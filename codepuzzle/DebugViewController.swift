
//
//  DebugView.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 8/15/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import UIKit

class DebugViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var cardGroupView: UIScrollView!
    @IBOutlet weak var cardGroupImageView: UIImageView!

    let cardList = CardListWrapper()!

    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        cardGroupView.minimumZoomScale = 1.0
        cardGroupView.maximumZoomScale = 6.0
        
        cardGroupImageView.image = OpenCVWrapper.debug(image)
        
//        OpenCVWrapper.process(image, cardList)
//        print("Debug Cards: \(cardList.count())")
//        cardGroupImageView.image = ImageProcessor.borderCards(image: image, cardList: cardList, index: -1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return cardGroupImageView
    }
}
