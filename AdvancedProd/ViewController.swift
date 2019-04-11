//
//  ViewController.swift
//  AdvancedProd
//
//  Created by Gino on 11.04.19.
//  Copyright © 2019 Gino. All rights reserved.
//

import UIKit

import AwaitKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let githubAPI: GithubAPI = GithubService()
    
    let params = [
      "description": "ios developer",
      "full_time": "true"
    ]
    
    let promise = githubAPI.getPositions(queryParameters: params)
    
    async {
      let response = try await(promise)
      let positions = try response.decoded() as Positions
      let jsonData = try JSONSerialization.data(withJSONObject: response.json!, options: .init(rawValue: 0))
      
      // Check if everything went well
      print("data: ", NSString(data: jsonData, encoding: 1)!)
      let fileManager = FileManager.default
      do {
        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        let fileURL = documentDirectory.appendingPathComponent("list.json")
        let data = try Data(contentsOf: fileURL)
        let decoded = try JSONDecoder().decode(Positions.self, from: data)
        print("decoded: ", decoded)
//        try jsonData.write(to: fileURL)
//        print("success written")
        
      } catch {
        print(error)
      }
      // Do something cool with the new JSON data
      
//      print(positions)
    }
    
    let presenter = ConfirmationPresenter(
      title: "Confirmation",
      question: "Delete this?",
      acceptTitle: "Yes",
      rejectTitle: "No") { (outcome) in
        switch outcome {
        case .accepted:
          print("do accepted")
        case .rejected:
          print("do rejected")
        }
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
      presenter.present(in: self)
    }
    
  }


}

