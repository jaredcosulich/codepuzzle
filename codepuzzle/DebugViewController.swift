
//
//  DebugView.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 8/15/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import UIKit

class DebugViewController: UIViewController, UIScrollViewDelegate {
    
    var cardProject: CardProject!
    @IBOutlet weak var cardGroupView: UIScrollView!
    @IBOutlet weak var cardGroupImageView: UIImageView!

    @IBOutlet weak var output: UILabel!
    
    let cardList = CardListWrapper()!
    let tesseract = G8Tesseract()

    var image: UIImage!
    
    var timer = Timer()
    var paramIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        cardGroupView.minimumZoomScale = 1.0
        cardGroupView.maximumZoomScale = 6.0
        
        cardGroupImageView.image = image
        
        tesseract.language = "eng+fra"
        tesseract.engineMode = .tesseractOnly
        tesseract.pageSegmentationMode = .auto
        tesseract.maximumRecognitionTime = 60.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return cardGroupImageView
    }
    
    @IBAction func openCVButton(_ sender: UIButton) {
        cardGroupImageView.image = OpenCVWrapper.debug(image)
    }
    
    func process() {
        OpenCVWrapper.process(image, cardList)
        output.text = "Found: \(cardList.count())"
    }

    @IBAction func fullButton(_ sender: UIButton) {
        process()
        cardGroupImageView.image = ImageProcessor.borderCards(image: image, cardList: cardList, index: -1, style: "full")
    }

    @IBAction func hexButton(_ sender: UIButton) {
        process()
        cardGroupImageView.image = ImageProcessor.borderCards(image: image, cardList: cardList, index: -1, style: "hex")
    }
    
    @IBAction func functionButton(_ sender: UIButton) {
        process()
        cardGroupImageView.image = ImageProcessor.borderCards(image: image, cardList: cardList, index: -1, style: "function")
    }

    @IBAction func paramButton(_ sender: UIButton) {
        process()
        cardGroupImageView.image = ImageProcessor.borderCards(image: image, cardList: cardList, index: -1, style: "param")
    }
    
    @IBAction func individualParams(_ sender: UIButton) {
        process()
        paramIndex = 0
        timer.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(showNextParam),
            userInfo: nil,
            repeats: true
        )
        showNextParam()
    }
    
    func showNextParam() {
        let rotation = cardList.getRotation(Int32(paramIndex))
        let functionRect = cardList.getFunctionRect(Int32(paramIndex))
        tesseract.image = ImageProcessor.cropCard(image: image, rect: functionRect, rotation: rotation).g8_blackAndWhite()
        tesseract.recognize()
        cardGroupImageView.image = tesseract.image
//        output.text = "Code: \(tesseract.recognizedText!)"
        paramIndex += 1
        if (Int32(paramIndex) >= cardList.count()) {
            timer.invalidate()
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cancel-debug-segue" {
            let dvc = segue.destination as! MenuViewController
            dvc.cardProject = cardProject
        }
    }
}
