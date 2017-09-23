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
    
    @NSManaged var manual: Bool
    @NSManaged var error: Bool

    @NSManaged var imageFilename: String?
    weak var image: UIImage? {
        get {
            return ImageSaver.retrieve(filename: imageFilename!)
        }
        
        set {
            if imageFilename == nil {
                imageFilename = "\(cardGroup.cardProject.title)-\(cardGroup.cardGroupIndex())-\(cardIndex())"
            }
            
            if newValue == nil {
                ImageSaver.delete(filename: imageFilename!)
            } else {
                _ = ImageSaver.save(image: newValue!, filename: imageFilename!)
            }
        }
    }
    
    @NSManaged var code: String
    @NSManaged var param: String
    
    @NSManaged var originalImageFilename: String?
    weak var originalImage: UIImage? {
        get {
            if (originalImageFilename == nil) {
                originalImageFilename = imageFilename
            }
            return ImageSaver.retrieve(filename: originalImageFilename!)
        }
        
        set {
            if (originalImageFilename == nil && newValue == nil) {
                return
            } else if originalImageFilename == nil {
                originalImageFilename = "\(cardGroup.cardProject.title)-\(cardGroup.cardGroupIndex())-\(cardIndex())Original"
            }
            
            if newValue == nil {
                ImageSaver.delete(filename: originalImageFilename!)
            } else {
                _ = ImageSaver.save(image: newValue!, filename: originalImageFilename!)
            }
        }
    }
    
    @NSManaged var originalCode: String?
    @NSManaged var originalParam: String?
    
    @NSManaged var disabled: Bool

    
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
    
    override func prepareForDeletion() {
        image = nil
        originalImage = nil
        
        super.prepareForDeletion()
    }
    
}
