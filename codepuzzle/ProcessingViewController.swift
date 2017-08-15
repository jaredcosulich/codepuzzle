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
    
    var processing: Bool!
    
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
        processing = true
        output.text = "Scanning photo for cards..."
        cardList.clear()
        
        // start the timer
        Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(startCardProcessing),
            userInfo: nil,
            repeats: false
        )
    }
    
    func startCardProcessing() {
        DispatchQueue.global(qos: .background).async {
            
            OpenCVWrapper.process(self.imageView.image, self.cardList)
            self.processing = false
            
            //        let codes: [String] = ["A 1", "A 3", "A 1", "A 4", "A 2", "A 3", "A 2", "A 4", "A 1", "A 1", "A 1", "A 1", "A 1"]
                    let params: [String] = ["100", "45", "35.355", "90", "35.355", "45", "100", "90", "50", "50", "50", "50", "50", "50"]
            
            for i in 0..<self.cardList.count() {
//            s3Util.upload(
//                image: cardList.getFunctionImage(index),
//                identifier: "function\(i)",
//                projectTimestamp: "TEST"
//            )
//            mathPix.processImage(
//                image: cardList.getFunctionImage(i)!,
//                identifier: "function\(i)"
//            )
                
                let paramRect = self.cardList.getParamRect(Int32(i))
                self.mathPix.processImage(
                    image: ImageProcessor.cropCard(image: self.cardGroup.image, rect: paramRect),
                    identifier: "param\(i)",
                    result: params[Int(i)]
                )
                
//            let code = Functions.processedCode(code: codes[Int(i)])
//            let fullRect = cardList.getFullRect(Int32(i))
//            let fullImage = ImageProcessor.cropCard(image: cardGroup.image, rect: fullRect)
//            _ = cardGroup.addCard(
//                code: code,
//                param: params[Int(i)],
//                image: fullImage,
//                originalCode: code,
//                originalParam: params[Int(i)],
//                originalImage: fullImage
//            )
            }
            
        }

        self.checkCardProcessing()
        
        // start the timer
        self.timer = Timer.scheduledTimer(
            timeInterval: 0.2,
            target: self,
            selector: #selector(self.checkCardProcessing),
            userInfo: nil,
            repeats: true
        )
    }
    
    func checkCardProcessing() {
        if (processing) {
            return
        }
        
        if (cardCount < cardList.count()) {
            let nextIdentifier = "param\(cardCount)"
        
            if (mathPix.processing(identifier: nextIdentifier)) {
                return
            }
            
            let functionRect = cardList.getFunctionRect(cardCount)
            tesseract.image = ImageProcessor.cropCard(image: cardGroup.image, rect: functionRect).g8_blackAndWhite()
            tesseract.recognize()
            
            let fullRect = cardList.getFullRect(cardCount)
            let cardImage = ImageProcessor.cropCard(image: cardGroup.image, rect: fullRect)
            let code = Functions.processedCode(code: tesseract.recognizedText!)
            let param = mathPix.getValue(identifier: "param\(cardCount)")
            
            if (Functions.valid(code: code)) {
                _ = cardGroup.addCard(
                    code: code,
                    param: param,
                    image: cardImage,
                    originalCode: code,
                    originalParam: param,
                    originalImage: cardImage
                )

                imageView.image = ImageProcessor.borderCards(image: imageView.image!, cardList: cardList, index: cardCount)
            }
            
//            if (cardCount < 3) {
//                imageView.image = ImageProcessor.cropCard(image: cardGroup.image, rect: functionRect)
//            }
            
            cardCount += 1

            output.text = "Identifying Cards:\(cardCount)\r\r\(Functions.signature(code: code, param: param))"
        } else {
            cardGroup.processed = true
            cardGroup.processedImage = imageView.image!
            cardGroup.save()
            timer.invalidate()
            
            performSegue(withIdentifier: "execution-segue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "execution-segue" {
            let dvc = segue.destination as! ExecutionViewController
            dvc.cardProject = cardProject
        }
    }
    
}

