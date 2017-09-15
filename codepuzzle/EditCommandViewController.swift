//
//  EditCommandViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 8/5/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation
import MagicalRecord
import ChromaColorPicker

struct TempCard {
    var cardProject: CardProject!
    var code: String
    var param: String
    var image: UIImage?
    var originalCode: String
    var originalParam: String
    var originalImage: UIImage?
    
    func addToCardGroup(cardGroup: CardGroup, completion: @escaping () -> Void) {
        var newCard: Card!
        cardProject.persistedManagedObjectContext.mr_save({
            (localContext: NSManagedObjectContext!) in
            newCard = Card.mr_createEntity(in: self.cardProject.persistedManagedObjectContext)
            newCard?.cardGroup = cardGroup
            newCard?.code = self.code
            newCard?.param = self.param
            newCard?.image = self.image
            newCard?.originalCode = self.originalCode
            newCard?.originalParam = self.originalParam
            newCard?.originalImage = self.originalImage
            newCard?.error = !Functions.valid(code: self.code, param: self.param)
        }, completion: {
            (MRSaveCompletionHandler) in
            self.cardProject.persistedManagedObjectContext.mr_saveToPersistentStoreAndWait()
            completion()
        })
    }

    func updateCard(card: Card, completion: @escaping () -> Void) {
        cardProject.persistedManagedObjectContext.mr_save({
            (localContext: NSManagedObjectContext!) in
            card.code = self.code
            card.param = self.param
            card.image = self.image
            card.originalCode = self.originalCode
            card.originalParam = self.originalParam
            card.originalImage = self.originalImage
            card.error = !Functions.valid(code: self.code, param: self.param)
        }, completion: {
            (MRSaveCompletionHandler) in
            self.cardProject.persistedManagedObjectContext.mr_saveToPersistentStoreAndWait()
            completion()
        })
    }
}

class EditCommandViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, ChromaColorPickerDelegate {
    
    @IBOutlet weak var functionPicker: UIPickerView!
    
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var paramLabel: UILabel!
    @IBOutlet weak var param: UITextField!
    @IBOutlet weak var cardView: UIImageView!
    
    var errorCard: Bool = false
    
    var uneditedCard: TempCard!
    var newCard: TempCard!
    
    var selectedIndex: Int!
    
    var functionCodes = [String]()
    
    var pickerData = [[String]]()
    
    var cardProject: CardProject!
    
    var selectedCard: Card!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var colorPickerView: UIView!
    
    let colorPicker = ChromaColorPicker(frame: CGRect(x: 50, y: 50, width: 200, height: 200))

    @IBOutlet weak var colorParam: UIView!
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let cards = cardProject.allCards()
        
        var selectedCode: String!
        
        if selectedIndex >= 0 && selectedIndex < cards.count {
            selectedCard = cards[selectedIndex]
            selectedCode = Functions.processedCode(code: selectedCard.code)
            
            if (errorCard) {
                if selectedCode.characters.count == 0 {
                    titleLabel.text = "We were unable to read the function on this card."
                } else {
                    titleLabel.text = "We were unable to read the parameter on this card."
                }
                toolbar.items?.removeAll()
                toolbar.items?.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
                toolbar.items?.append(UIBarButtonItem(title: "Save", style: .plain, target: nil, action: #selector(save)))
                toolbar.items?.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
                
                if (selectedCode.characters.count == 0) {
                    selectedCard.code = "A1"
                }
            }

            param.text = selectedCard.param
            cardView.image = selectedCard.image
            if selectedCard.disabled {
                
            }

            uneditedCard = TempCard(
                cardProject: cardProject,
                code: selectedCard.code,
                param: selectedCard.param,
                image: selectedCard.image!,
                originalCode: selectedCard.originalCode!,
                originalParam: selectedCard.originalParam!,
                originalImage: selectedCard.originalImage!
            )
        } else {
            toolbar.items?.removeAll()
            toolbar.items?.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            toolbar.items?.append(UIBarButtonItem(title: "Save", style: .plain, target: nil, action: #selector(save)))
            toolbar.items?.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            toolbar.items?.append(UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(cancel)))
            toolbar.items?.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))

            newCard = TempCard(
                cardProject: cardProject,
                code: "A1",
                param: "",
                image: nil,
                originalCode: "A1",
                originalParam: "",
                originalImage: nil
            )
            selectedCode = "A1"
            titleLabel.text = "Add Card To Project"
            cardView.image = drawCard(
                image: UIImage(named: selectedCode)!,
                param: nil
            )
        }
        
        functionCodes = Array(Functions.functionInfo.keys).sorted()
        
        var functionNames = [String]()
        for i in 0..<Functions.functionInfo.count {
            let functionCode = functionCodes[i]
            let functionName = Functions.functionInfo[functionCode]!.name
            functionNames.append("\(functionName) (\(functionCode))")
        }
        
        pickerData = [functionNames]
        
        functionPicker.delegate = self
        functionPicker.dataSource = self
        
        param.delegate = self
        
        colorParam.layer.cornerRadius = colorParam.frame.size.height/2;
        colorParam.layer.masksToBounds = true;
        colorParam.layer.borderColor = UIColor.black.cgColor;
        colorParam.layer.borderWidth = 1;
        
        colorPickerView.layer.cornerRadius = colorPickerView.frame.size.height/2;
        colorPickerView.layer.masksToBounds = true;
        colorPickerView.layer.borderColor = UIColor.black.cgColor;
        colorPickerView.layer.borderWidth = 2;
        
        colorPicker.delegate = self //ChromaColorPickerDelegate
        colorPicker.padding = 5
        colorPicker.stroke = 3
        colorPicker.hexLabel.textColor = UIColor.white
        
        colorPickerView.addSubview(colorPicker)
        
        prepareCard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        let param = "\(color)"
        if selectedCard == nil {
            newCard.param = param
        } else {
            selectedCard.param = param
        }
        prepareCard()
        colorPickerView.isHidden = true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerData.count
    }

    func pickerView(_
        pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int
        ) -> Int {
        return pickerData[component].count
    }

    func pickerView(_
        pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int
        ) -> String? {
        return pickerData[component][row]
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int)
    {
        let newCode = functionCodes[row]
        if (selectedCard == nil) {
            let drawnCard = drawCard(
                image: UIImage(named: newCode)!,
                param: param.text!
            )
            newCard.code = newCode
            newCard.param = param.text!
            newCard.image = drawnCard
            newCard.originalCode = newCode
            newCard.originalParam = param.text!
            newCard.originalImage = drawnCard
            cardView.image = drawnCard
        } else if (newCode != selectedCard.code) {
            selectedCard.code = newCode
            selectedCard.param = param.text!
            if (!errorCard) {
                selectedCard.image = drawCard(
                    image: UIImage(named: newCode)!,
                    param: param.text!
                )
                cardView.image = selectedCard.image
            }
            updateSelectedCard()
        }
        
        prepareCard()
    }
    
    func textFieldShouldReturn(_ sender: UITextField) -> Bool {
        param.resignFirstResponder()
        return true
    }
    
    func prepareCard() {
        let cardCode = selectedCard == nil ? newCard.code : selectedCard.code
        let cardParam = selectedCard == nil ? newCard.param : selectedCard.param
        let info = Functions.info(code:  cardCode)
        
        if (info.paramCount == 0) {
            param.isHidden = true
            paramLabel.isHidden = true
        } else {
            param.isHidden = false
            paramLabel.isHidden = false
        }
        
        if (info.color) {
            colorLabel.isHidden = false
            colorParam.isHidden = false
            colorParam.backgroundColor = ImageProcessor.colorFrom(text: cardParam)
            colorPicker.adjustToColor(colorParam.backgroundColor!)
        } else {
            colorLabel.isHidden = true
            colorParam.isHidden = true
        }
        
        for i in 0..<Functions.functionInfo.count {
            if (functionCodes[i] == Functions.processedCode(code: cardCode)) {
                functionPicker.selectRow(i, inComponent: 0, animated: true)
            }
        }
    }
    
    @IBAction func selectColor(_ sender: UIButton) {
        colorPickerView.isHidden = false
    }
    
    
    func updateSelectedCard() {
        if (selectedCard == nil) {
            return
        }
        
        var indexTally = 0
        for cardGroup in cardProject.cardGroups {
            if (indexTally + cardGroup.cards.count) > selectedIndex {
                let card = cardGroup.cards[selectedIndex - indexTally]
                cardProject.persistedManagedObjectContext.mr_save({
                    (localContext: NSManagedObjectContext!) in
                    card.code = self.selectedCard.code
                    card.param = self.selectedCard.param
                    card.image = self.selectedCard.image
                    card.originalCode = self.selectedCard.originalCode
                    card.originalParam = self.selectedCard.originalParam
                    card.originalImage = self.selectedCard.originalImage
                    card.error = !Functions.valid(code: self.selectedCard.code, param: self.selectedCard.param)
                }, completion: {
                    (MRSaveCompletionHandler) in
                    self.cardProject.persistedManagedObjectContext.mr_saveToPersistentStoreAndWait()
                })
                return
            } else {
                indexTally += cardGroup.cards.count
            }
        }
    }

    @IBAction func showParam(_ sender: Any) {
        let code: String!
        
        if (selectedCard != nil) {
            selectedCard.param = param.text!
            code = selectedCard.code
        } else {
            newCard.param = param.text!
            code = newCard.code
        }
        
        if (!errorCard) {
            let newImage = drawCard(
                image: UIImage(named: Functions.processedCode(code: code))!,
                param: param.text
            )
            selectedCard?.image = newImage
            newCard?.image = newImage
            cardView.image = newImage
        }
    }
    
    @IBAction func saveParam(_ sender: Any) {
        showParam(sender: sender)
        updateSelectedCard()
    }
    
    
    @IBAction func revert(_ sender: UIBarButtonItem) {
        param.text = selectedCard.originalParam
        cardView.image = selectedCard.originalImage
        
        var selectedFunctionIndex = -1
        for i in 0..<Functions.functionInfo.count {
            let functionCode = functionCodes[i]
            if (functionCode == selectedCard.originalCode) {
                selectedFunctionIndex = i
            }
        }
        functionPicker.selectRow(selectedFunctionIndex, inComponent: 0, animated: true)

        selectedCard.param = selectedCard.originalParam!
        selectedCard.code = selectedCard.originalCode!
        selectedCard.image = selectedCard.originalImage!
        selectedCard.disabled = false
        prepareCard()
        updateSelectedCard()
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        if (!colorPickerView.isHidden) {
            let param = "\(colorPicker.currentColor)"
            if (selectedCard == nil) {
                newCard.param = param
            } else {
                selectedCard.param = param
            }
        }
        
        if (newCard != nil) {
            newCard.addToCardGroup(cardGroup: cardProject.cardGroups.last!, completion: {
                self.performSegue(withIdentifier: "save-edit-segue", sender: nil)
            })
        } else {
            if (errorCard) {
                let errorIndex = cardProject.allCards().index(where: { (c) -> Bool in c.error })
                
                if (errorIndex != nil) {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let dvc = storyboard.instantiateViewController(withIdentifier: "editCommandViewController") as! EditCommandViewController
                    dvc.cardProject = cardProject
                    dvc.selectedIndex = errorIndex
                    dvc.errorCard = true
                    
                    present(dvc, animated: true, completion: nil)
                    return
                }
            
                selectedIndex = -1
            }

            self.performSegue(withIdentifier: "save-edit-segue", sender: nil)
        }
    }
    
    func drawCard(image: UIImage, param: String?) -> UIImage {
        let textColor = UIColor.black
        let textFont = UIFont(name: "Helvetica", size: 60)!
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            ] as [String : Any]
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        if (param != nil) {
            let x = (image.size.width - CGFloat(36 * param!.characters.count)) / 2
            let textOrigin = CGPoint(x: x, y: 300)
            let rect = CGRect(origin: textOrigin, size: image.size)
            param!.draw(in: rect, withAttributes: textFontAttributes)
        }
            
        let newCardImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newCardImage!
    }
    
    
    @IBAction func deleteCard(_ sender: UIBarButtonItem) {
        let deleteAlert = UIAlertController(title: "Delete Card", message: "Do you want to delete this card?", preferredStyle: UIAlertControllerStyle.alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        deleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            let context = self.cardProject.persistedManagedObjectContext!
            context.mr_save({
                (localContext: NSManagedObjectContext!) in
                if self.selectedCard.originalImage == nil {
                    self.selectedCard.mr_deleteEntity(in: context)
                } else {
                    self.selectedCard.disabled = true
                }
            }, completion: {
                (MRSaveCompletionHandler) in
                context.mr_saveToPersistentStoreAndWait()
                self.performSegue(withIdentifier: "save-edit-segue", sender: nil)
            })
        }))
        
        present(deleteAlert, animated: true, completion: nil)
    }
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        if (uneditedCard == nil) {
            self.performSegue(withIdentifier: "cancel-edit-segue", sender: nil)
        } else {
            uneditedCard.updateCard(card: selectedCard, completion: {
                self.performSegue(withIdentifier: "cancel-edit-segue", sender: nil)
            })
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (newCard != nil) {
            newCard.image = nil
            newCard.originalImage = nil
        }
        
        if (uneditedCard != nil) {
            uneditedCard.image = nil
            uneditedCard.originalImage = nil
        }
        
        functionPicker.removeFromSuperview()
        cardView.removeFromSuperview()
        param.removeFromSuperview()
        colorPickerView.removeFromSuperview()
        
        if segue.identifier == "save-edit-segue" || segue.identifier == "cancel-edit-segue" {
            let dvc = segue.destination as! ExecutionViewController
            dvc.cardProject = cardProject
            dvc.selectedIndex = selectedIndex
        } else if segue.identifier == "manual-segue" {
            let dvc = segue.destination as! EditCommandViewController
            dvc.cardProject = cardProject
            dvc.selectedIndex = selectedIndex
            dvc.errorCard = true
        }
    }
}


