//
//  NetworkProvider.swift
//  HackerNews
//
//  Created by Reza Shirazian on 3/1/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import Foundation


protocol NetworkProvider {
  func dataRequest(url: URL, onCompletion: @escaping (Result<Data, NetworkError>) -> Void)
}

enum APIEndPoint {
  case newsList
  case newsItem(id: Int)
  case commentItem(id: Int)
}

enum NetworkError: Error {
  case networkError(Error)
  case httpError(Int?)
  case decoderError(Error)
  case parseError
  case noData
}

extension APIEndPoint {
  
  var endPoint: URL {
    switch self {
    case .newsList:
      return URL(string:"https://hacker-news.firebaseio.com/v0/topstories.json")!
    case .newsItem(let id):
      return URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json")!
    case .commentItem(id: let id):
      return URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json")!
    }
  }
}
