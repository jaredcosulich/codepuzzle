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

    var cardCount = Int32(0)
    
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
                    selector: #selector(self.startCardAnalysis),
                    userInfo: nil,
                    repeats: false
                )
            }
        )
    }
    
    @IBAction func confirmCard(_ sender: UIButton) {
        if (cardCount < cardList.count()) {
            execute = true
            output.text = "Processing cards. One moment..."
        } else {
            executeCards()
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
                image: ImageProcessor.cropCard(image: self.cardGroup.image!, rect: functionRect, hexRect: hexRect, rotation: rotation),
                identifier: "function\(i)",
                result: codes[Int(i)]
            )
            
            let paramRect = self.cardList.getParamRect(Int32(i))
            self.mathPix.processImage(
                image: ImageProcessor.cropCard(image: self.cardGroup.image!, rect: paramRect, hexRect: hexRect, rotation: rotation),
                identifier: "param\(i)",
                result: params[Int(i)]
            )
        }

        self.checkCardProcessing()
    }
    
    func checkCardProcessing() {
        if (cardCount < cardList.count()) {
            let nextParamIdentifier = "param\(cardCount)"
            let nextFunctionIdentifier = "function\(cardCount)"
        
            if (mathPix.processing(identifier: nextParamIdentifier) || mathPix.processing(identifier: nextFunctionIdentifier)) {
                
                // start the timer
                self.timer = Timer.scheduledTimer(
                    timeInterval: 0.1,
                    target: self,
                    selector: #selector(self.checkCardProcessing),
                    userInfo: nil,
                    repeats: false
                )

                return
            }
            
            cardCount += 1
            checkCardProcessing()
        } else {
            timer.invalidate()
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
        activityView.startAnimating()
        yesButton.isHidden = true
        noButton.isHidden = true
        output.isHidden = true
        
        let context = self.cardProject.persistedManagedObjectContext!
        context.mr_save({
            (localContext: NSManagedObjectContext!) in
            
            for i in 0..<self.cardCount {
                let rotation = self.cardList.getRotation(i)
                let hexRect = self.cardList.getHexRect(i)
                //            let functionRect = self.cardList.getFunctionRect(i)
                //            tesseract.image = ImageProcessor.cropCard(image: self.cardGroup.image, rect: functionRect, hexRect: hexRect, rotation: 0).g8_blackAndWhite()
                //            tesseract.recognize()
                
                let fullRect = self.cardList.getFullRect(i)
                
                let cardImage = ImageProcessor.cropCard(image: self.cardGroup.image!, rect: fullRect, hexRect: hexRect, rotation: rotation)
                
                //            let code = Functions.processedCode(code: tesseract.recognizedText!)
                let code = Functions.processedCode(code: self.mathPix.getValue(identifier: "function\(i)"))
                let param = self.mathPix.getValue(identifier: "param\(i)")
                
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

