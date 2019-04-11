//
//  GenericResult.swift
//  AdvancedProd
//
//  Created by Gino on 11.04.19.
//  Copyright © 2019 Gino. All rights reserved.
//

import Foundation

enum Result<Value> {
  case success(Value)
  case error(Error)
}

