//
//  Util.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 9/18/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation

class Util {
 
    class func proportionalFont(anyElement: AnyObject, bufferPercentage: Int?) {
        anyElement.layoutIfNeeded()
        
        var height = anyElement.bounds.height
        if (bufferPercentage != nil) {
            height -= (((height * CGFloat(bufferPercentage!)) / 100) * 2)
        }
        
        var size = height * (2/3)
        
        var width = anyElement.bounds.width
        if (bufferPercentage != nil) {
            width -= (((width * CGFloat(bufferPercentage!)) / 100) * 2)
        }
        
        if let element = anyElement as? UITextField {
            element.font = element.font?.withSize(size)
            return
        }
        
        if let element = anyElement as? UISegmentedControl {
            let font = UIFont.systemFont(ofSize: 16)
            element.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
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

        let lines = CGFloat(label.numberOfLines)
        if (lines > 1) {
            size = size / lines
        }
        
        let wsize = (width * 2.2 / CGFloat((label.text)!.characters.count)) * lines
        if size > wsize {
            size = wsize
        }
        
        label.font = label.font.withSize(size)
    }
    
}
