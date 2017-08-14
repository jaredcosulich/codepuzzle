//
//  MenuViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 6/8/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var projectTitle: UILabel!
    
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var rotateLeft: UIButton!
    
    @IBOutlet weak var rotateRight: UIButton!
    
    @IBOutlet weak var newPhoto: UIButton!
    @IBOutlet weak var loadPhoto: UIButton!
    @IBOutlet weak var changePhoto: UIButton!
    @IBOutlet weak var processPhoto: UIButton!
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    @IBOutlet weak var editTitle: UIButton!
    @IBOutlet weak var playProject: UIButton!
    @IBOutlet weak var deleteProject: UIButton!
    @IBOutlet weak var methodOutput: UILabel!
    
    @IBOutlet weak var editProjectView: UIView!    
    @IBOutlet weak var editProjectTitle: UITextField!

    var selectedCardGroupIndex: Int!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    @IBOutlet weak var cardGroupView: UIScrollView!
    @IBOutlet weak var cardGroupImageView: UIImageView!
    
    let s3Util = S3Util()
    
    var cardProject: CardProject!
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        projectTitle.text = cardProject.title
        editProjectTitle.text = cardProject.title
        
        cardGroupView.minimumZoomScale = 1.0
        cardGroupView.maximumZoomScale = 6.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return cardGroupImageView
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "Cell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
        
        let cardGroup = cardProject.cardGroups[indexPath.row]
        cell?.textLabel?.text = "Card Photo \(indexPath.row + 1)"
        cell?.detailTextLabel?.text = "\(cardGroup.cards.count) Cards"
        cell?.imageView?.image = cardGroup.image
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            cardProject.deleteCardGroup(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        selectedCardGroupIndex = indexPath.row
        showCardGroup(cardGroup: cardProject.cardGroups[selectedCardGroupIndex])
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return cardProject.cardGroups.count
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
        rotateRight.isHidden = false
        rotateLeft.isHidden = false
        processPhoto.isHidden = false
        changePhoto.isHidden = false
        
        addPhotoLabel.isHidden = true
        
        editTitle.isHidden = true
        playProject.isHidden = true
        deleteProject.isHidden = true
        newPhoto.isHidden = true
        loadPhoto.isHidden = true
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "processing-segue" {
            _ = cardProject.addCardGroup(image: imageView.image!)
            let dvc = segue.destination as! ProcessingViewController
            dvc.cardProject = cardProject
            dvc.selectedIndex = cardProject.cardGroups.count - 1
        } else if segue.identifier == "execution-segue" {
            let dvc = segue.destination as! ExecutionViewController
            dvc.cardProject = cardProject
        }
    }
    
    @IBAction func changePhotoButton(_ sender: UIButton) {
        rotateRight.isHidden = true
        rotateLeft.isHidden = true
        processPhoto.isHidden = true
        changePhoto.isHidden = true
        imageView.isHidden = true
        
        addPhotoLabel.isHidden = false
        
        editTitle.isHidden = false
        playProject.isHidden = false
        deleteProject.isHidden = false
        
        newPhoto.isHidden = false
        loadPhoto.isHidden = false
    }
    
    @IBAction func processbutton(_ sender: UIButton) {
    }     
    
    @IBAction func deleteProjectButton(_ sender: UIButton) {
        cardProject.delete()
        performSegue(withIdentifier: "delete-project-segue", sender: nil)
    }
    
    func resizeView(image: UIImage) {
        let viewSize = imageView.bounds.size
        if (viewSize.width > image.size.width || viewSize.height > image.size.height) {
            imageView.contentMode = UIViewContentMode.center
        } else {
            imageView.contentMode = UIViewContentMode.scaleAspectFit
        }
    }
    
    @IBAction func editProjectTitleButton(_ sender: UIButton) {
        editProjectView.isHidden = false
    }
    
    @IBAction func saveProjectTitle(_ sender: UIButton) {
        cardProject.title = editProjectTitle.text!
        projectTitle.text = editProjectTitle.text!
        editProjectView.isHidden = true
    }
    
    @IBAction func cancelEditProject(_ sender: UIButton) {
        editProjectTitle.text = cardProject.title
        editProjectView.isHidden = true
    }
    
    func showCardGroup(cardGroup: CardGroup) {
        cardGroupImageView.image = cardGroup.processedImage
        blurEffectView.isHidden = false
    }
    
    @IBAction func playButton(_ sender: UIButton) {
        performSegue(withIdentifier: "execution-segue", sender: nil)
    }
    
    @IBAction func closeCardGroupPhotoView(_ sender: UIButton) {
        blurEffectView.isHidden = true
    }
    @IBAction func deleteCardGroupButton(_ sender: UIButton) {
        cardProject.deleteCardGroup(at: selectedCardGroupIndex)
    }
}

