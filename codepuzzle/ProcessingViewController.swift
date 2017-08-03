//
//  ProcessingViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 6/8/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import UIKit

struct Card {
    var image: UIImage
    var fuction: String
    var param: String
}

class ProcessingViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var output: UILabel!
    
    let cardList = CardListWrapper()!
    let mathPix = MathPix()
    
    var timer = Timer()

    var image: UIImage!
    
//    var functions: Functions!

    var cards = [Card]()
    
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

        for i in 0..<cardList.count() {
//            s3Util.upload(
//                image: cardList.getFunctionImage(index),
//                identifier: "function\(i)",
//                projectTimestamp: "TEST"
//            )
//            mathPix.processImage(
//                image: cardList.getFunctionImage(i)!,
//                identifier: "function\(i)"
//            )
            mathPix.processImage(
                image: cardList.getParamImage(Int32(i))!,
                identifier: "param\(i)"
            )
        }
        
        // start the timer
        timer = Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(checkCardProcessing),
            userInfo: nil,
            repeats: true
        )
    }
    
    func checkCardProcessing() {
        if (!mathPix.processing()) {
            timer.invalidate()
            
            let tesseract = G8Tesseract()
            tesseract.language = "eng+fra"
            tesseract.engineMode = .tesseractOnly
            tesseract.pageSegmentationMode = .auto
            tesseract.maximumRecognitionTime = 60.0
            
            for i in 0..<cardList.count() {
                tesseract.image = cardList.getFunctionImage(i)!.g8_blackAndWhite()
                tesseract.recognize()
                let cardImage = cardList.getFullImage(i)
                let function = tesseract.recognizedText!
                let param = mathPix.getValue(identifier: "param\(i)")
                cards.append(Card(image: cardImage!, fuction: function, param: param))
            }
            
            performSegue(withIdentifier: "execution-segue", sender: nil)

        } else {
            output.text = "\(cardList.count()) cards identified. Still processing..."
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "execution-segue" {
            let dvc = segue.destination as! ExecutionViewController
            dvc.cards = cards
        }
    }
    
}

