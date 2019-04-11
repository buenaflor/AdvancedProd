//
//  HTTPResponse+Decodable.swift
//  AdvancedProd
//
//  Created by Gino on 11.04.19.
//  Copyright © 2019 Gino. All rights reserved.
//

import Foundation

extension HTTP.Response {
  func decoded<T: Decodable>(
    using decoder: JSONDecoder = .init()) throws -> T {
    do {
      guard let data = data else {
        throw APIError.invalidResponse
      }
      return try decoder.decode(T.self, from: data)
    } catch let error {
      throw error
    }
  }
}
