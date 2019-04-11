//
//  UIDevice+Project.swift
//  NetworkLayerTestProduction
//
//  Created by Gino on 06.04.19.
//  Copyright © 2019 Gino. All rights reserved.
//

import UIKit

extension UIDevice {
  
  var userAgent: String {
    return "Gino/\(Bundle.main.version) " +
      "(test.NetworkLayerTest; build:\(Bundle.main.buildNumber); " +
    "iOS \(UIDevice.current.systemVersion))"
  }
  
}
