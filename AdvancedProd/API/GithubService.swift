//
//  GithubService.swift
//  AdvancedProd
//
//  Created by Gino on 11.04.19.
//  Copyright © 2019 Gino. All rights reserved.
//

import PromiseKit

typealias JSON = [[String: Any]]

protocol GithubAPI {
  func getPositions(queryParameters: HTTP.QueryParameters) -> Promise<HTTP.Response>
}

final public class GithubService: GithubAPI {
  
  @discardableResult
  func getPositions(queryParameters: HTTP.QueryParameters) -> Promise<HTTP.Response> {
    let path = "/positions.json"
    let urlComponents = Config.githubJobsAPI.urlComponents
    
    let http = HTTP()
    
    let promise = http.get(urlComponents, path: path, parameters: queryParameters)
    
    return promise
  }
}


typealias Positions = [Position]

struct Position: Codable {
  let id, type: String
  let url: String
  let createdAt, company: String
  let companyURL: String?
  let location, title, description, howToApply: String
  let companyLogo: String?
  
  enum CodingKeys: String, CodingKey {
    case id, type, url
    case createdAt = "created_at"
    case company
    case companyURL = "company_url"
    case location, title, description
    case howToApply = "how_to_apply"
    case companyLogo = "company_logo"
  }
}
