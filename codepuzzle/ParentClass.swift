//
//  ParentClass.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 9/28/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation
import CoreData

// This directive makes the class accessible to Objective-C code from the MagicalRecord library.
@objc(ParentClass)

class ParentClass: NSManagedObject {
    
    // Attributes
    
    @NSManaged var slug: String
    @NSManaged var name: String

    var persistedManagedObjectContext: NSManagedObjectContext!

    // Relationships
    @NSManaged var cardProjects: [CardProject]

}
