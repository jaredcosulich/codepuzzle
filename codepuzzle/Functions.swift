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
    
    func signature(code: String, param: String) -> String {
//        let regex = NSRegularExpression(pattern: "[\\s]+", options:nil, error: nil)
//        let compactCode = regex!.stringByReplacingMatchesInString(code, options: nil, range: NSMakeRange(0, count(code)), withTemplate: nil)
    
        var compactCode = code;
        compactCode.remove(at: code.index(code.endIndex, offsetBy: -2))
        print("COMPACT CODE: \(compactCode)")

        var info = functionInfo[compactCode]

        let name = Selector((info?["method"]!)!) // e.g. from somewhere else
        if let method = extractMethodFrom(owner: self, selector: name) {
            let result = method("test")
            print("RESULT: \(result)")
        }

        return "\(info!["name"] ?? "Bad Function") \(param)"
    }
    
    func extractMethodFrom(owner: AnyObject, selector: Selector) -> ((String) -> String)? {
        print("EXTRACTING: \(selector)")
        let method: Method
        if owner is AnyClass {
            method = class_getClassMethod(owner as! AnyClass, selector)
        } else {
            method = class_getInstanceMethod(type(of: owner), selector)
        }
        
//        guard method != nil else {
//            return nil
//        }
        
        let implementation = method_getImplementation(method)
        
        typealias Function = @convention(c) (AnyObject, Selector, String) -> Unmanaged<AnyObject>
        let function = unsafeBitCast(implementation, to: Function.self)
        
        return { string in (function(owner, selector, string).takeUnretainedValue() as! String) }
    }
    
    @objc func moveForward(s: String) -> String {
        return "Move Forward"
    }

    @objc func moveBackward(s: String) -> String {
        return "Move Backward"
    }

    @objc func rotateRight(s: String) -> String {
        return "Rotate Right"
    }

    @objc func rotateLeft(s: String) -> String {
        return "Rotate Left"
    }

    @objc func penUp(s: String) -> String {
        return "Pan Up"
    }
    
    @objc func penDown(s: String) -> String {
        return "Pan Down"
    }


}

