//
//  CardGroup.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 8/21/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation
import CoreData

// This directive makes the class accessible to Objective-C code from the MagicalRecord library.
@objc(CardGroup)

class CardGroup: NSManagedObject {
    
    // Attributes
    @NSManaged var imageFilename: NSString
        
    var image: UIImage {
        get {
            return ImageSaver.retrieve(filename: String(imageFilename))
        }
        
        set {
            let filename = "\(cardProject.title)-\(cardGroupIndex())"
            if ImageSaver.save(image: newValue, filename: filename) {
                self.imageFilename = NSString(string: filename)
            }
        }
    }

    @NSManaged var processed: NSNumber
    
    var isProcessed: Bool {
        get {
            return Bool(processed)
        }
        set {
            processed = NSNumber(value: newValue)
        }
    }

    @NSManaged var processedImageFilename: NSString?

    var processedImage: UIImage? {
        get {
            return ImageSaver.retrieve(filename: String(imageFilename))
        }
        
        set {
            let filename = "\(cardProject.title)-\(cardGroupIndex())Processed"
            if ImageSaver.save(image: newValue!, filename: filename) {
                imageFilename = NSString(string: filename)
            }
        }
    }

    // Relationships
    @NSManaged var cardProject: CardProject
    @NSManaged var cards: [Card]

    func cardGroupIndex() -> Int {
        for i in 0..<cardProject.cardGroups.count {
            if cardProject.cardGroups[i] == self {
                return i
            }
        }
        return -1
    }    
}
