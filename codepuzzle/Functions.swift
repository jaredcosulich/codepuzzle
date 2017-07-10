//
//  Functions.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 7/9/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation

class Functions {
    
    let tempImageView = UIImageView()
    
    var imageView: UIImageView
    
    var currentPoint = CGPoint(x: 0.0, y: 0.0)
    var currentAngle = CGFloat(0)
    
    var penIsUp = false
    
    let functionInfo = [
        "A1": [
            "name": "Move Foward",
            "method": "moveForward"
        ],
        "A2": [
            "name": "Move Backward",
            "method": "moveBackward"
        ],
        "A3": [
            "name": "Rotate Right",
            "method": "rotateRight"
        ],
        "A4": [
            "name": "Rotate Left",
            "method": "rotateLeft"
        ],
        "A5": [
            "name": "Pen Up",
            "method": "penUp"
        ],
        "A6": [
            "name": "Pen Down",
            "method": "penDown"
        ],
        "A7": [
            "name": "Move To",
            "method": "moveTo"
        ]
    ]
    
    init(uiImageView: UIImageView) {
        imageView = uiImageView;
        let s = imageView.bounds.size
        currentPoint = CGPoint(x: s.width / 5.0, y: s.height)
    }
    
    func info(code: String) -> [String: String] {
        return functionInfo[compactCode(code: code)]!
    }
    
    func compactCode(code: String) -> String {
        var compactCode = code
        compactCode.remove(at: code.index(code.endIndex, offsetBy: -2))
        return compactCode
    }
    
    func signature(code: String, param: String) -> String {
//        let regex = NSRegularExpression(pattern: "[\\s]+", optionparam:nil, error: nil)
//        let compactCode = regex!.stringByReplacingMatchesInString(code, optionparam: nil, range: NSMakeRange(0, count(code)), withTemplate: nil)
    
        return "\(info(code: code)["name"] ?? "Bad Function") \(param)"
    }
    
    func execute(code: String, param: String) {
        
        UIGraphicsBeginImageContext(imageView.frame.size)
        imageView.image?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.width, height: imageView.frame.height))
        let context = UIGraphicsGetCurrentContext()
        
        context?.move(to: currentPoint)

        let paramNumber = CGFloat((param as NSString).floatValue)

        let methodName = info(code: code)["method"] ?? ""

        var toPoint = currentPoint
        
        switch methodName {
        case "moveForward":
            let xDistance = paramNumber * (cos(currentAngle))
            let yDistance = paramNumber * (sin(currentAngle))
            toPoint = CGPoint(x: currentPoint.x + xDistance, y: currentPoint.y - yDistance)
            context?.addLines(between: [currentPoint, toPoint])
        case "moveBackward":
            let xDistance = paramNumber * (cos(currentAngle))
            let yDistance = paramNumber * (sin(currentAngle))
            toPoint = CGPoint(x: currentPoint.x - xDistance, y: currentPoint.y + yDistance)
            context?.addLine(to: toPoint)
        case "rotateRight":
            currentAngle += paramNumber
        case "rotateLeft":
            currentAngle -= paramNumber
        case "penUp":
            penIsUp = true
        case "penDown":
            penIsUp = false
        default:
            print("Method Not Found")
        }
        
        currentPoint = toPoint
        
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(2)
        context?.setStrokeColor(UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor)
        
        context?.strokePath()
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        
        
        
        
        
//        UIGraphicsBeginImageContext(imageView.frame.size)
//        let context = UIGraphicsGetCurrentContext()
//        imageView.image?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.size.width , height: imageView.frame.size.height))
////        tempImageView.image?.draw(in: CGRect(x: 20, y: 0, width: imageView.frame.size.width - 40, height: imageView.frame.size.height))
//        
//        context?.setLineCap(CGLineCap.round)
//        context?.setLineWidth(3.0)
//        context?.setStrokeColor(red: 200.0, green: 0.0, blue: 0.0, alpha: 1.0)
//        context?.setBlendMode(CGBlendMode.normal)
//
////        context?.move(to: currentPoint)
//
//        context?.beginPath()
//
//        let paramNumber = CGFloat((param as NSString).floatValue)
//        
//        let methodName = info(code: code)["method"] ?? ""
//        switch methodName {
//        case "moveForward":
//            let toPoint = CGPoint(x: currentPoint.x, y: currentPoint.y + paramNumber)
//            context?.addLines(between: [currentPoint, toPoint])
//        case "moveBackward":
//            let toPoint = CGPoint(x: currentPoint.x, y: currentPoint.y + paramNumber)
//            context?.addLine(to: toPoint)
//        case "rotateRight":
//            let toPoint = CGPoint(x: currentPoint.x, y: currentPoint.y + paramNumber)
//            context?.addLine(to: toPoint)
//        case "rotateLeft":
//            let toPoint = CGPoint(x: currentPoint.x, y: currentPoint.y + paramNumber)
//            context?.addLine(to: toPoint)
//        case "penUp":
//            let toPoint = CGPoint(x: currentPoint.x, y: currentPoint.y + paramNumber)
//            context?.addLine(to: toPoint)
//        case "penDown":
//            let toPoint = CGPoint(x: currentPoint.x, y: currentPoint.y + paramNumber)
//            context?.addLine(to: toPoint)
//        default:
//            print("Method Not Found")
//        }
//        
//        context?.closePath()
//        // 4
//        context?.strokePath()
//        
//        context?.replacePathWithStrokedPath()
//
//        UIGraphicsEndImageContext()
//
//        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
//        imageView.alpha = 1
//        
////        // 5
////        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
////        tempImageView.alpha = 1
////        UIGraphicsEndImageContext()
////        
////        UIGraphicsBeginImageContext(imageView.frame.size)
////        imageView.image?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
////        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height), blendMode: CGBlendMode.normal, alpha: 1.0)
////        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
////        UIGraphicsEndImageContext()
////
////        tempImageView.image = nil
    }


}

