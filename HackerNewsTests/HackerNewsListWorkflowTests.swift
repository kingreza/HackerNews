//
//  HackerNewsListWorkflowTests.swift
//  HackerNewsTests
//
//  Created by Reza Shirazian on 4/16/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import XCTest
import BlueprintUI
import Workflow
import WorkflowTesting

@testable import HackerNews

// Tests for all actions and render permutations in HackerNewsListWorkflow.
class HackerNewsListWorkflowTests: XCTestCase {
  
  static var mockNetworkService: NetworkProvider!
  static var mockNewsService: NewsProvider!
  
  override class func setUp() {
    mockNetworkService = MockNetworkService()
    mockNewsService = NewsService(networkProvider: mockNetworkService)
  }
  
  //MARK: Action Tests
  
  func test_action_loadMoreNewsList(){
    let newsIds: [Int] = self.getNewsList(upto: 20)
    let newsItems: [News] = []
    
    /* When a loadMoreNewsList action is triggered we extend our current count by 20 and set state to loadedNewsList.
     
     This will indicate that the list has been upated and we should trigger another round of loading news items from the list.
     */
    var state = HackerNewsListWorkflow.State(
      currentState: .loadedNews,
      currentCount: 10,
      newsIdList: newsIds,
      newsItems: newsItems
    )
    
    HackerNewsListWorkflow
      .Action
      .tester(withState: state)
      .send(action: .loadMoreNewsList)
      .assertState { state in
        XCTAssert(state.currentCount == 30)
        XCTAssert(state.currentState == .loadedNewsList)
    }
    
    /* If we're in the process of loading news items, we ignore the call to load more news.
     */
    state = HackerNewsListWorkflow.State(
      currentState: .loadingNews,
      currentCount: 10,
      newsIdList: newsIds,
      newsItems: newsItems
    )
    
    HackerNewsListWorkflow
      .Action
      .tester(withState: state)
      .send(action: .loadMoreNewsList)
      .assertState { state in
        XCTAssertEqual(state.currentCount, 10)
        XCTAssertEqual(state.currentState,.loadingNews)
    }
    
  }
  
  func test_action_reload(){
    let newsIds: [Int] = self.getNewsList(upto: 20)
    let newsItems: [News] = self.getNewsFrom(list: Array(newsIds.prefix(upTo: 10)))
    
    let state = HackerNewsListWorkflow.State(
      currentState: .loadedNews,
      currentCount: 10,
      newsIdList: newsIds,
      newsItems: newsItems
    )
    
    /* When a reload action is triggered we set the current state to loadingNewsList. This will trigger a worker to reload the news list in the next render call. Nothing else should change in this call.
     */
    HackerNewsListWorkflow
      .Action
      .tester(withState: state)
      .send(action: .reload)
      .assertState { state in
        XCTAssertEqual(state.newsIdList, newsIds )
        XCTAssertEqual(state.newsItems, newsItems)
        XCTAssertEqual(state.currentCount, 10)
        XCTAssertEqual(state.currentState, .loadingNewsList)
    }
    
  }
  
  func test_action_commentTapped(){
    let newsIds: [Int] = self.getNewsList(upto: 20)
    let newsItems: [News] = self.getNewsFrom(list: Array(newsIds.prefix(upTo: 10)))
    let tappedNewsItem = newsItems[0]
    
    let state = HackerNewsListWorkflow.State(
      currentState: .loadedNews,
      currentCount: 10,
      newsIdList: newsIds,
      newsItems: newsItems
    )
    
    // When a comment is tapped, the action needs to be outputed to the root workflow to handle.
    
    HackerNewsListWorkflow
      .Action
      .tester(withState: state)
      .send(
        action: .commentTapped(tappedNewsItem),
        outputAssertions: { output in
          switch output {
          case .commentTapped(let news):
            XCTAssertEqual(news, tappedNewsItem)
          default:
            XCTFail("did not get expected output")
          }
      }
    )
  }
  
  func test_action_titleTapped(){
    let newsIds: [Int] = self.getNewsList(upto: 20)
    let newsItems: [News] = self.getNewsFrom(list: Array(newsIds.prefix(upTo: 10)))
    let tappedNewsItem = newsItems[0]
    
    let state = HackerNewsListWorkflow.State(
      currentState: .loadedNews,
      currentCount: 10,
      newsIdList: newsIds,
      newsItems: newsItems
    )
    
    //When a title tapped action is triggered we open the URL. Nothing changes within the workflow.
    
    HackerNewsListWorkflow
      .Action
      .tester(withState: state)
      .send(action: .titleTapped(tappedNewsItem))
      .assertState { state in
        XCTAssertEqual(state.currentState, .loadedNews)
        XCTAssertEqual(state.currentCount, 10)
        XCTAssertEqual(state.newsIdList, newsIds)
        XCTAssertEqual(state.newsItems, newsItems)
    }
  }
  
  func test_action_newsIdListLoaded(){
    let currentNewsIds: [Int] = self.getNewsList(upto: 20)
    var newsItems: [News] = self.getNewsFrom(list: Array(currentNewsIds.prefix(upTo: 10)))
    var newNewsIds: [Int] = Array(currentNewsIds.prefix(10)) + Array(self.getNewsList(upto: 30).suffix(10))
    
    var state = HackerNewsListWorkflow.State(
      currentState: .loadedNews,
      currentCount: 20,
      newsIdList: currentNewsIds,
      newsItems: newsItems
    )
    
    // Trigger a newsIdListLoaded where the last 10 items in the list have changed. We need to assert that the new list is now the list in the state, that the number of news items to load is set to 10, (the new items changed) and that those items match the last 10 items in the newIdList to load. We also need to see that state set to loading news (since we have a list with 10 new items)
    
    HackerNewsListWorkflow
      .HackerNewsServiceWorkerAction
      .tester(withState: state)
      .send(action: .newsIdListLoaded(newNewsIds))
      .assertState { state in
        XCTAssertEqual(state.newsIdList, newNewsIds)
        XCTAssertEqual(state.idsToLoad.count, 10)
        XCTAssertEqual(state.idsToLoad, Array(state.newsIdList.suffix(10)))
        XCTAssertEqual(state.currentState, .loadingNews)
    }
    
    newNewsIds = currentNewsIds.reversed()
    newsItems = self.getNewsFrom(list: Array(currentNewsIds.prefix(upTo: 20)))
    
    state = HackerNewsListWorkflow.State(
      currentState: .loadedNews,
      currentCount: 20,
      newsIdList: currentNewsIds,
      newsItems: newsItems
    )
    
    // Trigger a newsIdListLoaded where the list has the same items but the orders have changed. Assert that new list is now the list in the state, but the number of items to load is 0 since we don't have any new news items and that the state is set to loadedNews.
    
    HackerNewsListWorkflow
      .HackerNewsServiceWorkerAction
      .tester(withState: state)
      .send(action: .newsIdListLoaded(newNewsIds))
      .assertState { state in
        XCTAssertEqual(state.newsIdList, newNewsIds)
        XCTAssertEqual(state.idsToLoad.count, 0)
        XCTAssertEqual(state.currentState, .loadedNews)
    }
  }
  
  func test_action_newsLoaded() {
    let currentNewsIds: [Int] = self.getNewsList(upto: 20)
    var newsItems: [News] = self.getNewsFrom(list: Array(currentNewsIds.prefix(upTo: 10)))
    var newNewsItem: News = self.getNewsFrom(list: [currentNewsIds[10]]).first!
    
    var state = HackerNewsListWorkflow.State(
      currentState: .loadingNews,
      currentCount: 20,
      newsIdList: currentNewsIds,
      newsItems: newsItems
    )
    
    //Trigger a news loaded action from the news service worker with a news item. We already have 10 loaded, we need to load 10 and with the new one loaded that should leave 9 to go. our state should remain loadingNews.
    
    HackerNewsListWorkflow
      .HackerNewsItemServiceWorkerAction
      .tester(withState: state)
      .send(action: .newsLoaded(newNewsItem))
      .assertState { state in
        XCTAssertEqual(state.newsIdList, currentNewsIds)
        XCTAssertEqual(state.idsToLoad.count, 9)
        XCTAssertEqual(state.currentState, .loadingNews)
    }
    
    newsItems = self.getNewsFrom(list: Array(currentNewsIds.prefix(upTo: 15)))
    newNewsItem = self.getNewsFrom(list: [currentNewsIds[15]]).first!
    
    state = HackerNewsListWorkflow.State(
      currentState: .loadingNews,
      currentCount: 15,
      newsIdList: currentNewsIds,
      newsItems: newsItems
    )
    
    HackerNewsListWorkflow
      .HackerNewsItemServiceWorkerAction
      .tester(withState: state)
      .send(action: .newsLoaded(newNewsItem))
      .assertState { state in
        XCTAssertEqual(state.newsIdList, currentNewsIds)
        XCTAssertEqual(state.idsToLoad.count, 0)
        XCTAssertEqual(state.currentState, .loadedNews)
    }
    
    
    newsItems = self.getNewsFrom(list: Array(currentNewsIds.prefix(upTo: 19)))
    newNewsItem = self.getNewsFrom(list: [currentNewsIds[19]]).first!
    
    state = HackerNewsListWorkflow.State(
      currentState: .loadedNews,
      currentCount: 20,
      newsIdList: currentNewsIds,
      newsItems: newsItems
    )
    
    //Trigger a news loaded action from the news service worker with a news item. We already have 19 loaded, we need to load 1 more. When the last one is loaded we should have no more ids to load and since the count from the list and the total number of loaded news items are the same our state should be set to complete.
    
    HackerNewsListWorkflow
      .HackerNewsItemServiceWorkerAction
      .tester(withState: state)
      .send(action: .newsLoaded(newNewsItem))
      .assertState { state in
        XCTAssertEqual(state.newsIdList, currentNewsIds)
        XCTAssertEqual(state.idsToLoad.count, 0)
        XCTAssertEqual(state.currentState, .completed)
    }
    
  }
  
  //MARK: Render Tests
  
  func test_render_initial() {
    let workflow = HackerNewsListWorkflow(newsService: HackerNewsListWorkflowTests.mockNewsService)
    
    let expectedState = ExpectedState<HackerNewsListWorkflow>(
      state: workflow.makeInitialState()
    )
    
    let expectedWorker = ExpectedWorker(
      worker: HackerNewsListWorkflow.HackerNewsListServiceWorker(
        newsProvider: HackerNewsListWorkflowTests.mockNewsService)
    )
    
    let renderExpectation = RenderExpectations<HackerNewsListWorkflow>(
      expectedState: expectedState,
      expectedOutput: nil,
      expectedWorkers: [expectedWorker],
      expectedWorkflows: []
    )
    
    // In the initial state, we display a loading screen since nothing has been set yet.
    workflow
      .renderTester()
      .render(
        with: renderExpectation,
        assertions: { screen in
          XCTAssert(screen.list is NewsListLoading)
      }
    )
  }
  
  func test_render_loadingNewsList() {
    let workflow = HackerNewsListWorkflow(newsService: HackerNewsListWorkflowTests.mockNewsService)
    
    let expectedState = ExpectedState<HackerNewsListWorkflow>(
      state: HackerNewsListWorkflow.State(
        currentState: .loadingNewsList,
        currentCount: 10,
        newsIdList: [],
        newsItems: []
      )
    )
    
    let expectedWorker = ExpectedWorker(
      worker: HackerNewsListWorkflow.HackerNewsListServiceWorker(
        newsProvider: HackerNewsListWorkflowTests.mockNewsService)
    )
    
    let renderExpectation = RenderExpectations<HackerNewsListWorkflow>(
      expectedState: expectedState,
      expectedOutput: nil,
      expectedWorkers: [expectedWorker],
      expectedWorkflows: []
    )
    
    // when loading news list, we move to displaying NewsListElement but it won't have any items.
    workflow
      .renderTester(
        initialState: HackerNewsListWorkflow.State(
          currentState: .loadingNewsList,
          currentCount: 10,
          newsIdList: [],
          newsItems: []
        )
    )
      .render(
        with: renderExpectation,
        assertions: { screen in
          XCTAssert(screen.list is NewsListElement)
          let listElement = screen.list as! NewsListElement
          XCTAssertEqual(listElement.news.count, 0)
      }
    )
  }
  
  func test_render_loadedNewsList() {
    let currentNewsIds: [Int] = self.getNewsList(upto: 20)
    let workflow = HackerNewsListWorkflow(newsService: HackerNewsListWorkflowTests.mockNewsService)
    
    let expectedState = ExpectedState<HackerNewsListWorkflow>(
      state: HackerNewsListWorkflow.State(
        currentState: .loadedNewsList,
        currentCount: 3,
        newsIdList: currentNewsIds,
        newsItems: []
      )
    )

    let expectedNewsWorker1 = ExpectedWorker(
      worker: HackerNewsListWorkflow.HackerNewsItemServiceWorker(
        newsProvider: HackerNewsListWorkflowTests.mockNewsService,
        ids: 22893323
      )
    )
    
    let expectedNewsWorker2 = ExpectedWorker(
      worker: HackerNewsListWorkflow.HackerNewsItemServiceWorker(
        newsProvider: HackerNewsListWorkflowTests.mockNewsService,
        ids: 22889778
      )
    )
    
    let expectedNewsWorker3 = ExpectedWorker(
      worker: HackerNewsListWorkflow.HackerNewsItemServiceWorker(
        newsProvider: HackerNewsListWorkflowTests.mockNewsService,
        ids: 22894608
      )
    )
    
    let renderExpectation = RenderExpectations<HackerNewsListWorkflow>(
      expectedState: expectedState,
      expectedOutput: nil,
      expectedWorkers: [expectedNewsWorker1, expectedNewsWorker2, expectedNewsWorker3],
      expectedWorkflows: []
    )
    
    // when news list is loaded and we need to load 3 news items from the list, our render call should fire up three HackerNewsItemServiceWorker to load up the news items.
    workflow
      .renderTester(
        initialState: HackerNewsListWorkflow.State(
          currentState: .loadedNewsList,
          currentCount: 3,
          newsIdList: currentNewsIds,
          newsItems: []
        )
    )
      .render(
        with: renderExpectation,
        assertions: { screen in
          XCTAssert(screen.list is NewsListElement)
          let listElement = screen.list as! NewsListElement
          XCTAssertEqual(listElement.news.count, 0)
      }
    )
  }
  
  func test_render_loadingNews() {
    let currentNewsIds: [Int] = self.getNewsList(upto: 20)
    let newsItems: [News] = self.getNewsFrom(list: [currentNewsIds[0]])
    
    let workflow = HackerNewsListWorkflow(newsService: HackerNewsListWorkflowTests.mockNewsService)
    
    let expectedState = ExpectedState<HackerNewsListWorkflow>(
      state: HackerNewsListWorkflow.State(
        currentState: .loadingNews,
        currentCount: 3,
        newsIdList: currentNewsIds,
        newsItems: newsItems
      )
    )
    
    let expectedNewsWorker2 = ExpectedWorker(
      worker: HackerNewsListWorkflow.HackerNewsItemServiceWorker(
        newsProvider: HackerNewsListWorkflowTests.mockNewsService,
        ids: 22889778
      )
    )
    
    let expectedNewsWorker3 = ExpectedWorker(
      worker: HackerNewsListWorkflow.HackerNewsItemServiceWorker(
        newsProvider: HackerNewsListWorkflowTests.mockNewsService,
        ids: 22894608
      )
    )
    let renderExpectation = RenderExpectations<HackerNewsListWorkflow>(
      expectedState: expectedState,
      expectedOutput: nil,
      expectedWorkers: [expectedNewsWorker2, expectedNewsWorker3],
      expectedWorkflows: []
    )
    
    // when part of our news items have been loaded, our render call should fire up workers for the remaining items and display what's been loaded in the NewsListElement
    workflow
      .renderTester(
        initialState: HackerNewsListWorkflow.State(
          currentState: .loadingNews,
          currentCount: 3,
          newsIdList: currentNewsIds,
          newsItems: newsItems
        )
      )
      .render(
        with: renderExpectation,
        assertions: { screen in
          XCTAssert(screen.list is NewsListElement)
          let listElement = screen.list as! NewsListElement
          XCTAssertEqual(listElement.news.count, 1)
          XCTAssertEqual(listElement.news[0], newsItems[0])
      }
    )
    
  }
  
  func test_render_loadedNews() {
    let currentNewsIds: [Int] = self.getNewsList(upto: 20)
    let newsItems: [News] = self.getNewsFrom(list: Array(currentNewsIds.prefix(3)))
    
    let workflow = HackerNewsListWorkflow(newsService: HackerNewsListWorkflowTests.mockNewsService)
    
    let expectedState = ExpectedState<HackerNewsListWorkflow>(
      state: HackerNewsListWorkflow.State(
        currentState: .loadedNews,
        currentCount: 3,
        newsIdList: currentNewsIds,
        newsItems: newsItems
      )
    )
    
    let renderExpectation = RenderExpectations<HackerNewsListWorkflow>(
      expectedState: expectedState,
      expectedOutput: nil,
      expectedWorkers: [],
      expectedWorkflows: []
    )
    
    // When all our news items are loaded and caught up with the list, our render will fire up no workers and display all the news items loaded in NewsListElement
    workflow
      .renderTester(
        initialState: HackerNewsListWorkflow.State(
          currentState: .loadedNews,
          currentCount: 3,
          newsIdList: currentNewsIds,
          newsItems: newsItems
        )
      )
      .render(
        with: renderExpectation,
        assertions: { screen in
          XCTAssert(screen.list is NewsListElement)
          let listElement = screen.list as! NewsListElement
          XCTAssertEqual(listElement.news.count, 3)
          XCTAssertEqual(listElement.news, newsItems)
      }
    )
       
  }
  
  func test_render_completed() {
    let currentNewsIds: [Int] = self.getNewsList(upto: 20)
    let newsItems: [News] = self.getNewsFrom(list: currentNewsIds)
    
    let workflow = HackerNewsListWorkflow(newsService: HackerNewsListWorkflowTests.mockNewsService)
    
    let expectedState = ExpectedState<HackerNewsListWorkflow>(
      state: HackerNewsListWorkflow.State(
        currentState: .loadedNews,
        currentCount: 20,
        newsIdList: currentNewsIds,
        newsItems: newsItems
      )
    )
    
    let renderExpectation = RenderExpectations<HackerNewsListWorkflow>(
      expectedState: expectedState,
      expectedOutput: nil,
      expectedWorkers: [],
      expectedWorkflows: []
    )
    
    // Same as above When all our news items are loaded and caught up with the list (this time all items in the list (meaning our current count is equal to the total number of items in the list), our render will fire up no workers and display all the news items loaded in NewsListElement.
    workflow
      .renderTester(
        initialState: HackerNewsListWorkflow.State(
          currentState: .loadedNews,
          currentCount: 20,
          newsIdList: currentNewsIds,
          newsItems: newsItems
        )
      )
      .render(
        with: renderExpectation,
        assertions: { screen in
          XCTAssert(screen.list is NewsListElement)
          let listElement = screen.list as! NewsListElement
          XCTAssertEqual(listElement.news.count, 20)
          XCTAssertEqual(listElement.news, newsItems)
      }
    )
  }
  
 
  private func getNewsFrom(list: [Int]) -> [News] {
    var newsItems: [News] = []
    for id in list {
      HackerNewsListWorkflowTests.mockNewsService.getNews(id: id) { newsItem in
        newsItems.append(try! newsItem.result.get())
      }
    }
    return newsItems
  }
  
  private func getNewsList(upto: Int? = nil) -> [Int] {
    var newList : [Int] = []
    HackerNewsListWorkflowTests.mockNewsService.getNewsList { result in
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

