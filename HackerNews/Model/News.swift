//
//  News.swift
//  HackerNews
//
//  Created by Reza Shirazian on 2/29/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import Foundation

struct News: Decodable, Equatable {
  let id: Int
  let title: String
  let by: String
  let urlString: String?
  let score: Int
  let timeIntervalSince1970: Int
  let descendants: Int?
  let kids: [Int]?
  
  var time: Date {
    return Date(timeIntervalSince1970: TimeInterval(self.timeIntervalSince1970))
  }
  
  var domain: String? {
    guard let host = self.url?.host else {
      return nil
    }
    return host.hasPrefix("www.") ? String(host.suffix(host.count - 4)) : host
  }
  
  var url: URL? {
    guard let urlClean = urlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
      return nil
    }
    return URL(string: urlClean)
  }
}

extension News {
  enum CodingKeys: String, CodingKey {
    case id = "id"
    case title = "title"
    case by = "by"
    case urlString = "url"
    case score = "score"
    case timeIntervalSince1970 = "time"
    case descendants = "descendants"
    case kids = "kids"
  }
}


