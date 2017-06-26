//
//  FirstViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 6/8/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var methodOutput: UILabel!
    
    let cardList = CardListWrapper()!
    var index = Int32(0)
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        UIView.animate(withDuration: 0.5, animations: {
            self.imageView.transform = CGAffineTransform(rotationAngle: (-90.0 * CGFloat(Double.pi)) / 180.0)
        })
    }

    @IBAction func rotateright(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, animations: {
            self.imageView.transform = CGAffineTransform(rotationAngle: (90.0 * CGFloat(Double.pi)) / 180.0)
        })
    }

    @IBAction func savephotobutton(_ sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(imageView.image!, photoSaved(), nil, nil)
    }
    
    func photoSaved() {
        methodOutput.text = "Photo Saved!"
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        imageView.image = image
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func processbutton(_ sender: UIButton) {
        OpenCVWrapper.process(imageView.image, cardList)
        showCard()

        timer.invalidate() // just in case this button is tapped multiple times
        
        // start the timer
        timer = Timer.scheduledTimer(
            timeInterval: 3,
            target: self,
            selector: #selector(showCard),
            userInfo: nil,
            repeats: true
        )
    }
    
    func showCard() {
        let cardCount = cardList.count()
        if (cardCount == 0) {
            methodOutput.text  = "No Cards Found!"
            timer.invalidate()
            return
        } else if (index >= cardCount) {
            methodOutput.text  = "All cards displayed. Total: \(cardCount)"
            timer.invalidate()
            return
        }

//        print("")
//        print("")
        imageView.image = cardList.getFullImage(index)!
        
        let tesseract = G8Tesseract()
        tesseract.language = "eng+fra"
        tesseract.engineMode = .tesseractOnly
        tesseract.pageSegmentationMode = .auto
        tesseract.maximumRecognitionTime = 60.0
        tesseract.image = cardList.getFunctionImage(index)?.g8_blackAndWhite()
        tesseract.recognize()
        methodOutput.text  = "Method: \(tesseract.recognizedText)"
//        print("TESSERACT: \(tesseract.recognizedText)")

//        let imageData = UIImagePNGRepresentation((cardList.getFunctionImage(index))!)! as NSData
//        MathPix.processSingleImage(imageData : imageData)
        
        index += 1
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

