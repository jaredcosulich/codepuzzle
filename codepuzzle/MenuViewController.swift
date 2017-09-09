//
//  MenuViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 6/8/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import UIKit
import MagicalRecord

class MenuViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var projectTitle: UILabel!
    
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var rotateLeft: UIButton!
    
    @IBOutlet weak var rotateRight: UIButton!
    
    @IBOutlet weak var newPhoto: UIButton!
    @IBOutlet weak var loadPhoto: UIButton!
    @IBOutlet weak var changePhoto: UIButton!
    @IBOutlet weak var processPhoto: UIButton!
    @IBOutlet weak var analyzePhoto: UIButton!
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    @IBOutlet weak var editTitle: UIButton!
    @IBOutlet weak var playProject: UIButton!
    @IBOutlet weak var deleteProject: UIButton!
    
    @IBOutlet weak var editProjectView: UIView!    
    @IBOutlet weak var editProjectTitle: UITextField!

    var selectedCardGroupIndex = -1
    
    let s3Util = S3Util()
    
    var cardProject: CardProject!
    
    var addPhoto: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        projectTitle.text = cardProject.title
        editProjectTitle.text = cardProject.title
        
        for i in 0..<cardProject.cardGroups.count {
            let cardGroup = cardProject.cardGroups[i]
            if (!cardGroup.isProcessed) {
                if (cardGroup.image != nil) {
                    showPhoto(activity: true)
                    selectedCardGroupIndex = i
                    showPhoto(activity: false)
                } else {
                    selectedCardGroupIndex = i
                }
                break
            }
        }
        
        info()
        
        if (addPhoto != nil) {
            Timer.scheduledTimer(
                withTimeInterval: 0,
                repeats: false,
                block: {
                    (Timer) in
                    if self.addPhoto == "take" {
                        self.newphotobutton(self.newPhoto)
                    } else if self.addPhoto == "library" {
                        self.photolibraryaction(self.loadPhoto)
                    }
                }
            )
        }
    }
    
    func info() {
        var codes = [String]()
        var params = [String]()
        for cardGroup in cardProject.cardGroups {
            for card in cardGroup.cards {
                codes.append("\"\(card.code)\"")
                params.append("\"\(card.param)\"")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if (cardGroup.isProcessed) {
            cell?.detailTextLabel?.text = "\(cardGroup.cards.count) Cards"
        } else  {
            cell?.detailTextLabel?.text = "Not Yet Processed"
        }
        cell?.imageView?.image = cardGroup.image
        
        return cell!
    }
    
    func tableView(_
        tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = self.cardProject.persistedManagedObjectContext!
            context.mr_save({
                (localContext: NSManagedObjectContext!) in
                let cardGroup = self.cardProject.cardGroups[indexPath.row]
                cardGroup.mr_deleteEntity(in: context)
            }, completion: {
                (MRSaveCompletionHandler) in
                self.selectedCardGroupIndex = -1
                context.mr_saveToPersistentStoreAndWait()
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            })
        }
    }
    
    func tableView(_
        tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        selectedCardGroupIndex = indexPath.row
        if (cardProject.cardGroups[selectedCardGroupIndex].isProcessed) {
            performSegue(withIdentifier: "debug-segue", sender: nil)
        } else {
            performSegue(withIdentifier: "processing-segue", sender: nil)            
        }
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        var cardGroupCount = cardProject.cardGroups.count
        if (cardGroupCount > 0 && !cardProject.cardGroups.last!.isProcessed) {
            cardGroupCount -= 1
        }
        return cardGroupCount
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
    
    @IBAction func photolibraryaction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func rotateleft(_ sender: UIButton) {
        showPhoto(activity: true)
        let cardImage = cardProject.cardGroups[selectedCardGroupIndex].image!

        saveCardGroup(
            image: ImageProcessor.rotate(image: cardImage, degrees: CGFloat(-90)),
            completion: { self.showPhoto(activity: false) }
        )
    }

    @IBAction func rotateright(_ sender: UIButton) {
        showPhoto(activity: true)
        let cardImage = cardProject.cardGroups[selectedCardGroupIndex].image!

        saveCardGroup(
            image: ImageProcessor.rotate(image: cardImage, degrees: CGFloat(90)),
            completion: { self.showPhoto(activity: false) }
        )
    }

//    @IBAction func savephotobutton(_ sender: UIButton) {
//        UIImageWriteToSavedPhotosAlbum(imageView.image!, photoSaved(), nil, nil)
//    }
    
//    func photoSaved() {
//        methodOutput.text = "Photo Saved!"
//    }

    func imagePickerController(_
        picker: UIImagePickerController,
                               didFinishPickingImage image: UIImage!,
                               editingInfo: [NSObject : AnyObject]!) {
        
        showPhoto(activity: true)
//        var start = NSDate()

        let normalized = ImageProcessor.normalize(image: image)
        
//        print("Time 1 \(start.timeIntervalSinceNow) seconds");
//        start = NSDate()
        
        resizeView(image: normalized)
        
//        print("Time 2 \(start.timeIntervalSinceNow) seconds");
//        start = NSDate()
        
        saveCardGroup(image: normalized, completion: { self.showPhoto(activity: false) })
        
        self.dismiss(animated: true, completion: nil)

//        print("Time 3 \(start.timeIntervalSinceNow) seconds");
}
    
    @IBAction func changePhotoButton(_ sender: UIButton) {
        hidePhoto()
    }
    
    func showPhoto(activity: Bool) {
        if (activity) {
            activityView.startAnimating()
            imageView.isHidden = true
        } else {
            activityView.stopAnimating()
            let cardImage = cardProject.cardGroups[selectedCardGroupIndex].image!
            imageView.image = ImageProcessor.scale(image: cardImage, view: imageView)
            imageView.isHidden = false
        }
        
        rotateRight.isHidden = false
        rotateLeft.isHidden = false
        analyzePhoto.isHidden = false
        processPhoto.isHidden = false
        changePhoto.isHidden = false
        addPhotoLabel.isHidden = true
        editTitle.isHidden = true
        playProject.isHidden = true
        deleteProject.isHidden = true
        newPhoto.isHidden = true
        loadPhoto.isHidden = true
    }
    
    func hidePhoto() {
        activityView.stopAnimating()

        rotateRight.isHidden = true
        rotateLeft.isHidden = true
        analyzePhoto.isHidden = true
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
    
    @IBAction func deleteProjectButton(_ sender: UIButton) {
//        cardProject.delete()
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
        self.cardProject.persistedManagedObjectContext.mr_save({
            (localContext: NSManagedObjectContext!) in
                self.cardProject.title = self.editProjectTitle.text!
        }, completion: {
            (MRSaveCompletionHandler) in
            self.cardProject.persistedManagedObjectContext.mr_saveToPersistentStoreAndWait()
        })
        projectTitle.text = editProjectTitle.text!
        editProjectView.isHidden = true
    }
    
    @IBAction func cancelEditProject(_ sender: UIButton) {
        editProjectTitle.text = cardProject.title
        editProjectView.isHidden = true
    }

    @IBAction func playButton(_ sender: UIButton) {
        performSegue(withIdentifier: "execution-segue", sender: nil)
    }
    
    func saveCardGroup(image: UIImage, completion: @escaping () -> Void) {
        let context = self.cardProject.persistedManagedObjectContext!

        context.mr_save({
            (localContext: NSManagedObjectContext!) in
            var editingCardGroup: CardGroup!
            
            if self.selectedCardGroupIndex == -1 {
                editingCardGroup = CardGroup.mr_createEntity(in: context)
                editingCardGroup?.cardProject = self.cardProject
            } else {
                editingCardGroup = self.cardProject.cardGroups[self.selectedCardGroupIndex]
            }
            editingCardGroup?.image = image
        }, completion: {
            (MRSaveCompletionHandler) in
            self.selectedCardGroupIndex = self.cardProject.cardGroups.count - 1
            context.mr_saveToPersistentStoreAndWait()
            completion()
        })
    }

    @IBAction func homeButton(_ sender: UIButton) {
        performSegue(withIdentifier: "home-segue", sender: nil)
    }
    
    @IBAction func debugImage(_ sender: UIButton) {
        performSegue(withIdentifier: "debug-segue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        imageView.removeFromSuperview()
        tableView.removeFromSuperview()
        
        if segue.identifier == "processing-segue" {
            let dvc = segue.destination as! ProcessingViewController
            dvc.selectedIndex = (selectedCardGroupIndex > -1 ? selectedCardGroupIndex : 0)
            dvc.cardProject = cardProject
        } else if segue.identifier == "execution-segue" {
            let dvc = segue.destination as! ExecutionViewController
            dvc.cardProject = cardProject
        } else if segue.identifier == "debug-segue" {
            let dvc = segue.destination as! DebugViewController
            dvc.cardProject = cardProject
            if selectedCardGroupIndex > -1 && cardProject.cardGroups[selectedCardGroupIndex].isProcessed {
                dvc.selectedIndex = selectedCardGroupIndex
            } else {
                dvc.selectedIndex = -1
            }
            dvc.image = cardProject.cardGroups[selectedCardGroupIndex].image
        }
    }
    
}

