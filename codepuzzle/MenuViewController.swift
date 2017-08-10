//
//  MenuViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 6/8/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var projectTitle: UILabel!
    
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var rotateLeft: UIButton!
    
    @IBOutlet weak var rotateRight: UIButton!
    
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    @IBOutlet weak var methodOutput: UILabel!
    
    let s3Util = S3Util()
    
    var cardProject: CardProject!
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        projectTitle.text = cardProject.title
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
    
    func photoSaved() {
        methodOutput.text = "Photo Saved!"
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        let normalized = ImageProcessor.normalize(image: image)
        resizeView(image: normalized)
        imageView.image = normalized
        imageView.isHidden = false
        rotateLeft.isHidden = false
        rotateRight.isHidden = false
        addPhotoLabel.isHidden = true
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "processing-segue" {
            _ = cardProject.addCardGroup(image: imageView.image!)
            let dvc = segue.destination as! ProcessingViewController
            dvc.cardProject = cardProject
        }
    }
    
    @IBAction func processbutton(_ sender: UIButton) {
    }     
    
    func resizeView(image: UIImage) {
        let viewSize = imageView.bounds.size
        if (viewSize.width > image.size.width || viewSize.height > image.size.height) {
            imageView.contentMode = UIViewContentMode.center
        } else {
            imageView.contentMode = UIViewContentMode.scaleAspectFit
        }
    }
    
}

