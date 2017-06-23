//
//  FirstViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 6/8/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    let cardList = CardListWrapper()!
    var index = Int32(0)
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func revertbutton(_ sender: UIButton) {
        let image = UIImage(named: "portrait_with_numbers.JPG")
        let normalizedImage = ImageProcessor.normalize(image: image!)
            
        imageView.image = normalizedImage
    }
    
    @IBAction func cannybutton(_ sender: UIButton) {
        OpenCVWrapper.canny(imageView.image, cardList)

        timer.invalidate() // just in case this button is tapped multiple times
        
        // start the timer
        timer = Timer.scheduledTimer(
            timeInterval: 5,
            target: self,
            selector: #selector(showCard),
            userInfo: nil,
            repeats: true
        )
    }
    
    func showCard() {
        imageView.image = cardList.getFull(index)!
        
        let tesseract = G8Tesseract()
        tesseract.language = "eng+fra"
        tesseract.engineMode = .tesseractOnly
        tesseract.pageSegmentationMode = .auto
        tesseract.maximumRecognitionTime = 60.0
        tesseract.image = cardList.getFunction(index)?.g8_blackAndWhite()
        tesseract.recognize()
        print("TESSERACT: \(tesseract.recognizedText)")
        //
        //        let imageData = UIImagePNGRepresentation((cardList.getFunction(index))!)! as NSData
        //        MathPix.processSingleImage(imageData : imageData)
        
        index += 1
        if (index >= cardList.count()) {
            index = 0
        }
    }
}

