//
//  CommentListElement.swift
//  HackerNews
//
//  Created by Reza Shirazian on 4/8/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import Listable
import BlueprintLists
import BlueprintUI
import BlueprintUICommonControls


struct CommentListElement: ProxyElement {

  let news: News
  let comments: [CommentViewModel]
  let onTitleTapped: (News) -> Void
  
  var elementRepresentation: Element {
    return List { list in
      list += Section(identifier: "News") { section in
        let commentRowElements = comments.map(getCommentRowForComment)
        for element in commentRowElements {
          section.add(
            Item(with: element)
          )
        }
        section.header = HeaderFooter(
          with: CommentHeaderElement(
            news: news,
            titleTapped: onTitleTapped
          )
        )
      }
      list.appearance.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.94, alpha:1.00)
    }
  }
  
  private func getCommentRowForComment(comment: CommentViewModel) -> CommentRowElement {
    return CommentRowElement(
      text: comment.text,
      indentation: comment.indentation,
      by: comment.by,
      timeAgoSinceDate: comment.timeAgoSinceDate
    )
  }
}

