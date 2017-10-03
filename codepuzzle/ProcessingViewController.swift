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
    
    var analyzedCardCount = Int32(0)
    var processedCardCodeCount = Int32(0)
    var processedCardParamCount = Int32(0)
    
    var cardProject: CardProject!
    
    var cardGroup: CardGroup!
    
    var selectedIndex = 0
    
    var processing: Bool!
    
    var execute = false
    
    var stopExecution = false
    
    @IBOutlet weak var yesButton: UIButton!
    
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet weak var fixButton: UIButton!
    
    @IBOutlet weak var changePhotoButton: UIButton!
    
    @IBOutlet weak var selectPhoto: UIButton!

    @IBOutlet weak var debugPhoto: UIButton!

    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    let s3Util = S3Util()

    
//    let codes: [String] = ["A 7", "A 8", "A 4", "A 1", "A 3", "A 1", "A 4", "A 1", "A 7", "A 8", "F 1", "A 1", "", "A 3", "A 1", "12", "A 1", "F 2", "17", "F 1", "A 4", "A 5", "A 2", "A 9", "A 1", "A 3", "A C", "12"]
//
//    let params: [String] = ["6", "UIExtendedSRGBColorSpace 0.27451 0.588235 0.513725 1", "10", "30", "20", "30", "20", "30", "1", "UIExtendedSRGBColorSpace 0.243137 0.219608 0.192157 1", "", "40", "69", "3", "0.5", "", "40", "", "12", "1", "13", "", "30", "UIExtendedSRGBColorSpace 0.819608 0.721569 0.305882 1", "30", "196", "", ""]

//    var start = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cardGroup = cardProject.cardGroups[selectedIndex]
        
        imageView.image = ImageProcessor.scale(image: cardGroup.image!, view: imageView)
        
        initCardList()
        
        Util.proportionalFont(anyElement: output, bufferPercentage: nil)
        
        yesButton.layer.cornerRadius = 6
        Util.proportionalFont(anyElement: yesButton, bufferPercentage: nil)
        noButton.titleLabel?.font = yesButton.titleLabel?.font
        
        changePhotoButton.layer.cornerRadius = 6
        Util.proportionalFont(anyElement: changePhotoButton, bufferPercentage: 10)

        fixButton.layer.cornerRadius = 6
        fixButton.titleLabel?.font = changePhotoButton.titleLabel?.font

        debugPhoto.layer.cornerRadius = 6
        Util.proportionalFont(anyElement: debugPhoto, bufferPercentage: 5)
        
        selectPhoto.layer.cornerRadius = 6
        
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
        OpenCVWrapper.process(cardGroup.image, self.cardList, 0.5)
        
        if self.cardList.count() == 0 || self.cardList.getHexRect(0).width < 75 {
            self.cardList.clear()
            OpenCVWrapper.process(cardGroup.image, self.cardList, 1)
        }
        
        if self.cardList.count() == 0 || self.cardList.getHexRect(0).width > 400 {
            self.cardList.clear()
            OpenCVWrapper.process(cardGroup.image, self.cardList, 0.2)
        }
        
        Timer.scheduledTimer(
            withTimeInterval: 0,
            repeats: false,
            block: {
                (Timer) in
                for i in 0..<self.cardList.count() {
                    let rotation = self.cardList.getRotation(Int32(i))
                    let hexRect = self.cardList.getHexRect(Int32(i))
                    let fullRect = self.cardList.getFullRect(Int32(i))
                    let image = ImageProcessor.cropCard(image: self.cardGroup.image!, rect: fullRect, hexRect: hexRect, rotation: rotation)
                    
//                    self.s3Util.upload(
//                        image: image,
//                        identifier: "function\(i)",
//                        projectTimestamp: "TEST"
//                    )
                }
            }
        )
        
        
        setProcessedImage(
            image: ImageProcessor.borderCards(image: cardGroup.image!, cardList: cardList, index: -1),
            completion: {
                self.imageView.image = ImageProcessor.scale(image: self.cardGroup.processedImage!, view: self.imageView)

                self.activityView.stopAnimating()
                
                self.debugPhoto.isHidden = false

                if (self.cardList.count() == 0) {
                    self.output.text = "Unable to find any cards. Please try a new photo."
                    self.selectPhoto.isHidden = false
                } else {
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
            }
        )
    }
    
    @IBAction func confirmCard(_ sender: UIButton) {
        activityView.startAnimating()
        yesButton.isHidden = true
        noButton.isHidden = true
        debugPhoto.isHidden = true
        output.text = "Analyzing cards. One moment..."

        if (processedCardParamCount < cardList.count()) {
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
            self.cardGroup.mr_deleteEntity(in: context)
        }, completion: {
            (MRSaveCompletionHandler) in
            context.mr_saveToPersistentStoreAndWait()
            self.performSegue(withIdentifier: "cancel-segue", sender: nil)
        })
    }

    func analyzeCards() {
        if (stopExecution) {
            return
        }

        if (execute) {
            output.text = "Analyzing Card \(analyzedCardCount + 1)..."
        }
        
        let rotation = self.cardList.getRotation(Int32(analyzedCardCount))
        let hexRect = self.cardList.getHexRect(Int32(analyzedCardCount))
        let functionRect = self.cardList.getFunctionRect(Int32(analyzedCardCount))
        self.mathPix.processImage(
            image: ImageProcessor.cropCard(image: self.cardGroup.image!, rect: functionRect, hexRect: hexRect, rotation: rotation),
            identifier: "function\(analyzedCardCount)",
            result: nil//codes[Int(analyzedCardCount)]
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
            self.checkCardCodeProcessing()
        }
    }
    
    func checkCardCodeProcessing() {
        if (stopExecution) {
            return
        }

        if (processedCardCodeCount < cardList.count()) {
            if (execute) {
                output.text = "Analyzing Card Codes \(processedCardCodeCount + 1)..."
            }

            let nextFunctionIdentifier = "function\(processedCardCodeCount)"
        
            if (mathPix.processing(identifier: nextFunctionIdentifier)) {

                Timer.scheduledTimer(
                    timeInterval: 0.25,
                    target: self,
                    selector: #selector(self.checkCardCodeProcessing),
                    userInfo: nil,
                    repeats: false
                )

            } else {
                let rotation = self.cardList.getRotation(Int32(processedCardCodeCount))
                let hexRect = self.cardList.getHexRect(Int32(processedCardCodeCount))
                let paramRect = self.cardList.getParamRect(Int32(processedCardCodeCount))
                var paramImage: UIImage!
                
                let functionValue = mathPix.getValue(identifier: nextFunctionIdentifier)
                let methodName = Functions.info(code: functionValue).method
                print("PROCESSED: \(methodName)")
                var result: String!
                if methodName == "fillColor" || methodName == "penColor" {
                    let colorRect = CGRect(
                        x: paramRect.midX - 5,
                        y: paramRect.minY + (paramRect.height * 3 / 4) - 5,
                        width: 10,
                        height: 10
                    )

                    paramImage = ImageProcessor.cropCard(image: self.cardGroup.image!, rect: colorRect, hexRect: hexRect, rotation: rotation)
                    result = "\(paramImage.averageColor())"
                } else {
                    paramImage = ImageProcessor.cropCard(image: self.cardGroup.image!, rect: paramRect, hexRect: hexRect, rotation: rotation)
                }
                
                self.mathPix.processImage(
                    image: paramImage,
                    identifier: "param\(processedCardCodeCount)",
                    result: result//params[Int(processedCardCodeCount)]
                )

                processedCardCodeCount += 1
                checkCardCodeProcessing()
            }
        } else {
            checkCardParamProcessing()
        }
    }

    func checkCardParamProcessing() {
        if (stopExecution) {
            return
        }

        if (processedCardParamCount < cardList.count()) {
            if (execute) {
                output.text = "Analyzing Card Parameters \(processedCardParamCount + 1)..."
            }

            let nextParamIdentifier = "param\(processedCardParamCount)"
            
            if (mathPix.processing(identifier: nextParamIdentifier)) {
                
                Timer.scheduledTimer(
                    timeInterval: 0.25,
                    target: self,
                    selector: #selector(self.checkCardParamProcessing),
                    userInfo: nil,
                    repeats: false
                )
                
            } else {
                processedCardParamCount += 1
                checkCardParamProcessing()
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
            output.text = "Processing Cards..."
        }
        
        processCards(i: 0)
    }
    
    func processCards(i: Int32) {
        if (stopExecution) {
            return
        }
        
        output.text = "Processing Card \(i + 1)"
        
        let context = cardProject.persistedManagedObjectContext!
        context.mr_save({
            (localContext: NSManagedObjectContext!) in
            
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
            
            //                print("\(self.mathPix.getValue(identifier: "function\(i)")), \(self.mathPix.getValue(identifier: "param\(i)")) -> \(Functions.signature(code: code, param: param))")
            
            let newCard = Card.mr_createEntity(in: context)
            newCard?.cardGroup = self.cardGroup!
            newCard?.code = code
            newCard?.param = param
            newCard?.image = cardImage
            
            newCard?.originalCode = code
            newCard?.originalParam = param
            newCard?.originalImage = cardImage
            newCard?.error = !Functions.valid(code: code, param: param)
        }, completion: {
            (MRSaveCompletionHandler) in
            Timer.scheduledTimer(
                withTimeInterval: 0,
                repeats: false,
                block: {(t) in
                    if (i == self.processedCardParamCount - 1) {
                        self.cardGroup.isProcessed = true
                        self.completeCardProcessing(context: context)
                    } else {
                        self.processCards(i: i + 1)
                    }
                }
            )
        })
    }

    func completeCardProcessing(context: NSManagedObjectContext) {
        context.mr_saveToPersistentStoreAndWait()
        let cardsWithError = self.cardGroup.cards.filter({ (c) -> Bool in c.error}).count
        if cardsWithError > 0 {
            self.output.text = "We were unable to process \(cardsWithError) \(cardsWithError > 1 ? "cards" : "card")."
            
            self.activityView.stopAnimating()
            
            self.fixButton.isHidden = false
            self.changePhotoButton.isHidden = false
            self.debugPhoto.isHidden = false
            
            return
        }
        
        self.performSegue(withIdentifier: "execution-segue", sender: nil)
    }
    
    @IBAction func fix(_ sender: UIButton) {
        selectedIndex = cardProject.allCards().index(where: { (c) -> Bool in c.error })!
        performSegue(withIdentifier: "manual-segue", sender: nil)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("CODES: \(cardProject.allCards().map({ (c) -> String in c.code }))")
//        print("PARAMS: \(cardProject.allCards().map({ (c) -> String in c.param }))")
        
        stopExecution = true
        
        imageView?.removeFromSuperview()
        
        if segue.identifier == "cancel-segue" || segue.identifier == "select-photo-segue" {
            let dvc = segue.destination as! MenuViewController
            self.cardGroup.mr_deleteEntity()
            dvc.cardProject = cardProject
        } else if segue.identifier == "execution-segue" {
            let dvc = segue.destination as! ExecutionViewController
            dvc.cardProject = cardProject
        } else if segue.identifier == "manual-segue" {
            let dvc = segue.destination as! EditCommandViewController
            dvc.cardProject = cardProject
            dvc.selectedIndex = selectedIndex
        } else if segue.identifier == "debug-segue" {
            let dvc = segue.destination as! DebugViewController
            dvc.cardProject = cardProject
            dvc.selectedIndex = selectedIndex
            dvc.image = cardGroup.image
        }
    }
    
}

