//
//  Array.swift
//  HackerNews
//
//  Created by Reza Shirazian on 4/14/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import Foundation

extension Array where Element == News {
  
  func reorder(by preferredOrder: [Int]) -> [Element] {
    
    return self.sorted { (lhs, rhs) -> Bool in
      guard let first = preferredOrder.firstIndex(of: lhs.id) else {
        return false
      }
      
      guard let second = preferredOrder.firstIndex(of: rhs.id) else {
        return true
      }
      
      return first < second
    }
  }
}
