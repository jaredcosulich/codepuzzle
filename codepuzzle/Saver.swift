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
            let uri = getDocumentsDirectory().appendingPathComponent("CodePuzzle-\(filename)")
            try? data.write(to: uri)
            return true
        }
        return false
    }
    
    class func retrieve(filename: String) -> UIImage {
        let uri = getDocumentsDirectory().appendingPathComponent("CodePuzzle-\(filename)")
        let imageData = NSData(contentsOf: uri)! as Data
        return UIImage(data: imageData)!
    }
    
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
