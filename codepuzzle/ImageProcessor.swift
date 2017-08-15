//
//  ImageProcessor.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 6/22/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation
import UIKit


class ImageProcessor {
    
    class func normalize(image: UIImage) -> UIImage {
        if (image.imageOrientation == UIImageOrientation.up) {
            return image
        }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        image.draw(in: rect)
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return normalizedImage!;
    }
    
    class func rotate(image: UIImage, left: Bool) -> UIImage {
        let degrees = CGFloat(left ? -90 : 90.0)
        let size = image.size
               
        //Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView = UIView(frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat(Double.pi / 180))
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        //Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat(Double.pi / 180)))
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)

        let newOrigin = CGPoint(x: -image.size.width / 2, y: -image.size.height / 2)
        bitmap.draw(image.cgImage!, in: CGRect(origin: newOrigin, size: image.size))
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
        
    }
    
    class func borderCards(image: UIImage, cardList: CardListWrapper, index: Int32 = -1) -> UIImage {
        UIGraphicsBeginImageContext(image.size)
        image.draw(at: CGPoint.zero)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setStrokeColor(UIColor.green.cgColor)
        ctx?.setLineWidth(8)
        
        if (index == -1) {
            for i in 0..<cardList.count() {
                ctx?.stroke(cardList.getFullRect(i))
            }
        } else {
            ctx?.stroke(cardList.getFullRect(index))

            ctx?.setStrokeColor(UIColor.red.cgColor)
            ctx?.stroke(cardList.getParamRect(index))

            ctx?.setStrokeColor(UIColor.blue.cgColor)
            ctx?.stroke(cardList.getFunctionRect(index))
        }

        let modifiedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return modifiedImage!
    }
    
    class func cropCard(image: UIImage, rect: CGRect) -> UIImage {
        return UIImage(cgImage: (image.cgImage?.cropping(to: rect))!)
    }
        
    
//    class func upload(uploadRequest: AWSS3TransferManagerUploadRequest) {
//        let transferManager = AWSS3TransferManager.default()
//        
//        transferManager.upload(uploadRequest).continueWith { (task) -> AnyObject! in
//            if let error = task.error {
//                print("upload() failed: [\(error)]")
//            }
//            
//            if task.result != nil {
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    if let index = self.indexOfUploadRequest(self.uploadRequests, uploadRequest: uploadRequest) {
//                        self.uploadRequests[index] = nil
//                        self.uploadFileURLs[index] = uploadRequest.body
//                        
//                        let indexPath = NSIndexPath(forRow: index, inSection: 0)
//                        self.collectionView.reloadItemsAtIndexPaths([indexPath])
//                    }
//                })
//            }
//            return nil
//        }
//    }
    
}

