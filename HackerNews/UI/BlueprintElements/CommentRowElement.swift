//
//  CommentRowElement.swift
//  HackerNews
//
//  Created by Reza Shirazian on 4/15/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import Listable
import BlueprintLists
import BlueprintUI
import BlueprintUICommonControls

struct CommentRowElement: BlueprintItemElement {
  
  let text: NSAttributedString
  let indentation: Int
  let by: String
  let timeAgoSinceDate: String
  
  func element(with info: ApplyItemElementInfo) -> Element {
    let result = Inset(
      top: 5.0,
      bottom: 5.0,
      left: 15 * CGFloat(indentation) + 5.0,
      right: 5.0,
      wrapping: Column { column in
        column.verticalOverflow = .condenseUniformly
        column.verticalUnderflow = .growUniformly
        column.add(
          child: Row { row in
            row.horizontalUnderflow = .growUniformly
            row.horizontalOverflow = .condenseUniformly
            row.verticalAlignment = .fill
            row.add(child:
              Label(text:"\(by) \(timeAgoSinceDate)") { label in
                label.font = UIFont(
                  name: "Verdana",
                  size: 12)!
                label.color =  UIColor(red:0.51, green:0.51, blue:0.51, alpha:1.00)
                label.numberOfLines = 1
              }
            )
          }
        )
        
        column.add(
          child: Row { row in
            row.add(child:
              AttributedTextViewElement(attributedText: text)
            )
          }
        )
      }
    )
    return result
  }
  
  var identifier: Identifier<CommentRowElement> {
    return .init(text)
  }
  
  func wasUpdated(comparedTo other: CommentRowElement) -> Bool {
    return text != other.text
  }
}
