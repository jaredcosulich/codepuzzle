//
//  FirstViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 6/8/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var methodOutput: UILabel!
    
    @IBOutlet weak var drawingView: UIImageView!
    
    @IBOutlet weak var speedSegment: UISegmentedControl!
    
    
    let s3Util = S3Util()
    let mathPix = MathPix()
    var functions: Functions!
    var index = Int32(0)
    var showTimer = Timer()
    var timer = Timer()
    var rotation = Int32(0)
    var speed = 1500.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // REMOVE THIS FOR MOST IMAGES
        imageView.image = ImageProcessor.rotate(image: imageView.image!, left: true)
        imageView.image = ImageProcessor.rotate(image: imageView.image!, left: true)
        imageView.image = ImageProcessor.rotate(image: imageView.image!, left: true)
        imageView.image = ImageProcessor.rotate(image: imageView.image!, left: true)
        
//        drawingView.contentMode = .bottomLeft
        
//        functions = Functions(uiImageView: drawingView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func newphotobutton(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func photolibraryaction(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func rotateleft(_ sender: UIButton) {
        imageView.image = ImageProcessor.rotate(image: imageView.image!, left: true)
    }

    @IBAction func rotateright(_ sender: UIButton) {
        imageView.image = ImageProcessor.rotate(image: imageView.image!, left: false)
    }

    @IBAction func savephotobutton(_ sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(imageView.image!, photoSaved(), nil, nil)
    }
    
    
//    @IBAction func speedbutton(_ sender: UISegmentedControl) {
//        switch (sender.selectedSegmentIndex) {
//        case 0:
//            speed = 200.0
//        case 2:
//            speed = 5000.0
//        default:
//            speed = 1500.0
//        }
//        initShowTimer()
//    }
    
    func photoSaved() {
        methodOutput.text = "Photo Saved!"
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        let normalized = ImageProcessor.normalize(image: image)
        resizeView(image: normalized)
        imageView.image = normalized
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "processing-segue" {
            let dvc = segue.destination as! ProcessingViewController
            dvc.image = imageView.image
        }
    }
    
    @IBAction func processbutton(_ sender: UIButton) {
//        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//
//        let processingController : ProcessingViewController = storyboard.instantiateViewController(withIdentifier: "processing") as! ProcessingViewController
//        
//        processingController.image = imageView.image
        
//        print("IMAGE VIEW: \(processingController.image) \(processingController.imageView)")
//        processingController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
//        self.present(processingController, animated: true, completion: nil)
        
        
//        methodOutput.text = "Processing..."
//        Timer.scheduledTimer(
//            timeInterval: 0.5,
//            target: self,
//            selector: #selector(process),
//            userInfo: nil,
//            repeats: false
//        )
    }
     
//    func process() {
//        speedSegment.isHidden = false
//        drawingView.isHidden = false
//
//        cardList.clear()
//
//        OpenCVWrapper.process(imageView.image, cardList)
//        
//        imageView.image = ImageProcessor.borderCards(image: imageView.image!, cardList: cardList)
//        return
//
//        for i in 0..<cardList.count() {
////            s3Util.upload(
////                image: cardList.getFunctionImage(index),
////                identifier: "function\(i)",
////                projectTimestamp: "TEST"
////            )
////            mathPix.processImage(
////                image: cardList.getFunctionImage(i)!,
////                identifier: "function\(i)"
////            )
////            mathPix.processImage(
////                image: cardList.getParamImage(Int32(i))!,
////                identifier: "param\(i)"
////            )
//        }
//        
//        timer.invalidate() // just in case this button is tapped multiple times
//        
//        // start the timer
//        timer = Timer.scheduledTimer(
//            timeInterval: 1,
//            target: self,
//            selector: #selector(checkCardProcessing),
//            userInfo: nil,
//            repeats: true
//        )
//    }
//    
//    func checkCardProcessing() {
//        if (!mathPix.processing()) {
//            timer.invalidate()
//            
//            index = 0
//            
//            showCard()
//            initShowTimer()
//        } else {
//            methodOutput.text = "Still Processing..."
//        }
//    }
//    
//    func initShowTimer() {
//        showTimer.invalidate()
//        
//        // start the timer
//        showTimer = Timer.scheduledTimer(
//            timeInterval: TimeInterval(speed / 1000.0),
//            target: self,
//            selector: #selector(showCard),
//            userInfo: nil,
//            repeats: true
//        )
//        showCard()
//    }
//    
//    func showCard() {
//        let cardCount = cardList.count()
//        if (cardCount == 0) {
////            imageView.image = OpenCVWrapper.cannify(imageView.image!)
//            methodOutput.text  = "No Cards Found!"
//            timer.invalidate()
//            return
//        } else if (index >= cardCount) {
////            imageView.image = cardList.analyzedImage;
//            methodOutput.text  = "All cards displayed. Total: \(cardCount)"
//            timer.invalidate()
//            return
//        }
//
//        let displayImage = cardList.getFullImage(index)!
//        resizeView(image: displayImage)
//        imageView.image = displayImage
//        
////        let tesseract = G8Tesseract()
////        tesseract.language = "eng+fra"
////        tesseract.engineMode = .tesseractOnly
////        tesseract.pageSegmentationMode = .auto
////        tesseract.maximumRecognitionTime = 60.0
////        tesseract.image = cardList.getFunctionImage(index)!.g8_blackAndWhite()
////        tesseract.recognize()
////        let code = tesseract.recognizedText!
////        methodOutput.text  = "Method: \(tesseract.recognizedText)"
//
//        let codes: [String] = ["A 1", "A 3", "A 1", "A 4", "A 2", "A 3", "A 2", "A 4", "A 1"]
//        let params: [String] = ["50", "45", "35.355", "90", "35.355", "45", "50", "90", "50"]
//        let code = codes[Int(index)]
//        let param = params[Int(index)]
//
////        let code = mathPix.getValue(identifier: "function\(index)")
////        let param = mathPix.getValue(identifier: "param\(index)")
//        methodOutput.text  = functions.signature(code: code, param: param)
//        
//        functions.execute(code: code, param: param)
////
//        index += 1
//    }
    
    func resizeView(image: UIImage) {
        let viewSize = imageView.bounds.size
        if (viewSize.width > image.size.width || viewSize.height > image.size.height) {
            imageView.contentMode = UIViewContentMode.center
        } else {
            imageView.contentMode = UIViewContentMode.scaleAspectFit
        }
    }
    
//    func drawRectangleOnImage(image: UIImage, rect: CGRect) -> UIImage? {
//        let opaque = false
//        let scale: CGFloat = 0
//        UIGraphicsBeginImageContextWithOptions(image.size, opaque, scale)
//        guard let context = UIGraphicsGetCurrentContext() else { return nil }
//        
//        image.draw(at: CGPoint(x: 0, y: 0))
//        
//        context.setStrokeColor(UIColor.red.cgColor)
//        context.setLineWidth(5.0)
//        
//        context.stroke(rect)
//        
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return newImage
//    }

}

