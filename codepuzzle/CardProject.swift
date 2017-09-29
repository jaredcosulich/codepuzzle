//
//  Project.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 8/21/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation
import CoreData

// This directive makes the class accessible to Objective-C code from the MagicalRecord library.
@objc(CardProject)

class CardProject: NSManagedObject {
    
    // Attributes
    @NSManaged var title: String
    
    // Relationships
    @NSManaged var parentClass: ParentClass

    @NSManaged var cardGroups: [CardGroup]
    
    var persistedManagedObjectContext: NSManagedObjectContext!
    
    func allCards() -> [Card] {
        var cards = [Card]()
        for cardGroup in cardGroups {
            cards += cardGroup.cards
        }
        return cards
    }

}


