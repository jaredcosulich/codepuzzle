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
    
    let domain = "https://2ed47c7b.ngrok.io" // "https://www.puzzleschool.com"
    
    var results = [String: String?]()
    
    init() {}
    
    func getValue(identifier: String) -> String? {
        return results[identifier]!
    }
    
    func processing(identifier: String) -> Bool {
        return !results.keys.contains(identifier)
    }
    
    func getClassName(slug: String) {
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
                self.results[slug] = (json as! NSDictionary)["name"] as? String
            }
        }
    }
    
    
    func saveProject(cardProject: CardProject) {
        let parameters : Parameters = [
            "class": cardProject.parentClass.slug,
            "title": cardProject.title
        ]
        
        Alamofire.request(
            "https://www.puzzleschool.com/code_puzzle_projects",
            method: .post,
            parameters : parameters,
            encoding: JSONEncoding.default,
            headers: [
                "app_id" : "puzzleschool",
                "app_key" : "a5f0c88b21f281282fce1adfa9609aaf"
            ]
        ).responseJSON { response in
            if (response.error != nil) { print("Error: \(response.error ?? "No Error" as! Error)") }
            
//            if let json = response.result.value {
//                let value = (json as! NSDictionary)["latex"] as? String
//                self.results[identifier] = value ?? "No Value"
//            }
        }
    }
}
