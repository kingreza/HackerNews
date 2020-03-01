//
//  AttributedTextViewElement.swift
//  HackerNews
//
//  Created by Reza Shirazian on 4/10/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import BlueprintUI
import UIKit

public struct AttributedTextViewElement: Element {
  
  public var attributedText: NSAttributedString
  public var numberOfLines: Int = 0
  /// The scale to which pixel measurements will be rounded. Defaults to `UIScreen.main.scale`.
  public var roundingScale: CGFloat = UIScreen.main.scale
  
  public init(attributedText: NSAttributedString) {
    self.attributedText = attributedText
  }
  
  public var content: ElementContent {
    struct Measurer: Measurable {
      
      var attributedText: NSAttributedString
      var roundingScale: CGFloat
      
      func measure(in constraint: SizeConstraint) -> CGSize {
        let foo = UITextView()
        foo.attributedText = attributedText
        var size = foo.sizeThatFits(constraint.maximum)
        size.width = size.width.rounded(.up, by: roundingScale)
        size.height = size.height.rounded(.up, by: roundingScale)
        
        return size
      }
    }
    
    return ElementContent(measurable: Measurer(attributedText: attributedText, roundingScale: roundingScale))
  }
  
  public func backingViewDescription(bounds: CGRect, subtreeExtent: CGRect?) -> ViewDescription? {
    return UITextView.describe { (config) in
      config[\.attributedText] = attributedText
      config[\.isScrollEnabled] = false
      config[\.isEditable] = false
      config[\.backgroundColor] = .clear
    }
  }
}
