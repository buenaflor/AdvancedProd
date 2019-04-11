//
//  Bundle+Project.swift
//  NetworkLayerTestProduction
//
//  Created by Gino on 06.04.19.
//  Copyright © 2019 Gino. All rights reserved.
//

import Foundation

extension Bundle {
  var version: String {
    return infoDictionary?["CFBundleShortVersionString"] as? String ?? "unkonwn"
  }
  
  var buildNumber: String {
    return infoDictionary?["CFBundleVersion"] as? String ?? "unkonwn"
  }
}
