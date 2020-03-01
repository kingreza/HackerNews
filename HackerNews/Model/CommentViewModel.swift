//
//  CommentViewModel.swift
//  HackerNews
//
//  Created by Reza Shirazian on 4/14/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import Foundation


struct CommentViewModel: Equatable {
  
  let text: NSAttributedString
  let indentation: Int
  let by: String
  let timeAgoSinceDate: String
  
  init(comment: Comment, indentation: Int) {
    let commentAsHtml = "<html style=\"font-family: Verdana, sans-serif;font-size:14;\"> \(comment.text) <html>"
    if let data = commentAsHtml.data(using: .unicode),
      let attributedString = try? NSMutableAttributedString(
      data: data,
      options: [.documentType: NSAttributedString.DocumentType.html],
      documentAttributes: nil) {
        self.text = attributedString
    } else {
        self.text = NSAttributedString(string: comment.text)
    }
    self.by = comment.by
    self.timeAgoSinceDate = comment.time.timeAgoSinceDate()
    self.indentation = indentation
  }
}
