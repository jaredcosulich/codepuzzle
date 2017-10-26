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
    
    var cardList: CardListWrapper!
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
    
    @IBOutlet weak var fixButton: UIButton!
    
    @IBOutlet weak var changePhotoButton: UIButton!
    
    @IBOutlet weak var retryButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var selectPhoto: UIButton!

    @IBOutlet weak var debugPhoto: UIButton!

    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var s3Util: S3Util!
    
    let puzzleSchool = PuzzleSchool()

    
//    let codes: [String] = ["A 7", "A 8", "A 4", "A 1", "A 3", "A 1", "A 4", "A 1", "A 7", "A 8", "F 1", "A 1", "", "A 3", "A 1", "12", "A 1", "F 2", "17", "F 1", "A 4", "A 5", "A 2", "A 9", "A 1", "A 3", "A C", "12"]
//
//    let params: [String] = ["6", "UIExtendedSRGBColorSpace 0.27451 0.588235 0.513725 1", "10", "30", "20", "30", "20", "30", "1", "UIExtendedSRGBColorSpace 0.243137 0.219608 0.192157 1", "", "40", "69", "3", "0.5", "", "40", "", "12", "1", "13", "", "30", "UIExtendedSRGBColorSpace 0.819608 0.721569 0.305882 1", "30", "196", "", ""]

//    let codes: [String] = ["L 1", "a 1", "A 3", "L 2", "P 1", "A 3", "A 1", "A 5"]
//    let params: [String] = ["5", "100", "144", "", "", "18", "50", "UIExtendedSRGBColorSpace 0.345098 0.243137 0.376471 1"]
    
//    var start = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        s3Util = S3Util(projectName: cardProject.title, className: cardProject.parentClass?.name)
        
        cardGroup = cardProject.cardGroups[selectedIndex]
        
        if let processedImage = cardGroup.processedImage {
            imageView.image = ImageProcessor.scale(image: processedImage, view: imageView)
        } else {
            imageView.image = ImageProcessor.borderCards(image: cardGroup.image!, cardList: cardList, index: -1, width: 8, deleteIcon: false)
        }
        
        Util.proportionalFont(anyElement: output, bufferPercentage: nil)
        
        cancelButton.layer.cornerRadius = 6
        Util.proportionalFont(anyElement: cancelButton, bufferPercentage: 10)

        retryButton.layer.cornerRadius = 6
        retryButton.titleLabel?.font = cancelButton.titleLabel?.font
        
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
        
//        initCardList(nil)
        initAnalysis(nil)
        
        Timer.scheduledTimer(
            timeInterval: 0,
            target: self,
            selector: #selector(initS3Upload),
            userInfo: nil,
            repeats: false
        )
    }
    
    func initS3Upload(timer: Timer) {
        self.s3Util.upload(
            image: self.cardGroup.image!,
            imageType: "group",
            completion: {
                s3Url in
                print("S3 UPLOADED")
                if self.cardProject.parentClass != nil {
                    let identifier = self.puzzleSchool.saveGroup(cardProject: self.cardProject, imageUrl: s3Url)

                    Timer.scheduledTimer(
                        timeInterval: 0.1,
                        target: self,
                        selector: #selector(self.setCardGroupId),
                        userInfo: identifier,
                        repeats: true
                    )
                }
            }
        )
    }
    
    @IBAction func initAnalysis(_ sender: Any?) {
        retryButton.isHidden = true
        cancelButton.isHidden = true
        debugPhoto.isHidden = true
        
        stopExecution = false
        processing = true
        execute = true
        
        activityView.startAnimating()
        
        output.text = "Analyzing cards. One moment..."
        
        if (processedCardParamCount < cardList.count()) {
            Timer.scheduledTimer(
                timeInterval: 0,
                target: self,
                selector: #selector(analyzeCards),
                userInfo: nil,
                repeats: false
            )
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
    
    func setCardGroupId(timer: Timer) {
        let identifier = timer.userInfo as! String
        if self.puzzleSchool.processing(identifier: identifier) {
            return
        }
        timer.invalidate()
        
        self.cardGroup.id = self.puzzleSchool.getValue(identifier: identifier)!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if let fullImage = self.cardGroup.image {
            self.mathPix.processImage(
                image: ImageProcessor.cropCard(image: fullImage, rect: functionRect, hexRect: hexRect, rotation: rotation),
                identifier: "function\(analyzedCardCount)",
                result: nil//codes[Int(analyzedCardCount)]
            )
        }
        
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
                
                if functionValue == "ERROR" {
                    stopExecution = true
                    output.text = "There was an error. Please check your internet connection and try again."
                    debugPhoto.isHidden = true
                    self.activityView.stopAnimating()
                    cancelButton.isHidden = false
                    retryButton.isHidden = false
                    return
                }
                
                let methodName = Functions.info(code: functionValue).method
                output.text = "Reading Card \(processedCardCodeCount + 1):\r\(Functions.info(code: functionValue).name)"
                print("PROCESSED: \(methodName)")
                var result: String!
                if let fullImage = self.cardGroup.image {
                    if methodName == "fillColor" || methodName == "penColor" {
                        let colorRect = CGRect(
                            x: paramRect.midX - 5,
                            y: paramRect.minY + (paramRect.height * 3 / 4) - 5,
                            width: 10,
                            height: 10
                        )
                        
                        paramImage = ImageProcessor.cropCard(image: fullImage, rect: colorRect, hexRect: hexRect, rotation: rotation)
                        result = "\(paramImage.averageColor())"
                    } else {
                        paramImage = ImageProcessor.cropCard(image: fullImage, rect: paramRect, hexRect: hexRect, rotation: rotation)
                    }
                
                    self.mathPix.processImage(
                        image: paramImage,
                        identifier: "param\(processedCardCodeCount)",
                        result: result//params[Int(processedCardCodeCount)]
                    )
                    processedCardCodeCount += 1
                }

                Timer.scheduledTimer(
                    timeInterval: 0,
                    target: self,
                    selector: #selector(self.checkCardCodeProcessing),
                    userInfo: nil,
                    repeats: false
                )
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
        
        let code = self.mathPix.getValue(identifier: "function\(i)")
        let param = self.mathPix.getValue(identifier: "param\(i)")

        output.text = "Processing Parameter \(i + 1):\r\(param.characters.count > 10 ? "Color" : param)"

        let rotation = self.cardList.getRotation(i)
        let hexRect = self.cardList.getHexRect(i)
        let fullRect = self.cardList.getFullRect(i)
        if let fullImage = self.cardGroup.image {
            let cardImage = ImageProcessor.cropCard(image: fullImage, rect: fullRect, hexRect: hexRect, rotation: rotation)

            if self.cardProject.parentClass != nil {
                self.s3Util.upload(
                    image: cardImage,
                    imageType: "full",
                    completion: {
                        s3Url in
                        let identifier = self.puzzleSchool.saveCard(cardGroup: self.cardGroup, imageUrl: s3Url, position: Int(i), code: code, param: param)
                        
                        Timer.scheduledTimer(
                            timeInterval: 0.1,
                            target: self,
                            selector: #selector(self.saveCard),
                            userInfo: [
                                "identifier": identifier as Any,
                                "code": code,
                                "param": param,
                                "cardImage": cardImage,
                                "index": i
                            ],
                            repeats: true
                        )
                    }
                )
            } else {
                Timer.scheduledTimer(
                    timeInterval: 0.1,
                    target: self,
                    selector: #selector(self.saveCard),
                    userInfo: [
                        "identifier": nil,
                        "code": code,
                        "param": param,
                        "cardImage": cardImage,
                        "index": i
                    ],
                    repeats: true
                )

            }
        }
    }

    func saveCard(timer: Timer) {
        let info = timer.userInfo as! NSDictionary

        let identifier = info["identifier"] as? String
        if identifier != nil && self.puzzleSchool.processing(identifier: identifier!) {
            return
        }
        timer.invalidate()
        
        let code = info["code"] as! String
        let param = info["param"] as! String
        let cardImage = info["cardImage"] as! UIImage
        let index = info["index"] as! Int32

        if let context = cardProject.persistedManagedObjectContext {
            context.mr_save({
                (localContext: NSManagedObjectContext!) in
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
                
                if (index == self.processedCardParamCount - 1) {
                    self.cardGroup.isProcessed = true
                    self.completeCardProcessing(context: context)
                } else {
                    self.processCards(i: index + 1)
                }
            })
        }
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
        if let context = self.cardProject.persistedManagedObjectContext {
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

