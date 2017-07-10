//
//  Functions.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 7/9/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation

class Functions {
    
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
    
    init() {}
    
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
        let methodName = info(code: code)["method"] ?? ""
        switch methodName {
        case "moveForward":
            moveForward(param: param)
        case "moveBackward":
            moveBackward(param: param)
        case "rotateRight":
            rotateRight(param: param)
        case "rotateLeft":
            rotateLeft(param: param)
        case "penUp":
            penUp(param: param)
        case "penDown":
            penDown(param: param)
        default:
            print("Method Not Found")
        }
    }
    
    func moveForward(param: String) {
        print("Move Forward \(param)")
    }

    func moveBackward(param: String) {
        print("Move Backward \(param)")
    }

    func rotateRight(param: String) {
        print("Rotate Right \(param)")
    }

    func rotateLeft(param: String) {
        print("Rotate Left \(param)")
    }

    func penUp(param: String) {
        print("Pan Up \(param)")
    }
    
    func penDown(param: String) {
        print("Pan Down \(param)")
    }


}

