//
//  NewsRowLoadingElement.swift
//  HackerNews
//
//  Created by Reza Shirazian on 4/13/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import Listable
import BlueprintLists
import BlueprintUI

struct NewsRowLoadingElement: BlueprintItemElement, Equatable {
  
  func element(with info: ApplyItemElementInfo) -> Element {
    return ActivityIndicator()
  }
  
  var identifier: Identifier<NewsRowLoadingElement> {
    return .init("activityIndicator")
  }
}
