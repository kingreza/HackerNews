////
////  NetworkService.swift
////  HackerNews
////
////  Created by Reza Shirazian on 3/1/20.
////  Copyright © 2020 Reza Shirazian. All rights reserved.
////
//
import Foundation

class NetworkService: NetworkProvider {
    func dataRequest(url: URL, onCompletion: @escaping (Result<Data, NetworkError>) -> Void) {
      URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard error == nil else {
          onCompletion(.failure(NetworkError.networkError(error!)))
          return
        }
  
        guard let data = data else {
          onCompletion(.failure(NetworkError.noData))
          return
        }
  
        guard let httpResponse = response as? HTTPURLResponse else {
          onCompletion(.failure(NetworkError.httpError(nil)))
          return
        }
        guard httpResponse.statusCode == 200 else {
          onCompletion(.failure(NetworkError.httpError(httpResponse.statusCode)))
          return
        }
        onCompletion(.success(data))
      }.resume()
    }
}
