//  
//  HackerNewsCommentsWorkflow.swift
//  HackerNews
//
//  Created by Reza Shirazian on 4/8/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import Workflow
import WorkflowUI
import ReactiveSwift

// MARK: Input and Output

struct HackerNewsCommentsWorkflow: Workflow {
  
  let newsService: NewsProvider
  let newsItem: News
  
  init(newsService: NewsProvider, newsItem: News) {
    self.newsService = newsService
    self.newsItem = newsItem
  }
  
  enum Output {
    
  }
}

// MARK: State and Initialization

extension HackerNewsCommentsWorkflow {
  
  enum CommentState {
    case loadingComments
    case completed
  }
  
  struct State: Equatable {
    let newsItem: News
    var currentState: CommentState
    var commentsLookup: [Int: Comment]
    var commentViewModelLookUp: [Int: CommentViewModel]
    var commentsInOrder: [Comment]
    var commentsToLoad: [Int]
  }
  
  func makeInitialState() -> HackerNewsCommentsWorkflow.State {
    return State(
      newsItem: self.newsItem,
      currentState: .loadingComments,
      commentsLookup: [:],
      commentViewModelLookUp: [:],
      commentsInOrder: [],
      commentsToLoad: self.newsItem.kids ?? []
    )
  }
  
  func workflowDidChange(from previousWorkflow: HackerNewsCommentsWorkflow, state: inout State) {
    
  }
}


// MARK: Actions

extension HackerNewsCommentsWorkflow {
  
  enum Action: WorkflowAction {

    typealias WorkflowType = HackerNewsCommentsWorkflow
    
    case titleTapped(News)
    
    func apply(toState state: inout HackerNewsCommentsWorkflow.State) -> HackerNewsCommentsWorkflow.Output? {
      switch self {
      case .titleTapped(let news):
        guard let url = news.url else {
          return nil
        }
        UIApplication.shared.open(
          url,
          options: [:],
          completionHandler: nil
        )
      }
      return nil
    }
  }
  
  enum HackerNewsCommentsWorkerAction: WorkflowAction {
    typealias WorkflowType = HackerNewsCommentsWorkflow
    
    case commentsLoaded([Comment])
    case commentErrored(Int, Error)
    
    func apply(toState state: inout HackerNewsCommentsWorkflow.State) -> HackerNewsCommentsWorkflow.Output? {
      switch self {
        
      case .commentErrored(let id,_):
        state.commentsLookup[id] = nil
        state.commentsToLoad.removeAll {
          $0 == id
        }
      case .commentsLoaded(let comments):
        comments.forEach { comment in
          state.commentsLookup[comment.id] = comment
          let viewModel = CommentViewModel(
            comment: comment,
            indentation: getIndentation(
              for: comment,
              commentLookUp: state.commentsLookup
            )
          )
          state.commentViewModelLookUp[comment.id] = viewModel
        }
        state.commentsInOrder = buildInOrderComments(for: state)
        state.commentsToLoad = Array(comments.compactMap{$0.kids}.joined())
        if state.commentsToLoad.count == 0 && state.newsItem.descendants ?? 0 <= state.commentsInOrder.count {
          state.currentState = .completed
        }
      }
      return nil
    }
    
    private func buildInOrderComments(for state: HackerNewsCommentsWorkflow.State) -> [Comment] {
      let currentComments = state.newsItem.kids?.compactMap{state.commentsLookup[$0]}
      var result: [Comment] = []
      for comment in currentComments ?? [] {
        buildInOrderComment(result: &result, commentsLookup: state.commentsLookup, currentComment: comment)
      }
      return result
    }
    
    private func buildInOrderComment(result: inout [Comment], commentsLookup: [Int:Comment] , currentComment: Comment) {
      result.append(currentComment)
      if let childComments = currentComment.kids?.compactMap({commentsLookup[$0]})  {
        for comment in childComments {
          buildInOrderComment(result: &result, commentsLookup: commentsLookup ,currentComment: comment)
        }
      }
    }
    
    private func getIndentation(for comment: Comment, commentLookUp: [Int: Comment]) -> Int {
      var currentIndentation = 0
      var isDone = false
      var currentNode = comment.parent
      while(!isDone) {
        guard let currentParentId = commentLookUp[currentNode]?.id,
          let currentParent = commentLookUp[currentParentId],
          currentIndentation <= 6 else {
          isDone = true
          break
        }
        currentNode = currentParent.parent
        currentIndentation += 1
      }
      return currentIndentation
    }
  }
}


// MARK: Workers

extension HackerNewsCommentsWorkflow {
  
  struct HackerNewsCommentsLoaderWorker: Worker {
    
    let newsProvider: NewsProvider
    let ids: [Int]
    
    init(newsProvider: NewsProvider, ids: [Int]) {
      self.newsProvider = newsProvider
      self.ids = ids
    }
    func run() -> SignalProducer<HackerNewsCommentsWorkerAction, Never> {
      return SignalProducer<HackerNewsCommentsWorkerAction, Never>() { observer, _ in
        self.newsProvider.getComments(ids: self.ids){ result in
          switch result {
          case .success(let comment):
            observer.send(value: .commentsLoaded(comment))
            observer.sendCompleted()
          default:
            fatalError()
          }
        }
      }
    }
    
    func isEquivalent(to otherWorker: HackerNewsCommentsLoaderWorker) -> Bool {
      self.ids == otherWorker.ids
    }
  }
}


// MARK: Rendering

extension HackerNewsCommentsWorkflow {
  
  typealias Rendering = HackerNewsListScreen
  func render(state: HackerNewsCommentsWorkflow.State, context: RenderContext<HackerNewsCommentsWorkflow>) -> Rendering {
    
    let sink = context.makeSink(of: Action.self)
    func displayComments() -> HackerNewsListScreen {
      return HackerNewsListScreen(
        list: CommentListElement(
          news: state.newsItem,
          comments: state.commentsInOrder.compactMap{state.commentViewModelLookUp[$0.id]},
          onTitleTapped: { news in
            sink.send(.titleTapped(news))
          }
        )
      )
    }
    
    func displayLoading() -> HackerNewsListScreen {
      return HackerNewsListScreen(
        list: NewsListLoading()
      )
    }
    
    switch state.currentState {
      
    case .loadingComments:
      let hackerNewsCommentWorker = HackerNewsCommentsLoaderWorker(
        newsProvider: self.newsService,
        ids: state.commentsToLoad
      )
      context.awaitResult(for: hackerNewsCommentWorker)
      if state.commentsInOrder.count == 0 {
        return displayLoading()
      }
      return displayComments()
    case .completed:
      return displayComments()
    }
  }
}
