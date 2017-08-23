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
    
    class func rotate(image: UIImage, degrees: CGFloat) -> UIImage {
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
    
    class func borderCards(image: UIImage, cardList: CardListWrapper, index: Int32 = -1, style: String = "full") -> UIImage {
        UIGraphicsBeginImageContext(image.size)
        image.draw(at: CGPoint.zero)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setStrokeColor(UIColor.green.cgColor)
        ctx?.setLineWidth(8)
        
        if (index == -1) {
            for i in 0..<cardList.count() {
                _borderCard(ctx: ctx!, image: image, cardList: cardList, index: i, style: style)
            }
        } else {
            _borderCard(ctx: ctx!, image: image, cardList: cardList, index: index, style: style)
        }

        let modifiedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return modifiedImage!
    }
    
    class func _borderCard(ctx: CGContext, image: UIImage, cardList: CardListWrapper, index: Int32, style: String = "full") {
        let rotation = CGFloat(cardList.getRotation(index))
        let hex = cardList.getHexRect(index)
        let xTranslation = hex.minX + (hex.size.width / 2)
        let yTranslation = hex.minY + (hex.size.height / 2)
        
        ctx.translateBy(x: xTranslation, y: yTranslation)
        ctx.rotate(by: (rotation * CGFloat(CGFloat.pi / 180)))
        ctx.translateBy(x: xTranslation * -1, y: yTranslation * -1)
        
        switch style {
        case "hex":
            ctx.stroke(cardList.getHexRect(index))
        case "function":
            ctx.stroke(cardList.getFunctionRect(index))
        case "param":
            ctx.stroke(cardList.getParamRect(index))
        default:
            ctx.stroke(cardList.getFullRect(index))
        }

        ctx.translateBy(x: xTranslation, y: yTranslation)
        ctx.rotate(by: (rotation * CGFloat(CGFloat.pi / 180) * -1))
        ctx.translateBy(x: xTranslation * -1, y: yTranslation * -1)
}
    
    class func cropCard(image: UIImage, rect: CGRect, hexRect: CGRect, rotation: Double) -> UIImage {
        
        let rotationPoint = CGPoint(x: hexRect.midX, y: hexRect.midY)

        let angle = (CGFloat(rotation) * CGFloat(CGFloat.pi / 180) * -1)
        
        UIGraphicsBeginImageContext(rect.size)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.rotate(by: angle)

        var x = rect.minX;
        var y = rect.minY;
        
        let s = sin(angle * -1);
        let c = cos(angle * -1);
        
        x -= rotationPoint.x;
        y -= rotationPoint.y;
        
        let newX = (x * c - y * s) + rotationPoint.x;
        let newY = (x * s + y * c) + rotationPoint.y;
        
        image.draw(at: CGPoint(x: newX * -1, y: newY * -1))
        
        let modifiedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return modifiedImage!
        
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

