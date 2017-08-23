//
//  ImageSaver.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 8/21/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation
import MagicalRecord

class ImageSaver {

    class func save(image: UIImage, filename: String) -> Bool {
        if let data = UIImagePNGRepresentation(image) {
            try? data.write(to: uri(filename: filename))
            return true
        }
        return false
    }
    
    class func delete(filename: String) {
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: uri(filename: filename))
    }
    
    class func retrieve(filename: String) -> UIImage {
        let imageData = NSData(contentsOf: uri(filename: filename))! as Data
        return UIImage(data: imageData)!
    }
    
    class func uri(filename: String) -> URL {
        return getDocumentsDirectory().appendingPathComponent("CodePuzzle-\(filename)")
    }
    
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
