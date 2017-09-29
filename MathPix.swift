//
//  MathPix.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 6/21/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation
import Alamofire

class MathPix {

    var results = [String: String]()
    
    init() {}
    
    func getValue(identifier: String) -> String {
        return results[identifier]!
    }
    
    func processing(identifier: String) -> Bool {
        return !results.keys.contains(identifier)
    }
    
    func processImage(image: UIImage, identifier: String, result: String?) {
        if (result != nil) {
            self.results[identifier] = result
            return
        }
        
        let imageData = UIImagePNGRepresentation(image)! as NSData
        let base64String = imageData.base64EncodedString(options: .init(rawValue: 0))
        let parameters : Parameters = [
            "url" : "data:image/jpeg;base64," + base64String
        ]
        
        Alamofire.request(
            "https://api.mathpix.com/v3/latex",
            method: .post,
            parameters : parameters,
            encoding: JSONEncoding.default,
            headers: [
                "app_id" : "puzzleschool",
                "app_key" : "a5f0c88b21f281282fce1adfa9609aaf"
            ]
        ).responseJSON{ response in
            if (response.error != nil) { print("Error: \(response.error ?? "No Error" as! Error)") }
            
            if let json = response.result.value {
                let value = (json as! NSDictionary)["latex"] as? String
                self.results[identifier] = value ?? "No Value"
            }
        }
    }
}
