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
        imageView.image = UIImage(named: "cardtest4_far.JPG");
    }
    
    @IBAction func cannybutton(_ sender: UIButton) {
        let processedImage = OpenCVWrapper.canny(imageView.image);
        imageView.image = processedImage;
        
        let tesseract = G8Tesseract();
        tesseract.language = "eng+fra";
        tesseract.engineMode = .tesseractOnly;
        tesseract.pageSegmentationMode = .auto;
        tesseract.maximumRecognitionTime = 60.0;
        tesseract.image = processedImage?.g8_blackAndWhite();
        tesseract.recognize();
        print("TESSERACT: \(tesseract.recognizedText)");
    }
}

