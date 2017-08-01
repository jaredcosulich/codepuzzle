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

    let layer = CAShapeLayer()
    
    var currentPoint = CGPoint(x: 0.0, y: 0.0)
    var currentAngle = CGFloat(90.0)
    
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
        
        initArrow()
    }
    
    func initArrow() {
        layer.isGeometryFlipped = false
        layer.opacity = 1.0
        layer.isHidden = false

        let path = UIBezierPath()
        let startingPoint = CGPoint(x: 0, y: 0)
        var angle = CGFloat(90.0)
        
        let point1 = calculatePoint(from: startingPoint, distance: 5.543, angle: angle)
        
        path.move(to: point1)

        angle = angle + (180 - 22.5)
        
        let point2 = calculatePoint(from: point1, distance: 6, angle: angle)
        
        path.addLine(to: point2)
        
        angle = angle + (90 + 22.5)
        
        let point3 = calculatePoint(from: point2, distance: 4.592, angle: angle)
        
        path.addLine(to: point3)

        path.close()
        
        path.stroke()
        
        layer.path = path.cgPath
        layer.opacity = 0.0
        layer.fillColor = UIColor.red.cgColor
        layer.fillRule = kCAFillRuleNonZero
        layer.lineCap = kCALineCapButt
        layer.lineDashPattern = nil
        layer.lineDashPhase = 0.0
        layer.lineJoin = kCALineJoinMiter
        layer.lineWidth = 1.0
        layer.miterLimit = 10.0
        layer.strokeColor = UIColor.red.cgColor
        
        imageView.layer.addSublayer(layer)
    }
    
    func translate(code: String) -> String {
        switch (code) {
        case "A T":
            return "A 1"
        default:
            return code
        }
    }
    
    func info(code: String) -> [String: String] {
        return functionInfo[compactCode(code: translate(code: code))]!
    }
    
    func compactCode(code: String) -> String {
        var compactCode = code
        compactCode.remove(at: code.index(code.endIndex, offsetBy: -2))
        return compactCode
    }
    
    func calculateXDistance(distance: CGFloat, angle: CGFloat) -> CGFloat {
        let adjustedAngle = angle.truncatingRemainder(dividingBy: 360)

        if (adjustedAngle == 90.0 || adjustedAngle == 270.0) {
            return 0
        } else if (adjustedAngle == 0.0) {
            return distance * -1
        } else if (adjustedAngle == 180.0) {
            return distance
        }
        
        return cos(adjustedAngle * (CGFloat.pi / 180.0)) * distance * -1
    }

    func calculateYDistance(distance: CGFloat, angle: CGFloat) -> CGFloat {
        let adjustedAngle = angle.truncatingRemainder(dividingBy: 360)
        
        if (adjustedAngle == 0.0 || adjustedAngle == 180.0) {
            return 0
        } else if (adjustedAngle == 270.0) {
            return distance
        } else if (adjustedAngle == 90.0) {
            return distance * -1
        }

        return sin(adjustedAngle * (CGFloat.pi / 180.0)) * distance * -1
    }
    
    func calculatePoint(from: CGPoint, distance: CGFloat, angle: CGFloat) -> CGPoint {
        let xDistance = calculateXDistance(distance: distance, angle: angle)
        let yDistance = calculateYDistance(distance: distance, angle: angle)
        return CGPoint(x: from.x + xDistance, y: from.y + yDistance)
    }

    func signature(code: String, param: String) -> String {
//        let regex = NSRegularExpression(pattern: "[\\s]+", optionparam:nil, error: nil)
//        let compactCode = regex!.stringByReplacingMatchesInString(code, optionparam: nil, range: NSMakeRange(0, count(code)), withTemplate: nil)
    
        return "\(info(code: translate(code: code))["name"] ?? "Bad Function") \(param)"
    }
    
    func drawPointer() {
        layer.opacity = 1.0
        layer.position = currentPoint
        let rotation = CGAffineTransform(rotationAngle: (currentAngle - 90.0) * (CGFloat.pi / 180.0))
        layer.setAffineTransform(rotation)
    }
    
    func execute(code: String, param: String) {
        UIGraphicsBeginImageContext(imageView.frame.size)
        imageView.image?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.width, height: imageView.frame.height))
        let context = UIGraphicsGetCurrentContext()
        
        context?.move(to: currentPoint)

        let paramNumber = CGFloat((param as NSString).floatValue)

        let methodName = info(code: translate(code: code))["method"] ?? ""

        var nextPoint = currentPoint
        
        switch methodName {
        case "moveForward":
            nextPoint = calculatePoint(from: currentPoint, distance: paramNumber, angle: currentAngle)
            context?.addLine(to: nextPoint)
        case "moveBackward":
            nextPoint = calculatePoint(from: currentPoint, distance: paramNumber * -1, angle: currentAngle)
            context?.addLine(to: nextPoint)
        case "rotateRight":
//            print("ROTATE RIGHT: \(currentAngle) - \(paramNumber) = \(currentAngle - paramNumber)")
            currentAngle += paramNumber
        case "rotateLeft":
//            print("ROTATE Left: \(currentAngle) + \(paramNumber) = \(currentAngle + paramNumber)")
            currentAngle -= paramNumber
        case "penUp":
            penIsUp = true
        case "penDown":
            penIsUp = false
        default:
            print("Method Not Found")
        }
        
        currentPoint = nextPoint

        drawPointer()
        
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(1)
        context?.setStrokeColor(UIColor.black.cgColor)
        
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

