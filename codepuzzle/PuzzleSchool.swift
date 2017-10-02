//
//  PuzzleSchool.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 9/28/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation
import Alamofire

class PuzzleSchool {
    
    let domain = "https://3c1766b5.ngrok.io" // "https://www.puzzleschool.com"
    
    var results = [String: String?]()
    
    init() {}
    
    func getValue(identifier: String) -> String? {
        return results[identifier]!
    }
    
    func processing(identifier: String) -> Bool {
        return !results.keys.contains(identifier)
    }
    
    func getClassName(slug: String) -> String {
        let identifier = "ParentClass\(slug)\(Date().timeIntervalSince1970)"

        Alamofire.request(
            "\(domain)/code_puzzle_classes/\(slug)",
            method: .get,
            encoding: JSONEncoding.default,
            headers: [
                "Accept": "application/json"
            ]
        ).responseJSON { response in
            if (response.error != nil) {
                self.results[slug] = nil
                print("Error: \(response.error ?? "No Error" as! Error)")
            }
            
            if let json = response.result.value {
                self.results[identifier] = (json as! NSDictionary)["name"] as? String
            }
        }
        return identifier
    }
    
    
    func saveProject(parentClass: ParentClass, title: String) -> String {
        let identifier = "\(parentClass.slug)\(title)\(Date().timeIntervalSince1970)"
        
        let parameters : Parameters = [
            "code_puzzle_project[title]": title
        ]
        
        Alamofire.request(
            "\(domain)/code_puzzle_classes/\(parentClass.slug)/code_puzzle_projects",
            method: .post,
            parameters : parameters,
            encoding: JSONEncoding.default,
            headers: [
                "Accept": "application/json"
            ]
        ).responseJSON { response in
            if (response.error != nil) { print("Error: \(response.error ?? "No Error" as! Error)") }
            
            if let json = response.result.value {
                print("JSON: \(json)")
                let id = (json as! NSDictionary)["id"] as? String
                self.results[identifier] = id ?? "No Value"
            }
        }
        return identifier
    }
}
