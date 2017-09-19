//
//  Util.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 9/18/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation

class Util {
 
    class func proportionalFont(anyElement: AnyObject, buffer: Int?) {
        var height = anyElement.bounds.height
        if (buffer != nil) {
            height -= CGFloat(buffer! * 2)
        }
        
        var size = height * (1/log2(3))
        
        if let element = anyElement as? UITextField {
            element.font = element.font?.withSize(size)
            return
        }
        
        var label: UILabel!
        if let element = anyElement as? UIButton {
            label = element.titleLabel!
        } else if let element = anyElement as? UITableViewCell {
            label = element.textLabel!
        } else if let element = anyElement as? UILabel {
            label = element
        }

        if (label.numberOfLines > 1) {
            size = size / CGFloat(label.numberOfLines)
        }
        
        label.font = label.font.withSize(size)
    }
    
}
