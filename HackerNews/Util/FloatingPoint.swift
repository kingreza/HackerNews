//
//  FloatingPoint.swift
//  HackerNews
//
//  Created by Reza Shirazian on 4/10/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import Foundation

extension FloatingPoint {
  
  mutating func round(_ rule: FloatingPointRoundingRule, by scale: Self) {
    self = self.rounded(rule, by: scale)
  }
  
  func rounded(_ rule: FloatingPointRoundingRule, by scale: Self) -> Self {
    return (self * scale).rounded(rule) / scale
  }
}
