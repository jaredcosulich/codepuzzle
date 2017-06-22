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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func revertbutton(_ sender: UIButton) {
        imageView.image = UIImage(named: "cards_with_numbers_mid.JPG");
    }
    
    @IBAction func cannybutton(_ sender: UIButton) {
        let cardList = CardListWrapper();
        OpenCVWrapper.canny(imageView.image, cardList);
        imageView.image = cardList!.getFull(3)!;
        
        let tesseract = G8Tesseract();
        tesseract.language = "eng+fra";
        tesseract.engineMode = .tesseractOnly;
        tesseract.pageSegmentationMode = .auto;
        tesseract.maximumRecognitionTime = 60.0;
        tesseract.image = cardList?.getFunction(3)?.g8_blackAndWhite();
        tesseract.recognize();
        print("TESSERACT: \(tesseract.recognizedText)");
        
        let imageData = UIImagePNGRepresentation((cardList?.getParam(3))!)! as NSData
        MathPix.processSingleImage(imageData : imageData)
    }
}

