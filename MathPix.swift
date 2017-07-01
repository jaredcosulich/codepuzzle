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

    class func processSingleImage(imageData : NSData) {
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
                if let JSON = response.result.value {
                    print("\(JSON)")
                }
        }
    }
    
//    func uploadFileToS3(_ s3: S3, data : Data, fileName : String, mimeType : String) {
//        let credentialsProvider = AWSCognitoCredentialsProvider(
//            regionType: CognitoRegionType,
//            identityPoolId: CognitoIdentityPoolId)
//        let configuration = AWSServiceConfiguration(
//            region: DefaultServiceRegionType,
//            credentialsProvider: credentialsProvider)
//        AWSServiceManager.default().defaultServiceConfiguration = configuration
//    }
//    
//    class func processMultipleImage() {
//        let base64String = imageData.base64EncodedString(options: .init(rawValue: 0))
//        let parameters : Parameters = [
//            "url" : "data:image/jpeg;base64," + base64String
//        ]
//        
//        Alamofire.request("https://api.mathpix.com/v3/latex",
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
//
    
//    curl -X POST https://api.mathpix.com/v3/batch \
//    -H "app_id: trial" \
//    -H "app_key: 34f1a4cea0eaca8540c95908b4dc84ab" \
//    -H "Content-Type: application/json" \
//    --data '{ "urls": {"inverted": "https://raw.githubusercontent.com/Mathpix/api-examples/master/images/inverted.jpg", "algebra": "https://raw.githubusercontent.com/Mathpix/api-examples/master/images/algebra.jpg"},"callback":{"post": "http://requestb.in/sr1x3lsr"}}'
    
    
//    Using NSUrl
//    
//    let headers = [
//        "content-type": "application/json",
//        "app_id": "puzzleschool",
//        "app_key": "a5f0c88b21f281282fce1adfa9609aaf"
//    ]
//    
//    let parameters = ["url": "data:image/jpeg;base64,{BASE64-STRING}"] as [String : Any]
//
//    let postData = try? JSONSerialization.data(withJSONObject: parameters, options: [])
//
//    let request = NSMutableURLRequest(url: NSURL(string: "https://api.mathpix.com/v3/latex")! as URL,
//                                      cachePolicy: .useProtocolCachePolicy,
//                                      timeoutInterval: 60.0)
//    
//    let session = URLSession.shared
//    let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
//        if (error != nil) {
//            print(error)
//        } else {
//            let httpResponse = response as? HTTPURLResponse
//            print(httpResponse)
//        }
//    })
//
//    dataTask.resume()
//
//
//    // Using Alamofire
//    // git url : https://github.com/Mathpix/api-examples/tree/extra/swift
//
//    func processSingleImage(imageName : String) {
//        request.httpMethod = "POST"
//        request.allHTTPHeaderFields = headers
//        request.httpBody = postData as Data
//        
//        if let data = NSData(contentsOfFile: imageName) {
//            let base64String = data.base64EncodedString(options: .init(rawValue: 0))
//            let parameters : Parameters = [
//                "url" : "data:image/jpeg;base64," + base64String
//            ]
//            
//            Alamofire.request("https://api.mathpix.com/v3/latex",
//                              method: .post,
//                              parameters : parameters,
//                              encoding: JSONEncoding.default,
//                              headers: [
//                                "app_id" : "mathpix",
//                                "app_key" : "139ee4b61be2e4abcfb1238d9eb99902"
//                ])
//                .responseJSON{ response in
//                    if let JSON = response.result.value {
//                        print("\(JSON)")
//                    }
//            }
//        }
//    }
}
