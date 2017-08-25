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
    @NSManaged var imageFilename: String?
        
    weak var image: UIImage? {
        get {
            return ImageSaver.retrieve(filename: imageFilename!)
        }
        
        set {
            if imageFilename == nil {
                imageFilename = "\(cardProject.title)-\(cardGroupIndex())"
            }
            
            if newValue == nil {
                ImageSaver.delete(filename: imageFilename!)
            } else {
                _ = ImageSaver.save(image: newValue!, filename: imageFilename!)
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

    @NSManaged var processedImageFilename: String?

    weak var processedImage: UIImage? {
        get {
            return ImageSaver.retrieve(filename: processedImageFilename!)
        }
        
        set {
            if processedImageFilename == nil {
                processedImageFilename = "\(cardProject.title)-\(cardGroupIndex())Processed"
            }
            
            if newValue == nil {
                ImageSaver.delete(filename: processedImageFilename!)
            } else {
                _ = ImageSaver.save(image: newValue!, filename: processedImageFilename!)
            }
        }
    }

    // Relationships
    @NSManaged var cardProject: CardProject
    @NSManaged var cards: [Card]

    func cardGroupIndex() -> Int {
        for i in 0..<(cardProject.cardGroups.count) {
            if cardProject.cardGroups[i] == self {
                return i
            }
        }
        return -1
    }
    
    override func prepareForDeletion() {
        image = nil
        processedImage = nil
        
        super.prepareForDeletion()
    }

}
