//
//  MockNetworkService.swift
//  HackerNewsTests
//
//  Created by Reza Shirazian on 4/16/20.
//  Copyright © 2020 Reza Shirazian. All rights reserved.
//

import Foundation
@testable import HackerNews

class MockNetworkService: NetworkProvider {
  var lookup: [String: Data]
  
  init() {
    self.lookup = [:]
    self.lookup = buildMockDataLookup()
  }
  
  func dataRequest(url: URL, onCompletion: @escaping (Result<Data, NetworkError>) -> Void) {
    let key = url.lastPathComponent
    guard let data = lookup[key] else {
      onCompletion(.failure(.noData))
      return
    }
    onCompletion(.success(data))
  }
  
  private func buildMockDataLookup () -> [String: Data] {
    var result: [String: Data] = [:]
    let bundle = Bundle(for: type(of: self))
    let resourcesURL = bundle.resourceURL!
    let fileManager = FileManager.default
    
    do {
      
      let docsArray = try fileManager.contentsOfDirectory(at: resourcesURL, includingPropertiesForKeys: nil).filter{$0.absoluteString.suffix(5) == ".json"}
      for file in docsArray {
        result[file.lastPathComponent] = try! Data(contentsOf: file)
      }
      
    } catch {

    }
    return result
  }
}
