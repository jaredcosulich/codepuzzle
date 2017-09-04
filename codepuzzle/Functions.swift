//
//  Functions.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 7/9/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation
import PaintBucket

class Functions {
    
    static let STARTING_ZOOM = CGFloat(10)
    
    static let functionInfo = [
        "A1": [
            "name": "Move Forward",
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
            "name": "Pen Size",
            "method": "penSize"
        ],
        "A8": [
            "name": "Pen Color",
            "method": "penColor"
        ],
        "A9": [
            "name": "Fill Color",
            "method": "fillColor"
        ],
        "F1": [
            "name": "Function",
            "method": "function"
        ],
        "F2": [
            "name": "End Function",
            "method": "endFunction"
        ],
        "L1": [
            "name": "Loop",
            "method": "loop"
        ],
        "L2": [
            "name": "End Loop",
            "method": "endLoop"
        ]
    ]

    let tempImageView = UIImageView()
    
    var scrollView: UIScrollView!
    var drawingRect: CGRect!
    
    var imageView: UIImageView!

    let layer = CAShapeLayer()
    
    var currentPoint = CGPoint(x: 0, y: 0)
    var currentAngle = CGFloat(90)
    
    var penIsDown = true
    
    var userDefinedFunctions = [CGFloat: [() -> Int]]()
    var currentUserDefinedFunction: CGFloat?
    
    var permanentPath = UIBezierPath()
    var scaledImage: UIImage!
    
    init(uiImageView: UIImageView, uiScrollView: UIScrollView) {
        imageView = uiImageView
        scrollView = uiScrollView
        drawingRect = scrollView.convert(scrollView.bounds, to: imageView)
        initDrawing()
    }
    
    func initDrawing() {
        imageView.image = nil
        imageView.layer.sublayers?.removeAll()
        let s = drawingRect.size
        currentPoint = CGPoint(x: drawingRect.minX + (s.width / 2), y: drawingRect.minY + (s.height / 2))
        currentAngle = CGFloat(90)
        
        initArrow()

        penIsDown = true
    }
    
    func reset() {
        userDefinedFunctions.removeAll()
        currentUserDefinedFunction = nil
        initDrawing()
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
        
        layer.position = currentPoint
        layer.path = path.cgPath
        layer.fillColor = UIColor.red.cgColor
        layer.fillRule = kCAFillRuleNonZero
        layer.lineCap = kCALineCapButt
        layer.lineDashPattern = nil
        layer.lineDashPhase = 0.0
        layer.lineJoin = kCALineJoinMiter
        layer.lineWidth = 2.0 / Functions.STARTING_ZOOM
        layer.miterLimit = 10.0
        layer.strokeColor = UIColor.red.cgColor
        
        imageView.layer.addSublayer(layer)
    }
    
    class func processedCode(code: String) -> String {
        return Functions.compactCode(code: Functions.translate(code: code))
    }
    
    class func translate(code: String) -> String {
        var translatedCode = code
        if code.characters.first == "4" {
            translatedCode = "A".appending(code.substring(from: code.index(code.startIndex, offsetBy: 1)))
        } else if code.characters.first == "9" {
            translatedCode = "A".appending(code.substring(from: code.index(code.startIndex, offsetBy: 1)))
        } else if code.characters.first == "1" {
            translatedCode = "L".appending(code.substring(from: code.index(code.startIndex, offsetBy: 1)))
        }

        switch (translatedCode) {
        case "A T":
            return "A 1"
        case "A B":
            return "A 6"
        case "All":
            return "A1"
        case "Al":
            return "A1"
        case "A41":
            return "A4"
        case "A^{1}":
            return "A1"
        default:
            return translatedCode
        }
    }
    
    class func compactCode(code: String) -> String {
        return code.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "‘", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: ":", with: "")
    }
    
    class func valid(code: String) -> Bool {
        if (code.characters.count == 0) {
            return false
        }
        
        return true
    }
    
    class func info(code: String) -> [String: String] {
        let function = Functions.functionInfo[Functions.processedCode(code: code)]
        if (function == nil) {
            print("NO FUNCTION: \(code)")
            return [
                "name": "N/A",
                "method": "n/a"
            ]
        } else {
            return function!
        }
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
        let xDistance = calculateXDistance(distance: distance, angle: angle) / Functions.STARTING_ZOOM
        let yDistance = calculateYDistance(distance: distance, angle: angle) / Functions.STARTING_ZOOM
        return CGPoint(x: from.x + xDistance, y: from.y + yDistance)
    }

    class func signature(code: String, param: String) -> String {
        let processedCode = Functions.processedCode(code: code)
        let translatedCode = Functions.translate(code: processedCode)
        return "\(Functions.info(code: translatedCode)["name"] ?? "Bad Function") \(Functions.translate(param: param))"
    }
    
    func drawPointer(at: CGPoint, angle: CGFloat) {
        layer.position = at
        let rotation = CGAffineTransform(rotationAngle: (angle - 90.0) * (CGFloat.pi / 180.0))
        layer.setAffineTransform(rotation)
    }
    
    class func translate(param: String) -> CGFloat {
        let translatedParam = param.replacingOccurrences(of: ">", with: "7")
            .replacingOccurrences(of: "$", with: "9")
            .replacingOccurrences(of: " ", with: "")

        return CGFloat((translatedParam as NSString).floatValue)
    }
        
    func execute(code: String, param: String, instant: Bool = false) -> Int {
        expandBounds(point: currentPoint)

        let paramNumber = Functions.translate(param: param)
        
        let processedCode = Functions.processedCode(code: code)
        let methodName = Functions.info(code: Functions.translate(code: processedCode))["method"] ?? ""

        if (currentUserDefinedFunction != nil) {
            if (methodName == "endFunction") {
                currentUserDefinedFunction = nil
            } else {
                userDefinedFunctions[currentUserDefinedFunction!]!.append({
                    return self.execute(code: code, param: param, instant: true)
                })
            }
            return 0
        }
        
        var nextPoint = currentPoint
        var fill = false
        var fillColor = UIColor.black.cgColor
        
        switch methodName {
        case "moveForward":
            nextPoint = calculatePoint(from: currentPoint, distance: paramNumber, angle: currentAngle)
        case "moveBackward":
            nextPoint = calculatePoint(from: currentPoint, distance: paramNumber * -1, angle: currentAngle)
        case "rotateRight":
            currentAngle += paramNumber
        case "rotateLeft":
            currentAngle -= paramNumber
        case "penUp":
            penIsDown = false
        case "penDown":
            penIsDown = true
        case "fillColor":
            fillColor = UIColor(displayP3Red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
            fill = true
        case "loop":
            return Int(paramNumber)
        case "endLoop":
            return -1
        case "function":
            let functionSteps = userDefinedFunctions[paramNumber]
            if (functionSteps != nil) {
                var loops = [Loop]()
                var index = -1
                while index < functionSteps!.count - 1 {
                    index += 1
                    let loopCount = functionSteps![index]()
                    if loopCount > 0 {
                        loops.append(Loop(startingIndex: index, count: loopCount))
                    } else if loopCount < 0 {
                        let loopIndex = loops.last!.increment()
                        if loopIndex == -1 {
                            _ = loops.popLast()
                        } else {
                            index = loopIndex
                        }
                    }
                }
            } else {
                userDefinedFunctions[paramNumber] = [() -> Int]()
                currentUserDefinedFunction = paramNumber
            }
            return 0
        default:
            print("Method Not Found")
        }
        
        drawPointer(at: nextPoint, angle: currentAngle)

        
        if (penIsDown) {
            if (currentPoint != nextPoint) {
                let pathLayer = CAShapeLayer()
                pathLayer.fillColor = fillColor
                pathLayer.strokeColor = UIColor.black.cgColor
                pathLayer.lineWidth = (1.0 / Functions.STARTING_ZOOM)
                
                let path = UIBezierPath()
                path.move(to: currentPoint)
                path.addLine(to: nextPoint)
                pathLayer.path = path.cgPath
                
                permanentPath.move(to: currentPoint)
                permanentPath.addLine(to: nextPoint)

                imageView.layer.addSublayer(pathLayer)
                
                if (!instant) {
                    let animation = CABasicAnimation(keyPath: "strokeEnd")
                    animation.fromValue = 0
                    animation.duration = 0.2
                    pathLayer.add(animation, forKey: "pathAnimation")
                }
            }

            if (fill) {
                layer.isHidden = true

                scrollView.zoomScale = 1.0
                let scaleTransform = CGAffineTransform(scaleX: CGFloat(Functions.STARTING_ZOOM), y: CGFloat(Functions.STARTING_ZOOM))
                let size = imageView.bounds.size.applying(scaleTransform)
                UIGraphicsBeginImageContextWithOptions(size, imageView.layer.isOpaque, 0)
                let context = UIGraphicsGetCurrentContext()!
                
                if (scaledImage != nil) {
                    scaledImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                }
                
                permanentPath.apply(scaleTransform)
                context.addPath(permanentPath.cgPath)
                permanentPath.stroke()
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                let pX = Int(currentPoint.x * 2 * Functions.STARTING_ZOOM)
                let pY = Int(currentPoint.y * 2 * Functions.STARTING_ZOOM)
                
                let coloredImage = image!.pbk_imageByReplacingColorAt(pX, pY, withColor: UIColor.red, tolerance: 5, antialias: true)
                
                scaledImage = coloredImage
                permanentPath = UIBezierPath()
                
                imageView.layer.sublayers?.removeAll()
                imageView.image = coloredImage
                
                scrollView.zoom(to: drawingRect, animated: false)
                layer.isHidden = false
                
//                imageView.image = OpenCVWrapper.floodFill(image, Int32(currentPoint.x), Int32(currentPoint.y), 255, 0, 0)
            }
            
        }
        
        currentPoint = nextPoint
        expandBounds(point: currentPoint)
        return 0
    }
    
    func expandBounds(point: CGPoint) {
        if (scrollView.zoomScale <= 0.5) {
            return
        }
       
        if drawingRect.contains(point) {
            return
        }
        
        let buffer = 50 / scrollView.zoomScale
        
        if (point.x < drawingRect.minX) {
            drawingRect = drawingRect.insetBy(dx: (point.x - drawingRect.minX) - buffer, dy: 0)
        }
        
        if (point.x > drawingRect.maxX) {
            drawingRect = drawingRect.insetBy(dx: (drawingRect.maxX - point.x) - buffer, dy: 0)
        }
        
        if (point.x < drawingRect.minY) {
            drawingRect = drawingRect.insetBy(dx: 0, dy: (point.y - drawingRect.minY) - buffer)
        }
        
        if (point.y > drawingRect.maxY) {
            drawingRect = drawingRect.insetBy(dx: 0, dy: (drawingRect.maxY - point.y) - buffer)
        }
        
        scrollView.zoom(to: drawingRect, animated: true)
    }
}

