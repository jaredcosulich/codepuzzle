//
//  ProcessingViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 6/8/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import UIKit
import MagicalRecord

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
//                    let params: [String] = ["100", "45", "35.355", "90", "35.355", "45", "100", "90", "50", "50", "50", "50", "50", "50"]
            
            for i in 0..<self.cardList.count() {
//            s3Util.upload(
//                image: cardList.getFunctionImage(index),
//                identifier: "function\(i)",
//                projectTimestamp: "TEST"
//            )
                let rotation = self.cardList.getRotation(Int32(i))
                let hexRect = self.cardList.getHexRect(Int32(i))
                let functionRect = self.cardList.getFunctionRect(Int32(i))
                self.mathPix.processImage(
                    image: ImageProcessor.cropCard(image: self.cardGroup.image, rect: functionRect, hexRect: hexRect, rotation: rotation),
                    identifier: "function\(i)",
                    result: nil
                )
                
                let paramRect = self.cardList.getParamRect(Int32(i))
                self.mathPix.processImage(
                    image: ImageProcessor.cropCard(image: self.cardGroup.image, rect: paramRect, hexRect: hexRect, rotation: rotation),
                    identifier: "param\(i)",
                    result: nil//params[Int(i)]
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
            
            let rotation = self.cardList.getRotation(cardCount)
            let hexRect = cardList.getHexRect(cardCount)
//            let functionRect = cardList.getFunctionRect(cardCount)
//            tesseract.image = ImageProcessor.cropCard(image: cardGroup.image, rect: functionRect, hexRect: hexRect, rotation: 0).g8_blackAndWhite()
//            tesseract.recognize()
            
            let fullRect = cardList.getFullRect(cardCount)
            let cardImage = ImageProcessor.cropCard(image: cardGroup.image, rect: fullRect, hexRect: hexRect, rotation: rotation)
//            let code = Functions.processedCode(code: tesseract.recognizedText!)
            let code = Functions.processedCode(code: mathPix.getValue(identifier: "function\(cardCount)"))
            let param = mathPix.getValue(identifier: "param\(cardCount)")
            
            if (Functions.valid(code: code)) {
                self.cardProject.persistedManagedObjectContext.mr_save({
                    (localContext: NSManagedObjectContext!) in
                    let newCard = Card.mr_createEntity(in: self.cardProject.persistedManagedObjectContext)
                    newCard?.cardGroup = self.cardGroup!
                    newCard?.code = code
                    newCard?.param = param
                    newCard?.image = cardImage
                    newCard?.originalCode = code
                    newCard?.originalParam = param
                    newCard?.originalImage = cardImage
                })

                imageView.image = ImageProcessor.borderCards(image: imageView.image!, cardList: cardList, index: cardCount)
            }
            
//            if (cardCount < 3) {
//                imageView.image = ImageProcessor.cropCard(image: cardGroup.image, rect: functionRect)
//            }
            
            cardCount += 1

            output.text = "Identifying Cards: \(cardCount)\r\r\(Functions.signature(code: code, param: param))"
        } else {
            timer.invalidate()
            self.cardProject.persistedManagedObjectContext.mr_save({
                (localContext: NSManagedObjectContext!) in
                self.cardGroup.processed = true
                self.cardGroup.processedImage = self.imageView.image!
            }, completion: {
                (MRSaveCompletionHandler) in
                self.cardProject.persistedManagedObjectContext.mr_saveToPersistentStoreAndWait()
                print(1)
                self.performSegue(withIdentifier: "execution-segue", sender: nil)
                print(2)
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "execution-segue" {
            let dvc = segue.destination as! ExecutionViewController
            dvc.cardProject = cardProject
        }
    }
    
}

