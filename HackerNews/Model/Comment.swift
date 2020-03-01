//
//  Comment.swift
//  HackerNews
//
//  Created by Reza Shirazian on 4/8/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import Foundation

struct Comment: Decodable, Equatable {
  
  let id: Int
  let by: String
  let parent: Int
  let kids: [Int]?
  let text: String
  let timeIntervalSince1970: Int
  
  var time: Date {
    return Date(timeIntervalSince1970: TimeInterval(self.timeIntervalSince1970))
  }
}

extension Comment {
  
  enum CodingKeys: String, CodingKey {
    case id = "id"
    case by = "by"
    case parent = "parent"
    case kids = "kids"
    case text = "text"
    case timeIntervalSince1970 = "time"
  }
}
