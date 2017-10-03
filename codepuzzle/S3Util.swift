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

    var projectName: String!

    var className: String?
    
    var s3Url: URL!
    
    init(projectName: String, className: String?) {
        self.projectName = projectName
        self.className = className
        
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration

        self.s3Url = AWSS3.default().configuration.endpoint.url
    }
    
    func processing() -> Bool {
        return processingCount > 0
    }
    
    func fullProjectName() {
        var name = projectName
        if className != nil {
            name!.append("-\(className ?? "N/A")")
        }
    }
    
    func getS3Url(imageType: String) -> URL {
        return contentUrls[imageType]!
    }
    
    func upload(image: UIImage, imageType: String, completion: ((URL) -> Void)?) {
        processingCount += 1
        
        let key = "\(imageType)/\(fullProjectName())/\(uuid).png"

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
                let timestampKey = "\(key)-\(Date().timeIntervalSince1970)"
                let contentUrl = self.s3Url.appendingPathComponent(self.bucketName).appendingPathComponent(timestampKey)
                self.contentUrls[imageType] = contentUrl
                completion?(contentUrl)
            }
            self.processingCount -= 1
            return nil
        }
    }

}
