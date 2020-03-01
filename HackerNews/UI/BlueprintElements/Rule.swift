//
//  Rule.swift
//  HackerNews
//
//  Created by Reza Shirazian on 4/16/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//
import BlueprintUI
import BlueprintUICommonControls

struct Rule: ProxyElement {
  static let Height: CGFloat = 1
  enum Orientation {
    case horizontal
    case vertical
  }
  var orientation: Orientation
  var elementRepresentation: Element {
    return ConstrainedSize(
      width: orientation == .horizontal ? .unconstrained : .absolute(Rule.Height),
      height: orientation == .vertical ? .unconstrained : .absolute(Rule.Height),
      wrapping: Box(backgroundColor: .lightGray)
    )
  }
}
