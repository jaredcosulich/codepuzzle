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
    
    var execute = false
    
    @IBOutlet weak var yesButton: UIButton!
    
    @IBOutlet weak var noButton: UIButton!
    
    
//    var start = NSDate()
    
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
        OpenCVWrapper.process(self.imageView.image, self.cardList)
        
        imageView.image = ImageProcessor.borderCards(image: imageView.image!, cardList: cardList, index: -1)

        output.text = "Identified \(cardList.count()) cards\r\rIs that correct?"
        
        yesButton.isHidden = false
        noButton.isHidden = false
        
        startCardAnalysis()
    }
    
    @IBAction func confirmCard(_ sender: UIButton) {
        if (cardCount < cardList.count()) {
            execute = true
            output.text = "Processing cards. One moment..."
        } else {
            self.performSegue(withIdentifier: "execution-segue", sender: nil)
        }
    }
    
    @IBAction func rejectCard(_ sender: UIButton) {
        timer.invalidate()
        Timer.scheduledTimer(
            timeInterval: 0.2,
            target: self,
            selector: #selector(self.completeCardRejection),
            userInfo: nil,
            repeats: false
        )
    }
    
    func completeCardRejection() {
        let context = self.cardProject.persistedManagedObjectContext!
        context.mr_save({
            (localContext: NSManagedObjectContext!) in
            self.cardGroup.isProcessed = false
            self.cardGroup.processedImage = nil
            for card in self.cardGroup.cards {
                card.mr_deleteEntity(in: context)
            }
        }, completion: {
            (MRSaveCompletionHandler) in
            context.mr_saveToPersistentStoreAndWait()
            self.performSegue(withIdentifier: "cancel-segue", sender: nil)
        })
    }

    func startCardAnalysis() {
        let codes: [String] = ["A 1", "A 3", "A 1", "A 4", "A 2", "A 3", "A 2", "A 4", "A 1", "A 1", "A 1", "A 1", "A 1"]
        let params: [String] = ["100", "45", "35.355", "90", "35.355", "45", "100", "90", "50", "50", "50", "50", "50", "50"]
        
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
                result: codes[Int(i)]
            )
            
            let paramRect = self.cardList.getParamRect(Int32(i))
            self.mathPix.processImage(
                image: ImageProcessor.cropCard(image: self.cardGroup.image, rect: paramRect, hexRect: hexRect, rotation: rotation),
                identifier: "param\(i)",
                result: params[Int(i)]
            )
        }

        self.checkCardProcessing()
        
        // start the timer
        self.timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(self.checkCardProcessing),
            userInfo: nil,
            repeats: true
        )
    }
    
    func checkCardProcessing() {
        if (cardCount < cardList.count()) {
            let nextParamIdentifier = "param\(cardCount)"
            let nextFunctionIdentifier = "function\(cardCount)"
        
            if (mathPix.processing(identifier: nextParamIdentifier) || mathPix.processing(identifier: nextFunctionIdentifier)) {
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
            let code = Functions.processedCode(code: mathPix.getValue(identifier: nextFunctionIdentifier))
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
            }
            
//            if (cardCount < 3) {
//                imageView.image = ImageProcessor.cropCard(image: cardGroup.image, rect: functionRect)
//            }
            
            cardCount += 1
        } else {
            timer.invalidate()
            self.cardProject.persistedManagedObjectContext.mr_save({
                (localContext: NSManagedObjectContext!) in
                self.cardGroup.isProcessed = true
                self.cardGroup.processedImage = self.imageView.image!
            }, completion: {
                (MRSaveCompletionHandler) in
                self.cardProject.persistedManagedObjectContext.mr_saveToPersistentStoreAndWait()
                if (self.execute) {
                    self.performSegue(withIdentifier: "execution-segue", sender: nil)
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cancel-segue" {
            let dvc = segue.destination as! MenuViewController
            dvc.cardProject = cardProject
        } else if segue.identifier == "execution-segue" {
            let dvc = segue.destination as! ExecutionViewController
            dvc.cardProject = cardProject
        }
    }
    
}

