//
//  GithubJobsAPI.swift
//  NetworkLayerTestProduction
//
//  Created by Gino on 05.04.19.
//  Copyright © 2019 Gino. All rights reserved.
//

import Foundation

public struct GithubJobsAPI {
  
  var urlComponents: URLComponents {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "jobs.github.com"
    return urlComponents
  }
}
