//
//  NewsRowElement.swift
//  HackerNews
//
//  Created by Reza Shirazian on 4/8/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import Listable
import BlueprintLists
import BlueprintUI
import BlueprintUICommonControls

struct NewsRowElement: BlueprintItemElement, Equatable {
  
  var index: Int
  var news: News
  var commentTapped: (News) -> Void
  var titleTapped: (News) -> Void

  static func == (lhs: NewsRowElement, rhs: NewsRowElement) -> Bool {
    return lhs.news == rhs.news && lhs.index == rhs.index
  }
  
  var identifier: Identifier<NewsRowElement> {
    return .init(news.id)
  }

  func element(with info: ApplyItemElementInfo) -> Element {
    return Inset(
      uniformInset: 10.0,
      wrapping: Column { column in
        column.verticalOverflow = .condenseUniformly
        column.verticalUnderflow = .growUniformly
        column.add(
          child: Row { row in
            row.horizontalUnderflow = .growUniformly
            row.horizontalOverflow = .condenseUniformly
            row.verticalAlignment = .fill
            row.add(child:
              Tappable(
                onTap: {
                  self.titleTapped(self.news)
                },
                wrapping: Label(text: "\(index + 1). \(news.title)") { label in
                  label.font = UIFont(
                    name: "Verdana",
                    size: 14)!
                  label.numberOfLines = 0
                
                }
              )
            )
          }
        )
        column.add(
          child: Row { row in
            row.verticalAlignment = .fill
            row.horizontalUnderflow = .growProportionally
            
            row.add(child:
              Label(text: "\(news.score) points by \(news.by) \(news.time.timeAgoSinceDate())") { label in
                label.font = UIFont(
                  name: "Verdana",
                  size: 12)!
                label.color =  UIColor(red:0.51, green:0.51, blue:0.51, alpha:1.00)
                label.numberOfLines = 1
              }
            )

            if let descendants = news.descendants, !(news.kids ?? []).isEmpty {
              row.add(child:
                Tappable(
                  onTap: {
                    self.commentTapped(self.news)
                  }, wrapping:
                  Label(
                    text: news.kids?.count == 1 ? " | 1 comment" : " | \(descendants) comments"
                    )
                  { label in
                    label.font = UIFont(
                      name: "Verdana",
                      size: 12
                    )!
                    label.numberOfLines = 1
                    label.color =  UIColor(red:0.51, green:0.51, blue:0.51, alpha:1.00)
                  }
                )
              )
            }
          }
        )
      }
    )
  }
}
