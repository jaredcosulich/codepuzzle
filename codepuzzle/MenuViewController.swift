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

    @IBOutlet weak var cardsExplanation: UILabel!

    @IBOutlet weak var getCardsButton: UIButton!
    
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
        
        getCardsButton.layer.cornerRadius = 6
        getCardsButton.titleLabel?.font = loadPhoto.titleLabel?.font

        Util.proportionalFont(anyElement: cardsExplanation, bufferPercentage: nil)
        if cardProject.cardGroups.count > 0 {
            cardsExplanation.isHidden = true
            getCardsButton.isHidden = true
            tableView.isHidden = false
        }
        

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
                timeInterval: 0,
                target: self,
                selector: #selector(initAddPhoto),
                userInfo: nil,
                repeats: false
            )
        }
    }
    
    func initAddPhoto() {
        if self.addPhoto == "take" {
            self.newphotobutton(self.newPhoto)
        } else if self.addPhoto == "library" {
            self.photolibraryaction(self.loadPhoto)
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
//        cell?.textLabel?.font = cell?.textLabel?.font.withSize(24)
        
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
            performSegue(withIdentifier: "select-segue", sender: nil)
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
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
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

        let normalized = ImageProcessor.normalize(image: image)
        resizeView(image: normalized)
        
        saveCardGroup(image: normalized, completion: { self.showPhoto(activity: false) })

        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changePhotoButton(_ sender: UIButton) {
        hidePhoto()
    }
    
    func showPhotoImmediately() {
        showPhoto(activity: false)
    }
    
    func showPhoto(activity: Bool) {
        if (activity) {
            activityView.startAnimating()
            imageView.isHidden = true
        } else {
            print("\(cardProject.cardGroups.count) -> \(selectedCardGroupIndex)")
            if cardProject.cardGroups[selectedCardGroupIndex].image == nil {
                showPhoto(activity: true)
                
                Timer.scheduledTimer(
                    timeInterval: 1,
                    target: self,
                    selector: #selector(showPhotoImmediately),
                    userInfo: nil,
                    repeats: false
                )
                
                return
            }
            activityView.stopAnimating()
            let cardImage = cardProject.cardGroups[selectedCardGroupIndex].image!
            imageView.image = ImageProcessor.scale(image: cardImage, view: imageView)
            imageView.isHidden = false

            rotateLabel.isHidden = false
            rotateRight.isHidden = false
            rotateLeft.isHidden = false
            processPhoto.isHidden = false
            changePhoto.isHidden = false
            addPhotoLabel.isHidden = true
        }
        
        newPhoto.isHidden = true
        loadPhoto.isHidden = true
        tableView.isHidden = true
        getCardsButton.isHidden = true
        cardsExplanation.isHidden = true
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

        if cardProject.cardGroups.count > 0 && cardProject.cardGroups.first!.isProcessed {
            tableView.isHidden = false
        } else {
            getCardsButton.isHidden = false
            cardsExplanation.isHidden = false
        }
    }
    
    @IBAction func deleteProjectButton(_ sender: UIBarButtonItem) {
        let deleteAlert = UIAlertController(title: "Delete Project", message: "Do you want to delete this project?", preferredStyle: UIAlertControllerStyle.alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        deleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            if let context = self.cardProject.persistedManagedObjectContext {
                context.mr_save({
                    (localContext: NSManagedObjectContext!) in
                    self.cardProject.mr_deleteEntity(in: context)
                }, completion: {
                    (MRSaveCompletionHandler) in
                    context.mr_saveToPersistentStoreAndWait()
                    self.performSegue(withIdentifier: "delete-project-segue", sender: nil)
                })
            }
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

        if #available(iOS 10.0, *) {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.5,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    self.editProjectView.alpha = 1.0
                }
            )
        } else {
            self.editProjectView.alpha = 1.0
        }

        editProjectTitle.becomeFirstResponder()
    }
    
    @IBAction func saveProjectTitle(_ sender: UIButton) {
        if let titleText = self.editProjectTitle.text {
            self.cardProject.persistedManagedObjectContext.mr_save({
                (localContext: NSManagedObjectContext!) in
                    self.cardProject.title = titleText
            }, completion: {
                (MRSaveCompletionHandler) in
                self.cardProject.persistedManagedObjectContext.mr_saveToPersistentStoreAndWait()
            })
            projectTitle.titleLabel?.text = titleText
        }
        
        closeEditProject()
    }
    
    @IBAction func cancelEditProject(_ sender: UIButton) {
        editProjectTitle.text = cardProject.title
        closeEditProject()
    }
    
    func closeEditProject() {
        editProjectTitle.resignFirstResponder()
        
        if #available(iOS 10.0, *) {
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
        } else {
            self.editProjectView.alpha = 0.0
            self.editProjectView.isHidden = true
        }
    }

    @IBAction func playButton(_ sender: UIBarButtonItem) {
        if cardProject.cardGroups.count == 0 {
            let noGroupsAlert = UIAlertController(title: "Add A Photo", message: "Please add at least one photo and click \"Use Photo\" to process it", preferredStyle: UIAlertControllerStyle.alert)
            
            noGroupsAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            present(noGroupsAlert, animated: true, completion: nil)
        } else if !cardProject.cardGroups.last!.isProcessed {
            performSegue(withIdentifier: "select-segue", sender: nil)
        } else {
            performSegue(withIdentifier: "execution-segue", sender: nil)
        }
    }

    @IBAction func processPhoto(_ sender: UIButton) {
        performSegue(withIdentifier: "select-segue", sender: nil)
    }
    
    func saveCardGroup(image: UIImage, completion: @escaping () -> Void) {
        if let context = self.cardProject.persistedManagedObjectContext {
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
    }
    
    
    @IBAction func getCards(_ sender: UIButton) {
        if let url = URL(string: "http://www.thecodepuzzle.com/") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                let urlAlert = UIAlertController(title: "Get Cards", message: "Please visit \(url.absoluteString) in a web browser to find the necessary cards.", preferredStyle: UIAlertControllerStyle.alert)
                
                urlAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        imageView.removeFromSuperview()
        tableView.removeFromSuperview()
        
        if segue.identifier == "select-segue" {
            let dvc = segue.destination as! SelectCardsViewController
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

