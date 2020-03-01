//
//  HackerNewsRootWorkflowTests.swift
//  HackerNewsTests
//
//  Created by Reza Shirazian on 4/18/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import XCTest
import BlueprintUI
import Workflow
import WorkflowTesting

@testable import HackerNews

class HackerNewsRootWorkflowTests: XCTestCase {
  static var mockNetworkService: NetworkProvider!
  static var mockNewsService: NewsProvider!
  
  override class func setUp() {
    mockNetworkService = MockNetworkService()
    mockNewsService = NewsService(networkProvider: mockNetworkService)
  }
  
  //MARK: Action tests
  
  func test_action_commentTapped() {
    
  }
  
  func test_action_backTapped() {
    
  }
  
  //MARK: Render tests
  
  func test_render_newsList() {
    
  }
  
  func test_render_comments() {
    
  }
}
