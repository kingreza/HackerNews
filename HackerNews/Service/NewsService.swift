//
//  NewsService.swift
//  HackerNews
//
//  Created by Reza Shirazian on 4/7/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import Foundation


class NewsService: NewsProvider {
  
  let networkService: NetworkProvider
  
  init(networkProvider: NetworkProvider) {
    self.networkService = networkProvider
  }

  func getNews(id: Int, onCompletion: @escaping (Result<News, NetworkError>) -> Void) {
    let onComplete: (Result<Data, NetworkError>) -> Void = { result  in
      switch result {
      case .success(let data):
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
          let decoded = try decoder.decode(News.self, from: data)
          onCompletion(.success(decoded))
        } catch {
          onCompletion(.failure(.decoderError(error)))
        }
      case .failure(let error):
        onCompletion(.failure(error))
      }
    }
    self.networkService.dataRequest(url: APIEndPoint.newsItem(id: id).endPoint, onCompletion: onComplete)
    //networkService.getNewsData(url: APIEndPoint.newsItem(id: id).endPoint, onCompletion: onCompletion)
  }
  
  func getNewsList(onCompletion: @escaping (Result<[Int], NetworkError>) -> Void) {
    let onComplete: (Result<Data,NetworkError>) -> Void = { result in
      switch result {
      case .success(let data):
        do {
           guard let newsId = try JSONSerialization.jsonObject(with: data, options: []) as? [Int] else {
             onCompletion(.failure(NetworkError.parseError))
             return
           }
           onCompletion(.success(newsId))
         } catch {
           onCompletion(.failure(NetworkError.decoderError(error)))
         }
      case .failure(let error):
        onCompletion(.failure(error))
      }
    }
    self.networkService.dataRequest(url: APIEndPoint.newsList.endPoint, onCompletion: onComplete)
    
//    networkService.getNewsLisData(url: APIEndPoint.newsList.endPoint) { result in
//
//      switch result {
//
//      case .success(let list):
//        onCompletion(.success(Array(list)))
//      case .failure(let error):
//        onCompletion(.failure(error))
//      }
//    }
  }
  
  func getComment(id: Int, onCompletion: @escaping (Result<Comment, NetworkError>) -> Void) {
    let onComplete: (Result<Data, NetworkError>) -> Void = { result  in
      switch result {
      case .success(let data):
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
          let decoded = try decoder.decode(Comment.self, from: data)
          onCompletion(.success(decoded))
        } catch {
          //print("error on url \(url)")
          onCompletion(.failure(.decoderError(error)))
        }
      case .failure(let error):
        onCompletion(.failure(error))
      }
    }
    self.networkService.dataRequest(url: APIEndPoint.newsItem(id: id).endPoint, onCompletion: onComplete)
  }
  
  func getComments(ids: [Int], onCompletion: @escaping (Result<[Comment], NetworkError>) -> Void) {
    var results: [Comment] = []
    var errors: [Error] = []
    var currentCount = 0
    for id in ids {
      self.getComment(id: id) { result in
        currentCount += 1
        switch result {
        case .success(let comment):
          results.append(comment)
        case .failure(let error):
          errors.append(error)
        }
        if currentCount == ids.count {
          onCompletion(.success(results))
        }
      }
    }
  }
}
