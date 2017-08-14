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
    
    @IBOutlet weak var output: UILabel!
    
    let cardList = CardListWrapper()!
    let mathPix = MathPix()
    let tesseract = G8Tesseract()
    
    var timer = Timer()

    var cardCount = Int32(0)
    
    var cardProject: CardProject!
    
    var cardGroup: CardGroup!
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cardGroup = cardProject.cardGroups[selectedIndex]
        
        imageView.image = cardGroup.image
        
        initCardList()
        
        tesseract.language = "eng+fra"
        tesseract.engineMode = .tesseractOnly
        tesseract.pageSegmentationMode = .auto
        tesseract.maximumRecognitionTime = 60.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initCardList() {
        cardList.clear()
        
        output.text = "Scanning photo for cards..."
        
        OpenCVWrapper.process(imageView.image, cardList)
        
//        let codes: [String] = ["A 1", "A 3", "A 1", "A 4", "A 2", "A 3", "A 2", "A 4", "A 1"]
//        let params: [String] = ["50", "45", "35.355", "90", "35.355", "45", "50", "90", "50"]

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
            
//            let code = Functions.processedCode(code: codes[Int(i)])
//            _ = cardGroup.addCard(
//                code: code,
//                param: params[Int(i)],
//                image: cardList.getFullImage(i),
//                originalCode: code,
//                originalParam: params[Int(i)],
//                originalImage: cardList.getFullImage(i)
//            )
        }
        
        checkCardProcessing()
        
        // start the timer
        timer = Timer.scheduledTimer(
            timeInterval: 0.2,
            target: self,
            selector: #selector(checkCardProcessing),
            userInfo: nil,
            repeats: true
        )
    }
    
    func checkCardProcessing() {
        if (!mathPix.processing()) {
            for i in Int32(cardGroup.cards.count)..<cardCount {
                tesseract.image = cardList.getFunctionImage(i)!.g8_blackAndWhite()
                tesseract.recognize()
                let cardImage = cardList.getFullImage(i)!
                let code = Functions.processedCode(code: tesseract.recognizedText!) 
                let param = mathPix.getValue(identifier: "param\(i)")

                _ = cardGroup.addCard(
                    code: code,
                    param: param,
                    image: cardImage,
                    originalCode: code,
                    originalParam: param,
                    originalImage: cardImage
                )
            }
        }
        
        if (cardCount < cardList.count()) {
            imageView.image = ImageProcessor.borderCards(image: imageView.image!, cardList: cardList, index: cardCount)

            cardCount += 1

            output.text = "Identifying Cards:\r\r\(cardCount)"
        } else if (!mathPix.processing()) {
            cardGroup.processed = true
            cardGroup.processedImage = imageView.image!
            cardGroup.save()
            timer.invalidate()
            
            performSegue(withIdentifier: "execution-segue", sender: nil)
        } else {
            output.text = "Processing \(cardList.count()) cards..."
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "execution-segue" {
            let dvc = segue.destination as! ExecutionViewController
            dvc.cardProject = cardProject
        }
    }
    
}

