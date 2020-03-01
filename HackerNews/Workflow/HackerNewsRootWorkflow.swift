//  
//  HackerNewsRootWorkflow.swift
//  HackerNews
//
//  Created by Reza Shirazian on 4/8/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import Workflow
import WorkflowUI
import ReactiveSwift

// MARK: Input and Output

struct HackerNewsRootWorkflow: Workflow {
  
  let newsService: NewsProvider
  
  init(newsService: NewsProvider) {
    self.newsService = newsService
  }
  
  enum Output {
    
  }
}


// MARK: State and Initialization

extension HackerNewsRootWorkflow {
  
  struct State {
    enum Showing {
      case newsList
      case comments(News)
    }
    var currentlyShowing: Showing
  }
  
  func makeInitialState() -> HackerNewsRootWorkflow.State {
    return State(currentlyShowing: .newsList)
  }
  
  func workflowDidChange(from previousWorkflow: HackerNewsRootWorkflow, state: inout State) {
    
  }
}


// MARK: Actions

extension HackerNewsRootWorkflow {
  
  enum Action: WorkflowAction {
    
    case commentTapped(News)
    case backTapped
    
    typealias WorkflowType = HackerNewsRootWorkflow
    
    func apply(toState state: inout HackerNewsRootWorkflow.State) -> HackerNewsRootWorkflow.Output? {
      
      switch self {
      case .commentTapped(let news):
        state.currentlyShowing = .comments(news)
      case .backTapped:
        state.currentlyShowing = .newsList
      }
      return nil
    }
  }
}


// MARK: Workers

extension HackerNewsRootWorkflow {
  
  struct HackerNewsRootWorker: Worker {
    
    enum Output {
      
    }
    
    func run() -> SignalProducer<Output, Never> {
      fatalError()
    }
    
    func isEquivalent(to otherWorker: HackerNewsRootWorker) -> Bool {
      return true
    }
    
  }
  
}

// MARK: Rendering

extension HackerNewsRootWorkflow {
  
  typealias Rendering = BackStackScreen
  func render(state: HackerNewsRootWorkflow.State, context: RenderContext<HackerNewsRootWorkflow>) -> Rendering {

    let sink = context.makeSink(of: Action.self)
    let newList = BackStackScreen.Item(
      screen: HackerNewsListWorkflow(
        newsService: NewsService(
          networkProvider: NetworkService()
        )
      ).mapOutput({ output -> Action in
        switch output {
        case .commentTapped(let news):
          return .commentTapped(news)
        }
      }).rendered(with: context), barContent: BackStackScreen.BarContent(title: "Hacker News")
    )
    
    switch state.currentlyShowing {
    case .newsList:
      return BackStackScreen(items: [newList])
    case .comments(let newsItem):
      let comment = BackStackScreen.Item(
        screen: HackerNewsCommentsWorkflow(
          newsService: self.newsService,
          newsItem: newsItem
        )
        .mapOutput({output -> Action in })
        .rendered(with: context),
        barContent: BackStackScreen.BarContent(
          title: "Hacker News",
          leftItem: .button(
            .back {
              sink.send(.backTapped)
            }
          )
        )
      )
      return BackStackScreen(items: [newList, comment])
    }
  }
}
