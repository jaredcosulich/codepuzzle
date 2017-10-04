//
//  MenuViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 6/8/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import UIKit
import MagicalRecord

class MenuViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var projectTitle: UIButton!

    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var rotateLabel: UILabel!
    @IBOutlet weak var rotateLeft: UIButton!
    @IBOutlet weak var rotateRight: UIButton!
    
    @IBOutlet weak var newPhoto: UIButton!
    @IBOutlet weak var loadPhoto: UIButton!
    @IBOutlet weak var changePhoto: UIButton!
    @IBOutlet weak var processPhoto: UIButton!
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    @IBOutlet weak var playProject: UIBarButtonItem!
    
    @IBOutlet weak var deleteProject: UIBarButtonItem!
    
    @IBOutlet weak var editProjectView: UIView!    
    @IBOutlet weak var editProjectLabel: UILabel!
    @IBOutlet weak var editProjectTitle: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var selectedCardGroupIndex = -1
    
    var s3Util: S3Util!
    var cardProject: CardProject!
    
    var addPhoto: String!
    
    let puzzleSchool = PuzzleSchool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        s3Util = S3Util(projectName: cardProject.title, className: cardProject.parentClass?.name)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        projectTitle.setTitle(cardProject.title, for: UIControlState.normal)
        Util.proportionalFont(anyElement: projectTitle, bufferPercentage: nil)

        Util.proportionalFont(anyElement: addPhotoLabel, bufferPercentage: nil)

        editProjectTitle.text = cardProject.title

        loadPhoto.layer.cornerRadius = 6
        Util.proportionalFont(anyElement: loadPhoto, bufferPercentage: 5)

        newPhoto.layer.cornerRadius = 6
        newPhoto.titleLabel?.font = loadPhoto.titleLabel?.font

        changePhoto.layer.cornerRadius = 6
        Util.proportionalFont(anyElement: changePhoto, bufferPercentage: 10)

        processPhoto.layer.cornerRadius = 6
        processPhoto.titleLabel?.font = changePhoto.titleLabel?.font

        Util.proportionalFont(anyElement: rotateLabel, bufferPercentage: nil)
        
        rotateLeft.layer.cornerRadius = 6
        rotateLeft.titleLabel?.font = rotateLabel.font

        rotateRight.layer.cornerRadius = 6
        rotateRight.titleLabel?.font = rotateLabel.font

        editProjectView.layer.cornerRadius = 6
        
        Util.proportionalFont(anyElement: editProjectLabel, bufferPercentage: nil)
        
        editProjectTitle.adjustsFontSizeToFitWidth = true
        Util.proportionalFont(anyElement: editProjectTitle, bufferPercentage: 5)
        editProjectTitle.returnKeyType = .done
        editProjectTitle.delegate = self
        
        cancelButton.layer.cornerRadius = 6
        Util.proportionalFont(anyElement: cancelButton, bufferPercentage: 8)
        
        saveButton.layer.cornerRadius = 6
        saveButton.titleLabel?.font = cancelButton.titleLabel?.font
        
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
        Util.proportionalFont(anyElement: cell!, bufferPercentage: 20)
        
        if (cardGroup.isProcessed) {
            cell?.detailTextLabel?.text = "\(cardGroup.cards.count) Cards"
        } else  {
            cell?.detailTextLabel?.text = "Not Yet Processed"
        }
//        Util.proportionalFont(anyElement: cell!.detailTextLabel!, bufferPercentage: 2)
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
    
    func textFieldShouldReturn(_ sender: UITextField) -> Bool {
        editProjectTitle.resignFirstResponder()
        return true
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
        
        rotateLabel.isHidden = false
        rotateRight.isHidden = false
        rotateLeft.isHidden = false
        processPhoto.isHidden = false
        changePhoto.isHidden = false
        addPhotoLabel.isHidden = true
        newPhoto.isHidden = true
        loadPhoto.isHidden = true
    }
    
    func hidePhoto() {
        activityView.stopAnimating()

        rotateLabel.isHidden = true
        rotateRight.isHidden = true
        rotateLeft.isHidden = true
        processPhoto.isHidden = true
        changePhoto.isHidden = true
        imageView.isHidden = true

        
        addPhotoLabel.isHidden = false
        
        newPhoto.isHidden = false
        loadPhoto.isHidden = false
    }
    
    @IBAction func deleteProjectButton(_ sender: UIBarButtonItem) {
        let deleteAlert = UIAlertController(title: "Delete Project", message: "Do you want to delete this project?", preferredStyle: UIAlertControllerStyle.alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        deleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            let context = self.cardProject.persistedManagedObjectContext!
            context.mr_save({
                (localContext: NSManagedObjectContext!) in
                self.cardProject.mr_deleteEntity(in: context)
            }, completion: {
                (MRSaveCompletionHandler) in
                context.mr_saveToPersistentStoreAndWait()
                self.performSegue(withIdentifier: "delete-project-segue", sender: nil)
            })
        }))
        
        present(deleteAlert, animated: true, completion: nil)
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
        editProjectView.alpha = 0.0
        editProjectView.isHidden = false

        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.editProjectView.alpha = 1.0
            }
        )

        editProjectTitle.becomeFirstResponder()
    }
    
    @IBAction func saveProjectTitle(_ sender: UIButton) {
        self.cardProject.persistedManagedObjectContext.mr_save({
            (localContext: NSManagedObjectContext!) in
                self.cardProject.title = self.editProjectTitle.text!
        }, completion: {
            (MRSaveCompletionHandler) in
            self.cardProject.persistedManagedObjectContext.mr_saveToPersistentStoreAndWait()
        })
        projectTitle.titleLabel?.text = editProjectTitle.text!
        
        closeEditProject()
    }
    
    @IBAction func cancelEditProject(_ sender: UIButton) {
        editProjectTitle.text = cardProject.title
        closeEditProject()
    }
    
    func closeEditProject() {
        editProjectTitle.resignFirstResponder()
        
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.editProjectView.alpha = 0.0
            }, completion: { (position) in
                self.editProjectView.isHidden = true
            }
        )
    }

    @IBAction func playButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "execution-segue", sender: nil)
    }

    @IBAction func processPhoto(_ sender: UIButton) {
        s3Util.upload(
            image: cardProject.cardGroups[selectedCardGroupIndex].image!,
            imageType: "full",
            completion: {
                s3Url in
                if self.cardProject.parentClass != nil {
                    let identifier = self.puzzleSchool.saveGroup(cardProject: self.cardProject, imageUrl: s3Url)
                
                    Timer.scheduledTimer(
                        withTimeInterval: 0.1,
                        repeats: true,
                        block: {
                            (timer) in
                            if self.puzzleSchool.processing(identifier: identifier) {
                                return
                            }
                            timer.invalidate()
                            
                            let groupId = self.puzzleSchool.results[identifier]!!
                            self.cardProject.cardGroups[self.selectedCardGroupIndex].id = groupId
                            self.performSegue(withIdentifier: "processing-segue", sender: nil)
                        }
                    )
                    //processing-segue
                } else {
                    self.performSegue(withIdentifier: "processing-segue", sender: nil)
                }
            }
        )
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

