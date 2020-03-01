//
//  CommentHeaderElement.swift
//  HackerNews
//
//  Created by Reza Shirazian on 4/15/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import Listable
import BlueprintLists
import BlueprintUI
import BlueprintUICommonControls

struct CommentHeaderElement: BlueprintHeaderFooterElement, Equatable {
  static func == (lhs: CommentHeaderElement, rhs: CommentHeaderElement) -> Bool {
    return rhs.news == lhs.news
  }
  
  
  let news: News
  let titleTapped: (News) -> Void
  
  var element: Element {
    let newsItem = Column { column in
      column.verticalOverflow = .condenseUniformly
      column.verticalUnderflow = .growUniformly
      column.horizontalAlignment = .fill
      column.add(child:
        Box(
          backgroundColor: UIColor(
            red:0.96,
            green:0.96,
            blue:0.94,
            alpha:1.00),
          wrapping: Inset(
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
                      wrapping: Label(text: "\(news.title)") { label in
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
                      Label(
                        text: news.kids?.count == 1 ? " | 1 comment" : " | \(descendants) comments"
                      ){ label in
                        label.font = UIFont(
                          name: "Verdana",
                          size: 12
                          )!
                        label.numberOfLines = 1
                        label.color =  UIColor(red:0.51, green:0.51, blue:0.51, alpha:1.00)
                      }
                    )
                  }
                }
              )
            }
          )
        )
      )
      column.add(
        growPriority: 0,
        shrinkPriority: 0,
        child: Rule(
          orientation: .horizontal
        )
      )
    }
    return newsItem
  }
}
