//  
//  HackerNewsListWorkflow.swift
//  HackerNews
//
//  Created by Reza Shirazian on 4/7/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import Workflow
import WorkflowUI
import ReactiveSwift

// MARK: Input and Output

struct HackerNewsListWorkflow: Workflow {
  
  let newsService: NewsProvider
  
  init(newsService: NewsProvider) {
    self.newsService = newsService
  }
  
  enum Output {
    case commentTapped(News)
  }
}


// MARK: State and Initialization

extension HackerNewsListWorkflow {
  
  enum NewsState {
    case initial
    case loadingNewsList
    case loadedNewsList
    case loadingNews
    case loadedNews
    case completed
  }
  
  struct State: Equatable {
    var currentState: NewsState
    var currentCount: Int
    var newsIdList: [Int]
    var newsItems: [News]
    
    var idsToLoad:[Int] {
      let idsOfNewsAlreadyLoaded = newsItems.map{$0.id}
      let idsThatNeedToBeLoaded = newsIdList.prefix(currentCount)
      return idsThatNeedToBeLoaded.filter { !idsOfNewsAlreadyLoaded.contains($0) }
    }
  }
  
  func makeInitialState() -> HackerNewsListWorkflow.State {
    return State(currentState: .initial, currentCount: 20,  newsIdList: [], newsItems: [])
  }
  
  func workflowDidChange(from previousWorkflow: HackerNewsListWorkflow, state: inout State) {
    
  }
}


// MARK: Actions


extension HackerNewsListWorkflow {
  
  enum Action: WorkflowAction {
    
    typealias WorkflowType = HackerNewsListWorkflow
    
    case loadMoreNewsList
    case reload
    case commentTapped(News)
    case titleTapped(News)
    
    func apply(toState state: inout HackerNewsListWorkflow.State) -> HackerNewsListWorkflow.Output? {
      
      switch self {
      // Update state and produce an optional output based on which action was received.
      case .loadMoreNewsList:
        if state.currentState == .loadingNews {return nil}
        state.currentCount += 20
        state.currentState = .loadedNewsList
      case .reload:
        state.currentState = .loadingNewsList
      case .commentTapped(let news):
        return .commentTapped(news)
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
  
  public enum HackerNewsServiceWorkerAction: WorkflowAction {
    
    typealias WorkflowType = HackerNewsListWorkflow
    
    case newsIdListLoaded([Int])
    
    func apply(toState state: inout HackerNewsListWorkflow.State) -> HackerNewsListWorkflow.Output? {
      switch self {
      case .newsIdListLoaded(let newsIdList):
        if state.newsIdList != newsIdList {
          state.newsIdList = newsIdList
         
          state.currentState = state.idsToLoad.count == 0 ? .loadedNews : .loadingNews
          
        } else {
          state.currentState = .loadedNews
        }
      }
      return nil
    }
  }
  
  enum HackerNewsItemServiceWorkerAction: WorkflowAction {
    typealias WorkflowType = HackerNewsListWorkflow
    
    case newsLoaded(News)
    
    func apply(toState state: inout HackerNewsListWorkflow.State) -> HackerNewsListWorkflow.Output? {
      switch self {
        
      case .newsLoaded(let news):

        state.newsItems.append(news)
        state.newsItems = state.newsItems.reorder(by: state.newsIdList)
        if state.idsToLoad.count == 0 {
          state.currentState = state.newsIdList.count == state.currentCount ? .completed :.loadedNews
        }
       
      }
      return nil
    }
  }
}


// MARK: Workers
extension HackerNewsListWorkflow {
  struct HackerNewsItemServiceWorker: Worker {
    
    let newsProvider: NewsProvider
    let id: Int
    
    init(newsProvider: NewsProvider, ids: Int) {
      self.newsProvider = newsProvider
      self.id = ids
    }
    
    func run() -> SignalProducer<HackerNewsItemServiceWorkerAction, Never> {
      return SignalProducer<HackerNewsItemServiceWorkerAction, Never>() { observer, _  in
        self.newsProvider.getNews(id: self.id) { result in
          switch result {
          case .success(let news):
            observer.send(value: .newsLoaded(news))
            observer.sendCompleted()
          case .failure(_):
            observer.sendCompleted()
          }
        }
      }
    }
    
    func isEquivalent(to otherWorker: HackerNewsListWorkflow.HackerNewsItemServiceWorker) -> Bool {
      self.id == otherWorker.id
    }
  }
}

extension HackerNewsListWorkflow {
  
  struct HackerNewsListServiceWorker: Worker {
    let newsProvider: NewsProvider
    
    init(newsProvider: NewsProvider) {
      self.newsProvider = newsProvider
    }
    
    func run() -> SignalProducer<HackerNewsServiceWorkerAction, Never> {
      return SignalProducer<HackerNewsServiceWorkerAction, Never>() { observer, _ in
        self.newsProvider.getNewsList() { result in
          switch result {
          case .success(let list):
            observer.send(value: .newsIdListLoaded(list))
            observer.sendCompleted()
          default:
            return
          }
        }
      }
    }
    
    func isEquivalent(to otherWorker: HackerNewsListServiceWorker) -> Bool {
      return true
    }
  }
}

// MARK: Rendering

extension HackerNewsListWorkflow {
  
  typealias Rendering = HackerNewsListScreen
  func render(state: HackerNewsListWorkflow.State, context: RenderContext<HackerNewsListWorkflow>) -> Rendering {
    
    func displayLoading() -> HackerNewsListScreen {
      return HackerNewsListScreen(
        list: NewsListLoading()
      )
    }
    
    func displayNews() -> HackerNewsListScreen {
      let newsListSink = context.makeSink(of: Action.self)

      return HackerNewsListScreen(
        list: NewsListElement(
          news: state.newsItems,
          onLoadMore: {
            newsListSink.send(.loadMoreNewsList)
        },
          onRefresh: {
            newsListSink.send(.reload)
        },
          onCommentTapped: { news in
            newsListSink.send(.commentTapped(news))
        },
          onTitleTapped: { news in
            news.url == nil ? newsListSink.send(.commentTapped(news)) : newsListSink.send(.titleTapped(news))
          },
          isRefreshing: state.currentState == .loadingNews || state.currentState == .loadingNewsList || state.currentState == .initial
        )
      )
    }
    
    func loadNewsList() {
      let listServiceWorker = HackerNewsListServiceWorker(
        newsProvider: self.newsService
      )
      context.awaitResult(for: listServiceWorker)
    }
    
    func loadPendingNewsItems() {
      for id in state.idsToLoad {
        let itemServiceWorker = HackerNewsItemServiceWorker(newsProvider: self.newsService, ids: id)
        context.awaitResult(for: itemServiceWorker)
      }
    }
    
    switch state.currentState {
    case .initial:
      loadNewsList()
      return displayLoading()
    case .loadingNewsList:
      loadNewsList()
      return displayNews()
    case .loadingNews, .loadedNewsList:
      loadPendingNewsItems()
      return displayNews()
    case .loadedNews, .completed:
      return displayNews()
    }
  }
}
