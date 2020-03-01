//
//  NewsProvider.swift
//  HackerNews
//
//  Created by Reza Shirazian on 2/29/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import Foundation

enum NewsServiceState {
  case loading
  case ready
  case errored
}

protocol NewsProvider {
  
  func getNews(id: Int, onCompletion: @escaping (Result<News, NetworkError>) -> Void)
  func getComment(id: Int, onCompletion: @escaping (Result<Comment, NetworkError>) -> Void)
  func getComments(ids: [Int], onCompletion: @escaping (Result<[Comment], NetworkError>) -> Void)
  func getNewsList(onCompletion: @escaping (Result<[Int], NetworkError>) -> Void)

}
