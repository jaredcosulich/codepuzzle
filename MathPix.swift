//
//  MathPix.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 6/21/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation
import Alamofire
import AWSCore
import AWSS3

class MathPix {

    var results = [String: String]()
    
    init() {}
    
    func getValue(identifier: String) -> String {
        return results[identifier]!
    }
    
    func processing(identifier: String) -> Bool {
        return !results.keys.contains(identifier)
    }
    
    func processImage(image: UIImage, identifier: String) {
//        if (identifier[identifier.startIndex] == "f") {
//            self.results[identifier] = "A 1"
//        } else {
//            self.results[identifier] = "10"
//        }

        let imageData = UIImagePNGRepresentation(image)! as NSData
        let base64String = imageData.base64EncodedString(options: .init(rawValue: 0))
        let parameters : Parameters = [
            "url" : "data:image/jpeg;base64," + base64String
        ]
        
        Alamofire.request("https://api.mathpix.com/v3/latex",
                          method: .post,
                          parameters : parameters,
                          encoding: JSONEncoding.default,
                          headers: [
                            "app_id" : "puzzleschool",
                            "app_key" : "a5f0c88b21f281282fce1adfa9609aaf"
            ])
            .responseJSON{ response in
                if (response.error != nil) { print("Error: \(response.error ?? "No Error" as! Error)") }
                
                if let json = response.result.value {
//                    let json = try? JSONSerialization.jsonObject(with: data as! Data, options: []) as? [String: Any]
//                    print("\(JSON)")
                    let value = (json as! NSDictionary)["latex"] as? String
                    print("\(identifier): \(value ?? "No Value")")
                    self.results[identifier] = value ?? "No Value"
                }
        }
    }

    
//    curl -X POST  \
//    -H "app_id: trial" \
//    -H "app_key: 34f1a4cea0eaca8540c95908b4dc84ab" \
//    -H "Content-Type: application/json" \
//    --data '{ "urls": {"inverted": "https://raw.githubusercontent.com/Mathpix/api-examples/master/images/inverted.jpg", "algebra": "https://raw.githubusercontent.com/Mathpix/api-examples/master/images/algebra.jpg"},"callback":{"post": "http://requestb.in/sr1x3lsr"}}'
//    
//    class func processImages() {
//        let base64String = imageData.base64EncodedString(options: .init(rawValue: 0))
//        let parameters : Parameters = [
//            "url" : "data:image/jpeg;base64," + base64String
//        ]
//        
//        Alamofire.request("https://api.mathpix.com/v3/batch",
//                          method: .post,
//                          parameters : parameters,
//                          encoding: JSONEncoding.default,
//                          headers: [
//                            "app_id" : "puzzleschool",
//                            "app_key" : "a5f0c88b21f281282fce1adfa9609aaf"
//            ])
//            .responseJSON{ response in
//                if let JSON = response.result.value {
//                    print("\(JSON)")
//                }
//        }
//    }

}
