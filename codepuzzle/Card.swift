//
//  Card.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 8/21/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation
import CoreData

// This directive makes the class accessible to Objective-C code from the MagicalRecord library.
@objc(Card)

class Card: NSManagedObject {
    
    // Attributes
    @NSManaged var imageFilename: String
    var image: UIImage {
        get {
            return ImageSaver.retrieve(filename: imageFilename)
        }
        
        set {
            let filename = "\(cardGroup.cardProject.title)-\(cardGroup.cardGroupIndex())-\(cardIndex())"
            if ImageSaver.save(image: newValue, filename: filename) {
                imageFilename = filename
            }
        }
    }
    
    @NSManaged var code: String
    @NSManaged var param: String
    
    @NSManaged var originalImageFilename: String
    var originalImage: UIImage {
        get {
            return ImageSaver.retrieve(filename: originalImageFilename)
        }
        
        set {
            let filename = "\(cardGroup.cardProject.title)-\(cardGroup.cardGroupIndex())-\(cardIndex())Original"
            if ImageSaver.save(image: newValue, filename: filename) {
                originalImageFilename = filename
            }
        }
    }

    
    @NSManaged var originalCode: String
    @NSManaged var originalParam: String
    
    // Relationships
    @NSManaged var cardGroup: CardGroup
    
    func cardIndex() -> Int {
        for i in 0..<cardGroup.cards.count {
            if cardGroup.cards[i] == self {
                return i
            }
        }
        return -1
    }
    
}
