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
//    let tesseract = G8Tesseract()
    
    var timer = Timer()

    var analyzedCardCount = Int32(0)
    var processedCardCount = Int32(0)
    
    var cardProject: CardProject!
    
    var cardGroup: CardGroup!
    
    var selectedIndex = 0
    
    var processing: Bool!
    
    var execute = false
    
    @IBOutlet weak var yesButton: UIButton!
    
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
//    var start = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cardGroup = cardProject.cardGroups[selectedIndex]
        
        imageView.image = ImageProcessor.scale(image: cardGroup.image!, view: imageView)
        
        initCardList()
        
//        tesseract.language = "eng+fra"
//        tesseract.engineMode = .tesseractOnly
//        tesseract.pageSegmentationMode = .auto
//        tesseract.maximumRecognitionTime = 60.0
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initCardList() {
        processing = true
        output.text = "Scanning photo for cards..."
        cardList.clear()
        activityView.startAnimating()
        
        Timer.scheduledTimer(
            timeInterval: 0,
            target: self,
            selector: #selector(startCardProcessing),
            userInfo: nil,
            repeats: false
        )
    }
    
    func startCardProcessing() {
        OpenCVWrapper.process(cardGroup.image, self.cardList)
        
        setProcessedImage(
            image: ImageProcessor.borderCards(image: cardGroup.image!, cardList: cardList, index: -1),
            completion: {
                self.imageView.image = ImageProcessor.scale(image: self.cardGroup.processedImage!, view: self.imageView)

                self.activityView.stopAnimating()
                
                self.output.text = "Identified \(self.cardList.count()) cards\r\rIs that correct?"
                
                self.yesButton.isHidden = false
                self.noButton.isHidden = false
                
                Timer.scheduledTimer(
                    timeInterval: 0,
                    target: self,
                    selector: #selector(self.analyzeCards),
                    userInfo: nil,
                    repeats: false
                )
            }
        )
    }
    
    @IBAction func confirmCard(_ sender: UIButton) {
        activityView.startAnimating()
        yesButton.isHidden = true
        noButton.isHidden = true
        output.text = "Processing cards. One moment..."

        if (processedCardCount < cardList.count()) {
            execute = true
        } else {
            Timer.scheduledTimer(
                timeInterval: 0,
                target: self,
                selector: #selector(executeCards),
                userInfo: nil,
                repeats: false
            )
        }
    }
    
    @IBAction func rejectCard(_ sender: UIButton) {
        timer.invalidate()
        Timer.scheduledTimer(
            timeInterval: 0,
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

    func analyzeCards() {
        let codes: [String] = ["A 1", "A 3", "A 1", "A 4", "A 2", "A 3", "A 2", "A 4", "A 1", "A 2", "A 3", "A 1", "A 3", "A 1", "A 3", "91", "A 5", "A 2", "A 4", "A 1", "A B", "11", "A 1", "A 3", "12"]
        let params: [String] = ["100", "45", "70.711", "90", "70.71", "45", "100", "90", "100", "30", "90", "40", "90", "20", "90", "40", "", "75", "90", "20", "", "4", "20", "90", ""]
        
//            s3Util.upload(
//                image: cardList.getFunctionImage(index),
//                identifier: "function\(i)",
//                projectTimestamp: "TEST"
//            )

        if (execute) {
            output.text = "Processing Card \(analyzedCardCount + 1)..."
        }
        
        let rotation = self.cardList.getRotation(Int32(analyzedCardCount))
        let hexRect = self.cardList.getHexRect(Int32(analyzedCardCount))
        let functionRect = self.cardList.getFunctionRect(Int32(analyzedCardCount))
        self.mathPix.processImage(
            image: ImageProcessor.cropCard(image: self.cardGroup.image!, rect: functionRect, hexRect: hexRect, rotation: rotation),
            identifier: "function\(analyzedCardCount)",
            result: codes[Int(analyzedCardCount)]
        )
        
        let paramRect = self.cardList.getParamRect(Int32(analyzedCardCount))
        self.mathPix.processImage(
            image: ImageProcessor.cropCard(image: self.cardGroup.image!, rect: paramRect, hexRect: hexRect, rotation: rotation),
            identifier: "param\(analyzedCardCount)",
            result: params[Int(analyzedCardCount)]
        )

        analyzedCardCount += 1

        if (analyzedCardCount < cardList.count()) {
            Timer.scheduledTimer(
                timeInterval: 0,
                target: self,
                selector: #selector(analyzeCards),
                userInfo: nil,
                repeats: false
            )
        } else {
            self.checkCardProcessing()
        }
    }
    
    func checkCardProcessing() {
        if (execute) {
            output.text = "Analyzing Card \(processedCardCount + 1)..."
        }

        if (processedCardCount < cardList.count()) {
            let nextParamIdentifier = "param\(processedCardCount)"
            let nextFunctionIdentifier = "function\(processedCardCount)"
        
            if (mathPix.processing(identifier: nextParamIdentifier) || mathPix.processing(identifier: nextFunctionIdentifier)) {

                Timer.scheduledTimer(
                    timeInterval: 0.25,
                    target: self,
                    selector: #selector(self.checkCardProcessing),
                    userInfo: nil,
                    repeats: false
                )

            } else {
                processedCardCount += 1
                checkCardProcessing()
            }
        } else {
            if execute {
                executeCards()
            }
        }
    }
    
    func setProcessedImage(image: UIImage, completion: @escaping () -> Void) {
        let context = self.cardProject.persistedManagedObjectContext!
        context.mr_save({
            (localContext: NSManagedObjectContext!) in
            self.cardGroup.processedImage = image
        }, completion: {
            (MRSaveCompletionHandler) in
            context.mr_saveToPersistentStoreAndWait()
            completion()
        })
    }
    
    func executeCards() {
        if (execute) {
            output.text = "Saving Cards..."
        }

        let context = self.cardProject.persistedManagedObjectContext!
        context.mr_save({
            (localContext: NSManagedObjectContext!) in
            
            for i in 0..<self.processedCardCount {
                let rotation = self.cardList.getRotation(i)
                let hexRect = self.cardList.getHexRect(i)
                //            let functionRect = self.cardList.getFunctionRect(i)
                //            tesseract.image = ImageProcessor.cropCard(image: self.cardGroup.image, rect: functionRect, hexRect: hexRect, rotation: 0).g8_blackAndWhite()
                //            tesseract.recognize()
                
                let fullRect = self.cardList.getFullRect(i)
                
                let cardImage = ImageProcessor.cropCard(image: self.cardGroup.image!, rect: fullRect, hexRect: hexRect, rotation: rotation)
                
                //            let code = Functions.processedCode(code: tesseract.recognizedText!)
                
                let code = self.mathPix.getValue(identifier: "function\(i)")
                let param = self.mathPix.getValue(identifier: "param\(i)")

                print("\(self.mathPix.getValue(identifier: "function\(i)")), \(self.mathPix.getValue(identifier: "param\(i)")) -> \(Functions.signature(code: code, param: param))")

                if (Functions.valid(code: code)) {
                    let newCard = Card.mr_createEntity(in: context)
                    newCard?.cardGroup = self.cardGroup!
                    newCard?.code = code
                    newCard?.param = param
                    newCard?.image = cardImage
                    
                    newCard?.originalCode = code
                    newCard?.originalParam = param
                    newCard?.originalImage = cardImage
                }
            }
            
            self.cardGroup.isProcessed = true
            
        }, completion: {
            (MRSaveCompletionHandler) in
            context.mr_saveToPersistentStoreAndWait()
            self.performSegue(withIdentifier: "execution-segue", sender: nil)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        imageView?.removeFromSuperview()
        
        if segue.identifier == "cancel-segue" {
            let dvc = segue.destination as! MenuViewController
            dvc.cardProject = cardProject
        } else if segue.identifier == "execution-segue" {
            let dvc = segue.destination as! ExecutionViewController
            dvc.cardProject = cardProject
        }
    }
    
}

