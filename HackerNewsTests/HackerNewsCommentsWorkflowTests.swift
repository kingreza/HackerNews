//
//  HackerNewsCommentsWorkflowTests.swift
//  HackerNewsTests
//
//  Created by Reza Shirazian on 4/18/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import XCTest
import BlueprintUI
import Workflow
import WorkflowTesting

@testable import HackerNews

class HackerNewsCommentsWorkflowTests: XCTestCase {
  
  static var mockNetworkService: NetworkProvider!
  static var mockNewsService: NewsProvider!
  
  override class func setUp() {
    mockNetworkService = MockNetworkService()
    mockNewsService = NewsService(networkProvider: mockNetworkService)
  }
  
  //MARK: Action Tests
  
  func test_action_titleTapped(){
    let news = getNews()
    
    let state = HackerNewsCommentsWorkflow.State(
      newsItem: news,
      currentState: .loadingComments,
      commentsLookup: [:],
      commentViewModelLookUp: [:],
      commentsInOrder: [],
      commentsToLoad: news.kids!
    )
    
    HackerNewsCommentsWorkflow
      .Action
      .tester(withState: state)
      .send(
        action: .titleTapped(news),
        outputAssertions: { output in
          XCTAssertNil(output)
        }
      )
      .assertState {state in
        XCTAssertEqual(state.currentState, .loadingComments)
        XCTAssertEqual(state.commentsLookup, [:])
        XCTAssertEqual(state.commentViewModelLookUp, [:])
        XCTAssertEqual(state.commentsInOrder, [])
        XCTAssertEqual(state.commentsToLoad, news.kids!)
      }
    
  }
  
  func test_action_commentsLoaded() {
    let news = getNews()
    let comments = getComments(news.kids!)
    
    // No comments are loaded, root comments are queued up (news articles kids node)
    var state = HackerNewsCommentsWorkflow.State(
      newsItem: news,
      currentState: .loadingComments,
      commentsLookup: [:],
      commentViewModelLookUp: [:],
      commentsInOrder: [],
      commentsToLoad: news.kids!
    )
    
    var viewModelLookup: [Int: CommentViewModel] = [:]
    var commentLookUp: [Int: Comment] = [:]
    comments.forEach {
      viewModelLookup[$0.id] = CommentViewModel(comment: $0, indentation: 0)
      commentLookUp[$0.id] = $0
    }
    
    var commentsToLoad = Array(comments.compactMap{$0.kids}.joined())

    // Root comments are loaded, the comment look up and view model look up are set. All the comment's child nodes are queued up to be loaded next.
    HackerNewsCommentsWorkflow.HackerNewsCommentsWorkerAction
      .tester(withState: state)
      .send(
        action: .commentsLoaded(comments),
        outputAssertions: { output in
          XCTAssertNil(output)
        }
      )
      .assertState {state in
        XCTAssertEqual(state.currentState, .loadingComments)
        XCTAssertEqual(state.commentsLookup, commentLookUp)
        XCTAssertEqual(state.commentViewModelLookUp, viewModelLookup)
        XCTAssertEqual(state.commentsInOrder, comments)
        XCTAssertEqual(state.commentsToLoad, commentsToLoad)
      }
    
    // Second time commentsLoaded is called, this time all the child comments to the root comments are loaded. Every comment is now indented one unit. Comment look up and view model look up are updated. We also build out a ordered list of comments which indicates the order in which comments should be displayed (in order) (root 1 -> child 1 -> grandchild 1 -> root 2 -> child 2)
    state = HackerNewsCommentsWorkflow.State(
      newsItem: news,
      currentState: .loadingComments,
      commentsLookup: commentLookUp,
      commentViewModelLookUp: viewModelLookup,
      commentsInOrder: comments,
      commentsToLoad: commentsToLoad
    )
    
    let secondLevelComments = getComments(commentsToLoad)
    secondLevelComments.forEach {
      viewModelLookup[$0.id] = CommentViewModel(comment: $0, indentation: 1)
      commentLookUp[$0.id] = $0
    }
    let orderedComment = buildInOrderComments(for: news, commentsLookup: commentLookUp)
    
    commentsToLoad = Array(secondLevelComments.compactMap{$0.kids}.joined())
    HackerNewsCommentsWorkflow.HackerNewsCommentsWorkerAction
      .tester(withState: state)
      .send(
        action: .commentsLoaded(secondLevelComments),
        outputAssertions: { output in
          XCTAssertNil(output)
        }
      )
      .assertState {state in
        XCTAssertEqual(state.currentState, .loadingComments)
        XCTAssertEqual(state.commentsLookup, commentLookUp)
        XCTAssertEqual(state.commentViewModelLookUp, viewModelLookup)
        XCTAssertEqual(state.commentsInOrder, orderedComment)
        XCTAssertEqual(state.commentsToLoad, commentsToLoad)
      }
  }
  
  func test_action_commentErrored() {
    let news = getNews()
   
    // No comments are loaded, root comments are queued up (news articles kids node)
    let state = HackerNewsCommentsWorkflow.State(
      newsItem: news,
      currentState: .loadingComments,
      commentsLookup: [:],
      commentViewModelLookUp: [:],
      commentsInOrder: [],
      commentsToLoad: news.kids!
    )
    
    
    // If a comment is errored out, ensure it is removed from the comments to load list and continue on.
    let commentToError = news.kids!.first!
    HackerNewsCommentsWorkflow.HackerNewsCommentsWorkerAction
      .tester(withState: state)
      .send(
        action: .commentErrored(commentToError, NetworkError.noData),
        outputAssertions: { output in
          XCTAssertNil(output)
        }
      )
      .assertState {state in
        XCTAssertEqual(state.currentState, .loadingComments)
        XCTAssertEqual(state.commentsLookup, [:])
        XCTAssertEqual(state.commentViewModelLookUp, [:])
        XCTAssertEqual(state.commentsInOrder, [])
        XCTAssertEqual(state.commentsToLoad, news.kids!.filter{$0 != commentToError})
      }
    
  }
  //MARK: Render Tests
  
  func test_render_loadingComments() {
    let news = self.getNews()
    let comments = getComments(news.kids!)
    
    let workflow = HackerNewsCommentsWorkflow(
      newsService: HackerNewsCommentsWorkflowTests.mockNewsService,
      newsItem: news
    )
    
    var expectedState = ExpectedState<HackerNewsCommentsWorkflow>(
      state: workflow.makeInitialState()
    )
    
    var expectedWorker = ExpectedWorker(
      worker: HackerNewsCommentsWorkflow.HackerNewsCommentsLoaderWorker(
        newsProvider: HackerNewsCommentsWorkflowTests.mockNewsService,
        ids: news.kids!)
    )
    
    var renderExpectation = RenderExpectations<HackerNewsCommentsWorkflow>(
      expectedState: expectedState,
      expectedOutput: nil,
      expectedWorkers: [expectedWorker],
      expectedWorkflows: []
    )
    // Initial state with no comment loaded should render a loading element. It should fire up a worker to load all the root comments. State should be loadingComments.
    workflow
      .renderTester()
      .render(
        with: renderExpectation,
        assertions: { screen in
          XCTAssert(screen.list is NewsListLoading)
      }
    )
    
    var viewModelLookup: [Int: CommentViewModel] = [:]
    var commentLookUp: [Int: Comment] = [:]
    comments.forEach {
      viewModelLookup[$0.id] = CommentViewModel(comment: $0, indentation: 0)
      commentLookUp[$0.id] = $0
    }
    
    var commentsToLoad = Array(comments.compactMap{$0.kids}.joined())
    
    let partiallyLoadedState = HackerNewsCommentsWorkflow.State(
      newsItem: news,
      currentState: .loadingComments,
      commentsLookup: commentLookUp,
      commentViewModelLookUp: viewModelLookup,
      commentsInOrder: comments,
      commentsToLoad: commentsToLoad
    )
    
    expectedState = ExpectedState(state: partiallyLoadedState)
    
    expectedWorker = ExpectedWorker(
      worker: HackerNewsCommentsWorkflow.HackerNewsCommentsLoaderWorker(
        newsProvider: HackerNewsCommentsWorkflowTests.mockNewsService,
        ids: commentsToLoad)
    )
    
   renderExpectation = RenderExpectations<HackerNewsCommentsWorkflow>(
      expectedState: expectedState,
      expectedOutput: nil,
      expectedWorkers: [expectedWorker],
      expectedWorkflows: []
    )
    // with root comments loaded, we should render the root comments while triggering a worker which will load all their child comments. The root comments should not be indented at all.
    
    workflow
      .renderTester(
        initialState: partiallyLoadedState
      )
      .render(
        with: renderExpectation,
        assertions: { screen in
          XCTAssert(screen.list is CommentListElement)
          let list = screen.list as! CommentListElement
          let viewModels = comments.map{CommentViewModel(comment: $0, indentation: 0)}
          XCTAssert(list.comments == viewModels)
          
      }
    )
  }
  
  private func buildInOrderComments(for news: News, commentsLookup: [Int: Comment] ) -> [Comment] {
    let currentComments = news.kids?.compactMap{commentsLookup[$0]}
    var result: [Comment] = []
    for comment in currentComments ?? [] {
      buildInOrderComment(result: &result, commentsLookup: commentsLookup, currentComment: comment)
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
  
  private func getComments(_ ids: [Int]) -> [Comment] {
    var comments: [Comment] = []
    HackerNewsCommentsWorkflowTests.mockNewsService.getComments(ids: ids) {
      comments = try! $0.get()
    }
    return comments
  }
  
  private func getRootComments() -> [Comment] {
    let news = self.getNews()
    return getComments(news.kids!)
  }
  
  //We use the news item with id 22889778 for testing comments.
  private func getNews() -> News {
    return getNewsFrom(
      list: [22889778]).first!
  }
  
  private func getNewsFrom(list: [Int]) -> [News] {
    var newsItems: [News] = []
    for id in list {
      HackerNewsCommentsWorkflowTests.mockNewsService.getNews(id: id) { newsItem in
        newsItems.append(try! newsItem.result.get())
      }
    }
    return newsItems
  }
  
  private func getNewsList(upto: Int? = nil) -> [Int] {
    var newList : [Int] = []
    HackerNewsCommentsWorkflowTests.mockNewsService.getNewsList { result in
      let list = try! result.get()
      if let upto = upto {
        newList = Array(list.prefix(upto))
      } else {
        newList = list
      }
    }
    return newList
  }
}
