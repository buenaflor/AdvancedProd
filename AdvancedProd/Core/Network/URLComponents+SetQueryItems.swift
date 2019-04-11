//
//  URLComponents+SetQueryItems.swift
//  NetworkLayerTestProduction
//
//  Created by Gino on 05.04.19.
//  Copyright © 2019 Gino. All rights reserved.
//

import Foundation

extension URLComponents {
  
  mutating func setQueryItems(with parameters: HTTP.QueryParameters) {
    self.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
  }
}
