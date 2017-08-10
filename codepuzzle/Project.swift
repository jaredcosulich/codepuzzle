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
    
    var cardProjects = [CardProject]()
 
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        
        managedObjectContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CardProjectData")
        
        do {
            // Execute Fetch Request
            let records = try managedObjectContext.fetch(fetchRequest)

            if let records = records as? [CardProjectData] {
                for cardProjectData in records {
                    cardProjects.append(CardProject(cardProjectData: cardProjectData, managedObjectContext: managedObjectContext))
                }
            }
            
        } catch {
            print("Unable to fetch CardProjects.")
        }
    }

    func save() {
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func addCardProject(title: String) -> CardProject {
        let entity = NSEntityDescription.entity(forEntityName: "CardProjectData", in: managedObjectContext)
        let cardProjectData = CardProjectData(entity: entity!, insertInto: managedObjectContext)
        
        let cardProject = CardProject(cardProjectData: cardProjectData, managedObjectContext: managedObjectContext)
        
        cardProject.title = title
        
        cardProjects.append(cardProject)
        save()
        return cardProject
    }
    
    func delete(at: Int) {
        cardProjects[at].delete()
        cardProjects.remove(at: at)
    }
    
}

class CardProject {
    
    var managedObjectContext: NSManagedObjectContext!
    
    var cardProjectData: CardProjectData!
    
    var title: String {
        get {
            return (cardProjectData.title ?? "N/A")
        }
        
        set {
            cardProjectData.title = newValue
        }
    }

    var cardGroups = [CardGroup]()
    
    init(cardProjectData: CardProjectData, managedObjectContext: NSManagedObjectContext) {
        self.cardProjectData = cardProjectData
        self.managedObjectContext = managedObjectContext
        
        for cardGroupData in cardProjectData.cardGroups! {
            cardGroups.append(CardGroup(cardGroupData: cardGroupData as! CardGroupData, managedObjectContext: managedObjectContext))
        }
        
    }
    
    func save() {
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func delete() {
        managedObjectContext.delete(cardProjectData)
        save()
    }
    
    func addCardGroup(image: UIImage) -> CardGroup {
        let entity = NSEntityDescription.entity(forEntityName: "CardGroupData", in: managedObjectContext)
        let cardGroupData = CardGroupData(entity: entity!, insertInto: managedObjectContext)
        
        let cardGroup = CardGroup(cardGroupData: cardGroupData, managedObjectContext: managedObjectContext)
        
        cardGroup.image = image
        
        cardProjectData.addToCardGroups(cardGroup.cardGroupData)
        cardGroups.append(cardGroup)
        save()
        return cardGroup
    }
    
    func deleteCardGroup(at: Int) {
        cardGroups[at].delete()
        cardGroups.remove(at: at)
    }
    
    func allCards() -> [Card] {
        var cards = [Card]()
        for cardGroup in cardGroups {
            cards += cardGroup.cards
        }
        return cards
    }

    
}

class CardGroup {
    
    var cardGroupData: CardGroupData
    
    var managedObjectContext: NSManagedObjectContext!
    
    var processed: Bool {
        get {
            return cardGroupData.processed
        }
        set {
            cardGroupData.processed = newValue
        }
    }
    
    var image: UIImage {
        get {
            return UIImage(data: cardGroupData.image! as Data)!
        }
        
        set {
            cardGroupData.image = UIImagePNGRepresentation(newValue)! as NSData
        }
    }
    
    var cards = [Card]()
    
    init(cardGroupData: CardGroupData, managedObjectContext: NSManagedObjectContext) {
        self.cardGroupData = cardGroupData
        self.managedObjectContext = managedObjectContext
        
        for cardData in cardGroupData.cards! {
            cards.append(Card(cardData: cardData as! CardData))
        }
    }
    
    func delete() {
        managedObjectContext.delete(cardGroupData)
        save()
    }
    
    func save() {
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func addCard(code: String, param: String, image: UIImage, originalCode: String, originalParam: String, originalImage: UIImage) -> Card {
        let entity = NSEntityDescription.entity(forEntityName: "CardData", in: managedObjectContext)
        let cardData = CardData(entity: entity!, insertInto: managedObjectContext)
        
        let card = Card(cardData: cardData)
        
        card.code = code
        card.param = param
        card.image = image

        card.originalCode = originalCode
        card.originalParam = originalParam
        card.originalImage = originalImage

        cardGroupData.addToCards(card.cardData)
        cards.append(card)
        save()
        return card
    }
    
}


class Card {
    
    var cardData: CardData!
    
    var code: String {
        get {
            return cardData.code!
        }
        set {
            cardData.code = newValue
        }
    }

    var param: String {
        get {
            return cardData.param!
        }
        set {
            cardData.param = newValue
        }
    }

    var image: UIImage {
        get {
            return UIImage(data: cardData.image! as Data)!
        }
        set {
            cardData.image = UIImagePNGRepresentation(newValue)! as NSData
        }
    }

    var originalCode: String {
        get {
            return cardData.code!
        }
        set {
            cardData.code = newValue
        }
    }
    
    var originalParam: String {
        get {
            return cardData.param!
        }
        set {
            cardData.param = newValue
        }
    }
    
    var originalImage: UIImage {
        get {
            return UIImage(data: cardData.image! as Data)!
        }
        set {
            cardData.image = UIImagePNGRepresentation(newValue)! as NSData
        }
    }
    
    init(cardData: CardData) {
        self.cardData = cardData
    }

}

