//
//  s3Util.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 7/8/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
import UIKit
import AWSS3
import AWSCognito

class S3Util {
    
    var processingCount = 0;
    
    let uuid = UIDevice.current.identifierForVendor!.uuidString
    
    let bucketName = "assets.codepuzzle.com"
    
    let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,
                                                            identityPoolId:"us-east-1:277eaedd-a718-4f7a-a8c4-2016d02f55d9")
    var contentUrls = [String: URL!]()
    
    var s3Url: URL!
    
    init() {
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration

        s3Url = AWSS3.default().configuration.endpoint.url
    }
    
    func processing() -> Bool {
        return processingCount > 0
    }
    
    func getS3Url(identifier: String, projectTimestamp: String) -> URL {
        let key = "\(uuid)-\(identifier)-\(projectTimestamp).png"
        return contentUrls[key]!
    }
    
    func upload(image: UIImage, identifier: String, projectTimestamp: String) {
        processingCount += 1
        
        let key = "\(uuid)-\(identifier)-\(projectTimestamp).png"

        var filename: URL!
        
        if let data = UIImagePNGRepresentation(image) {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            filename = documentsPath.appendingPathComponent(key)
            try? data.write(to: filename)
        }
        
        let request = AWSS3TransferManagerUploadRequest()!
        request.bucket = bucketName
        request.key = key
        request.body = filename
        request.acl = .publicReadWrite
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(request).continueWith(executor: AWSExecutor.mainThread()) { (task) -> Any? in
            if let error = task.error {
                print(error)
            }
            if task.result != nil {
                print("Uploaded \(key)")
                let contentUrl = self.s3Url.appendingPathComponent(self.bucketName).appendingPathComponent(key)
                self.contentUrls[key] = contentUrl
                print("URL: \(contentUrl)")
            }
            self.processingCount -= 1
            return nil
        }
    }

}
