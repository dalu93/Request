//
//  ViewController.swift
//  Request
//
//  Created by Luca D'Alberti on 2/17/17.
//  Copyright © 2017 dalu93. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
//    var request: Request!
    
    let accessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6IjU4YTVjZTZmZmZlZmY3MDAwNGU2Mzk4ZSJ9.V4Bs8uSv_FYayqEw-Q_oYvUvSk-maXPQaYiG7KMMsLA"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let request = try! Request(url: "http://rednote-ddex-development.herokuapp.com/api/search", method: .get, parameters: ["q": "hello", "access_token": accessToken], parameterEncoding: URLEncoding())
            .validate(using: StatusCodeValidator())
            .responseJSON { response in
            switch response.result {
            case .success(let json):
                print(json)
                
            case .failed(let error):
                print(error)
            }
        }.run()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

