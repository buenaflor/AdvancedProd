//
//  APIError.swift
//  NetworkLayerTest
//
//  Created by Gino on 05.04.19.
//  Copyright © 2019 Gino. All rights reserved.
//

import Foundation

enum APIError: String, Error {
  
  case invalidURL
  
  case requestFailed
  
  case decodingFailure
  
  /// Thrown, when the operation fails du to missing permissions.
  case unauthorized
  
  /// Thrown when the serialisation of Core Data objects to post/put params
  /// failed.
  case serializationError
  
  case invalidResponse
    
  /// Thrown when the authentication is unsuccessful due to missing user
  /// profile for the specified facebook account.
  case noUserForThisFacebookAccount
  
  /// Thrown when the authentication is unsuccessful due to missing user
  /// profile for the specified google account.
  case noUserForThisGoogleAccount
  
  /// Thrown when the operation was cancelled.
  /// Do not treat as real error as it was initiated by the user.
  case cancelled
  
  /// Thrown when requested content is private
  /// and belongs to other user (http code 403)
  case forbidden
}
