//
//  ConfirmationPresenter.swift
//  AdvancedProd
//
//  Created by Gino on 11.04.19.
//  Copyright © 2019 Gino. All rights reserved.
//

import UIKit

enum Outcome {
  case accepted
  case rejected
}

struct ConfirmationPresenter {
  
  let title: String?
  let question: String
  let acceptTitle: String
  let rejectTitle: String
  let handler: (Outcome) -> Void
  
  func present(in viewController: UIViewController) {
    let alert = UIAlertController(
      title: title,
      message: question,
      preferredStyle: .alert
    )
    
    let rejectAction = UIAlertAction(title: rejectTitle, style: .cancel) { _ in
      self.handler(.rejected)
    }
    
    let acceptAction = UIAlertAction(title: acceptTitle, style: .default) { _ in
      self.handler(.accepted)
    }
    
    alert.addAction(rejectAction)
    alert.addAction(acceptAction)
    
    viewController.present(alert, animated: true)
  }
}
