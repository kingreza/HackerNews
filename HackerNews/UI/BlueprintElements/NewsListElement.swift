//
//  NewsListElement.swift.swift
//  HackerNews
//
//  Created by Reza Shirazian on 4/7/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import Listable
import BlueprintLists
import BlueprintUI
import BlueprintUICommonControls

struct NewsListLoading: ProxyElement {
  
  var elementRepresentation: Element {
    return List { list in
      list += Section(identifier: "News") { section in
        section.add(Item(with: NewsRowLoadingElement()))
      }
    }
  }
}

struct NewsListElement: ProxyElement {
  
  var news: [News]
  var onLoadMore: () -> Void
  var onRefresh: () -> Void
  var onCommentTapped: (News) -> Void
  var onTitleTapped: (News) -> Void
  var isRefreshing: Bool
  
  private var refreshController: RefreshControl {
    return RefreshControl(isRefreshing: self.isRefreshing) {
      self.onRefresh()
    }
  }
  
  var elementRepresentation: Element {
    return List { list in
      list.content.refreshControl = refreshController
      list += Section(identifier: "News") { section in
        section += news.enumerated().map { (index, newsItem) in
          let item = Item(
            NewsRowElement(
              index: index,
              news: newsItem,
              commentTapped: onCommentTapped,
              titleTapped: onTitleTapped
            )
          ) { item in
            item.onDisplay = { idRow in
              // If the item being displayed is the last item, call onLoadMore
              if idRow.news.id == self.news.last?.id {
                self.onLoadMore()
              }
            }
          }
          return item
        }
        list.animatesChanges = true
        list.appearance.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.94, alpha:1.00)
      }
    }
  }
}

