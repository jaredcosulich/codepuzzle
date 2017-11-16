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
    
    let domain = "https://www.puzzleschool.com" //"https://4a3ad6da.ngrok.io"//
    
    var results = [String: String?]()
    
    init() {}
    
    func getValue(identifier: String) -> String? {
        if results.keys.contains(identifier) && results[identifier]! == "N/A" {
            return nil
        }
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
                self.results[identifier] = "N/A"
                print("IDENTIFIER: \(identifier) = \(self.results.keys.contains(identifier))")
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
        
        let parameters : [String:Parameters] = [
            "code_puzzle_project": ["title": title]
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
                let id = (json as! NSDictionary)["id"] as? Int
                self.results[identifier] = "\(id!)"
            }
        }
        return identifier
    }
    
    func saveGroup(cardProject: CardProject, imageUrl: URL) -> String {
        let parentClass = cardProject.parentClass!
        let identifier = "\(parentClass.slug)\(cardProject.title)\(cardProject.cardGroups.count)\(Date().timeIntervalSince1970)"
        
        let parameters : [String:Parameters] = [
            "code_puzzle_group": [
                "photo_url": imageUrl.absoluteString,
                "position": cardProject.cardGroups.count - 1
            ]
        ]
        
        Alamofire.request(
            "\(domain)/code_puzzle_classes/\(parentClass.slug)/code_puzzle_projects/\(cardProject.id!)/code_puzzle_groups",
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
                let id = (json as! NSDictionary)["id"] as? Int
                self.results[identifier] = "\(id!)"
            }
        }
        
        return identifier
    }

    func saveCard(cardGroup: CardGroup, imageUrl: URL, position: Int, code: String, param: String) -> String {
        return saveCard(cardGroup: cardGroup, imageUrl: imageUrl, position: position, code: code, param: param, id: nil)
    }

    func saveCard(cardGroup: CardGroup, imageUrl: URL, position: Int, code: String, param: String, id: String?) -> String {
        let cardProject = cardGroup.cardProject
        let parentClass = cardProject.parentClass!
        
        var relativePosition = position
        for group in cardProject.cardGroups {
            if (group == cardGroup) {
                break
            }
            relativePosition += group.cards.count
        }
        
        let identifier = "\(parentClass.slug)\(cardProject.id)\(cardGroup.id)\(relativePosition)\(Date().timeIntervalSince1970)"
        
        let parameters : [String:Parameters] = [
            "code_puzzle_card": [
                "photo_url": imageUrl.absoluteString,
                "position": "\(relativePosition)",
                "code": code,
                "param": param,
                "id": id ?? ""
            ]
        ]
        
        Alamofire.request(
            "\(domain)/code_puzzle_classes/\(parentClass.slug)/code_puzzle_projects/\(cardProject.id!)/code_puzzle_groups/\(cardGroup.id!)/code_puzzle_cards",
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
                let id = (json as! NSDictionary)["id"] as? Int
                self.results[identifier] = "\(id!)"
            }
        }
        return identifier
    }
}
