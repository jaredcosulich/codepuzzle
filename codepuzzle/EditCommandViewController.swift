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
    var manual: Bool
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
            newCard?.manual = self.manual
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
            card.manual = self.manual
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
    
    @IBOutlet weak var functionDisplay: UILabel!
    @IBOutlet weak var paramDisplay: UILabel!
    
    @IBOutlet weak var editFunction: UIButton!
    
    @IBOutlet weak var editParam: UIButton!
    
    var errorCard: Bool = false
    
    var uneditedCard: TempCard!
    var newCard: TempCard!
    
    var selectedIndex: Int!
    
    var functionCodes = [String]()
    
    var pickerData = [[String]]()
    
    var cardProject: CardProject!
    
    var selectedCard: Card!
    
    var newCode: String!
    
    @IBOutlet weak var editFunctionView: UIView!
    @IBOutlet weak var saveFunction: UIButton!
    
    @IBOutlet weak var editParamView: UIView!
    @IBOutlet weak var saveParam: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionText: UILabel!
    
    @IBOutlet weak var colorPickerView: UIView!
    
    let colorPicker = ChromaColorPicker(frame: CGRect(x: 50, y: 50, width: 200, height: 200))

    @IBOutlet weak var colorParam: UIView!
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editFunction.layer.cornerRadius = 10
        editParam.layer.cornerRadius = 10
        editFunctionView.layer.cornerRadius = 10
        saveFunction.layer.cornerRadius = 6
        editParamView.layer.cornerRadius = 10
        saveParam.layer.cornerRadius = 6
        
        // Do any additional setup after loading the view, typically from a nib.
        let cards = cardProject.allCards()
        
        var selectedCode: String!
        
        if selectedIndex >= 0 && selectedIndex < cards.count {
            selectedCard = cards[selectedIndex]
            errorCard = selectedCard.error
            selectedCode = Functions.processedCode(code: selectedCard.code)
            
            if (errorCard) {
                titleLabel.text = "Fix This Card"
                if selectedCode.characters.count == 0 {
                    descriptionText.text = "We were unable to read the function on this card."
                } else {
                    descriptionText.text = "We were unable to read the parameter on this card."
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
                manual: selectedCard.manual,
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
                manual: true,
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
                code: selectedCode,
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
        colorParam.backgroundColor = color
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
                    attributedTitleForRow row: Int,
                    forComponent component: Int
        ) -> NSAttributedString? {
        let rowString = NSAttributedString(string: pickerData[component][row], attributes: [NSForegroundColorAttributeName:UIColor.white])
        return rowString
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int)
    {
        newCode = functionCodes[row]
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
            paramDisplay.text = ""
            let color = ImageProcessor.colorFrom(text: cardParam)
            paramDisplay.backgroundColor = color
            colorLabel.isHidden = false
            colorParam.isHidden = false
            colorParam.backgroundColor = color
            colorPicker.adjustToColor(color)
        } else {
            paramDisplay.backgroundColor = UIColor.white
            paramDisplay.text = cardParam
            colorLabel.isHidden = true
            colorParam.isHidden = true
        }
        
        for i in 0..<Functions.functionInfo.count {
            if (functionCodes[i] == Functions.processedCode(code: cardCode)) {
                functionPicker.selectRow(i, inComponent: 0, animated: true)
            }
        }
        
        functionDisplay.text = Functions.info(code: cardCode).name
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
            let paramText = "\(colorPicker.currentColor)"
            
            if (selectedCard == nil) {
                newCard.param = paramText
            } else {
                selectedCard.param = paramText
            }
            
            let newImage = drawCard(
                code: selectedCard == nil ? newCard.code : selectedCard.code,
                param: paramText
            )
            
            selectedCard?.image = newImage
            newCard?.image = newImage
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
    
    func drawCard(code: String!, param: String?) -> UIImage {
        let processedCode = Functions.processedCode(code: code)
        let info = Functions.info(code: processedCode)
        let image = UIImage(named: processedCode)!
        let textColor = UIColor.black
        let textFont = UIFont(name: "Helvetica", size: 60)!
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

        if (param != nil) {
            if (info.paramCount == 1) {
                let x = (image.size.width - CGFloat(36 * param!.characters.count)) / 2
                let textOrigin = CGPoint(x: x, y: 300)
                let rect = CGRect(origin: textOrigin, size: image.size)

                let textFontAttributes = [
                    NSFontAttributeName: textFont,
                    NSForegroundColorAttributeName: textColor,
                    ] as [String : Any]
                
                if (param != nil) {
                    param!.draw(in: rect, withAttributes: textFontAttributes)
                }
            }
            
            if (info.color) {
                let context = UIGraphicsGetCurrentContext()
                let colorRect = CGRect(origin: CGPoint(x: 180, y: 270), size: CGSize(width: 90, height: 90))
                
                let color = ImageProcessor.colorFrom(text: param!)
                context?.setFillColor(color.cgColor)
                context?.fill(colorRect)
            }
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
                print("DELETING, MANUAL: \(self.selectedCard.manual)")
                if self.selectedCard.manual {
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

    @IBAction func editFunction(_ sender: UIButton) {
        let cardCode = selectedCard == nil ? newCard.code : selectedCard.code
        newCode = nil
        for i in 0..<Functions.functionInfo.count {
            if (functionCodes[i] == Functions.processedCode(code: cardCode)) {
                functionPicker.selectRow(i, inComponent: 0, animated: false)
            }
        }
        
        editFunctionView.alpha = 0.0
        editFunctionView.isHidden = false
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.editFunctionView.alpha = 1.0
            }
        )

    }
    
    @IBAction func cancelEditFunction(_ sender: UIButton) {
        hideFunction()
    }
    
    @IBAction func saveFunction(_ sender: UIButton) {
        if (newCode != nil) {
            functionDisplay.text = Functions.info(code: newCode).name

            if (selectedCard == nil) {
                let drawnCard = drawCard(
                    code: newCode,
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
                        code: newCode,
                        param: param.text!
                    )
                    cardView.image = selectedCard.image
                }
                updateSelectedCard()
            }
            
            prepareCard()
        }
        
        hideFunction()
    }
    
    func hideFunction() {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.editFunctionView.alpha = 0.0
            }, completion: { (position) in
                self.editFunctionView.isHidden = true
            }
        )
        
    }
    
    @IBAction func editParam(_ sender: UIButton) {
        if (selectedCard == nil) {
            param.text = newCard.param
        } else {
            param.text = selectedCard.param
        }
        editParamView.alpha = 0.0
        editParamView.isHidden = false
        if !param.isHidden {
            param.becomeFirstResponder()
        }
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.editParamView.alpha = 1.0
            }
        )
    }
    
    @IBAction func cancelEditParam(_ sender: UIButton) {
        hideParam()
    }
    
    @IBAction func saveParam(_ sender: UIButton) {
        var paramText: String!
        if (param.isHidden) {
            paramText = "\(colorParam.backgroundColor ?? UIColor.black)"
        } else {
            paramText = param.text!
        }

        if (paramText != (selectedCard == nil ? newCard.param : selectedCard.param)) {
            if (selectedCard != nil) {
                selectedCard.param = paramText
            } else {
                newCard.param = paramText
            }
            
            if (!errorCard) {
                let newImage = drawCard(
                    code: selectedCard == nil ? newCard.code : selectedCard.code,
                    param: paramText
                )
                selectedCard?.image = newImage
                newCard?.image = newImage
                cardView.image = newImage
            }
            
            updateSelectedCard()
            
            prepareCard()
        }
        
        hideParam()
    }
    
    func hideParam() {
        param.resignFirstResponder()
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.editParamView.alpha = 0.0
            }, completion: { (position) in
                self.editParamView.isHidden = true
            }
        )
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
        }
    }
}


