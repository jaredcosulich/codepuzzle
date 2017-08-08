//
//  Project.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 8/7/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation
import CoreData

class ProjectLoader {

    let appDelegate: AppDelegate!
    
    let managedObjectContext: NSManagedObjectContext!
    
    var projects = [CodeProject]()
    var projectDatas = [NSManagedObject]()
 
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        
        managedObjectContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CodeProjectData")
        
        do {
            // Execute Fetch Request
            let records = try managedObjectContext.fetch(fetchRequest)
            
            if let records = records as? [NSManagedObject] {
                projectDatas = records
            }
            
        } catch {
            print("Unable to fetch CodeProjects.")
        }
    }

    func save() {
        for project in projects {
            project.save(managedObjectContext: managedObjectContext)
        }
    }
    
    func addProject(title: String) -> CodeProject {
        let project = CodeProject(title: title)
        projects.append(project)
        save()
        return project
    }
    
}

class CodeProject {
    
    var title: String!
    
    init(title: String) {
        self.title = title
    }
    
    func save(managedObjectContext: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "CodeProjectData", in: managedObjectContext)
        
        let codeProjectData = CodeProjectData(entity: entity!, insertInto: managedObjectContext)
        
        codeProjectData.setValue(title, forKeyPath: "title")
        
        do {
            try managedObjectContext.save()
            print("Saved Project: \(title)")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }

    }
    
}


class Card {
    
    var code: String!
    var param: String!
    var image: UIImage!
    
    var originalCode: String!
    var originalParam: String!
    var originalImage: UIImage!
    
    init(code: String, param: String, image: UIImage, originalCode: String, originalParam: String, originalImage: UIImage) {
        self.code = code
        self.param = param
        self.image = image
        
        self.originalCode = originalCode
        self.originalParam = originalParam
        self.originalImage = originalImage
    }
    
    func save(managedContext: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "CardData", in: managedContext)
        
        let cardData = CardData(entity: entity!, insertInto: managedContext)
        
        cardData.setValue(code, forKeyPath: "code")
        cardData.setValue(param, forKeyPath: "param")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
}

