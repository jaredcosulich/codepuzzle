//
//  ProcessingViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 6/8/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import UIKit

class ProcessingViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage!
    
    let cardList = CardListWrapper()!
    
    @IBOutlet weak var output: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imageView.image = image
        
        initCardList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initCardList() {
        cardList.clear()
        
        output.text = "Scanning photo for cards..."
        
        OpenCVWrapper.process(imageView.image, cardList)
        imageView.image = ImageProcessor.borderCards(image: imageView.image!, cardList: cardList)
        
        output.text = "\(cardList.count()) cards identified. Processing cards..."
    }

    
}

