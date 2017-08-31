//
//  Loop.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 8/31/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation

class Loop {
    
    var startingIndex: Int!
    var count = Int(-1)
    var completedCycles = Int(0)
    
    init(startingIndex: Int, count: Int) {
        self.startingIndex = startingIndex
        self.count = count
    }
    
    func increment() -> Int {
        completedCycles += 1
        if (completedCycles < count) {
            return startingIndex
        } else {
            return -1
        }
    }
    
    class func duplicate(loops: [Loop], startingIndex: Int) -> Bool {
        for loop in loops {
            if loop.startingIndex == startingIndex {
                return true
            }
        }
        return false
    }
    
}
