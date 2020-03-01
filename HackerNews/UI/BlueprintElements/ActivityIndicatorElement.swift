//
//  ActivityIndicatorElement.swift
//  HackerNews
//
//  Created by Reza Shirazian on 4/13/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import BlueprintUI

struct ActivityIndicator: Element {
  
  var content: ElementContent {
    struct Measurer: Measurable {
      func measure(in constraint: SizeConstraint) -> CGSize {
        return CGSize(width: 50.0, height: 50.0)
      }
    }
    return ElementContent(measurable: Measurer())
  }
  
  func backingViewDescription(bounds: CGRect, subtreeExtent: CGRect?) -> ViewDescription? {
    return UIActivityIndicatorView.describe { config in
      config.builder = {UIActivityIndicatorView(style: .medium)}
      config.apply {
        $0.startAnimating()
      }
    }
  }
}
