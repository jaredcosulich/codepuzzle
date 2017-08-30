//
//  EditCommandViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 8/5/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation
import MagicalRecord

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
        }, completion: {
            (MRSaveCompletionHandler) in
            self.cardProject.persistedManagedObjectContext.mr_saveToPersistentStoreAndWait()
            completion()
        })
    }
}

class EditCommandViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var functionPicker: UIPickerView!
    
    @IBOutlet weak var param: UITextField!
    @IBOutlet weak var cardView: UIImageView!
    
    var uneditedCard: TempCard!
    var newCard: TempCard!
    
    var selectedIndex: Int!
    
    var functionCodes = [String]()
    
    var pickerData = [[String]]()
    
    var cardProject: CardProject!
    
    var selectedCard: Card!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let cards = cardProject.allCards()
        
        var selectedCode: String!
        
        if selectedIndex > 0 && selectedIndex < cards.count {
            selectedCard = cards[selectedIndex]
            selectedCode = selectedCard.code
            param.text = selectedCard.param
            cardView.image = selectedCard.image

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
        
        var selectedFunctionIndex = -1
        
        var functionNames = [String]()
        for i in 0..<Functions.functionInfo.count {
            let functionCode = functionCodes[i]
            if (selectedCode != nil && functionCode == selectedCode) {
                selectedFunctionIndex = i
            }
            functionNames.append(
                "\((Functions.functionInfo[functionCode]?["name"])!) (\(functionCode))"
            )
        }
        
        pickerData = [functionNames]
        
        functionPicker.delegate = self
        functionPicker.dataSource = self
        
        param.delegate = self
        
        functionPicker.selectRow(selectedFunctionIndex, inComponent: 0, animated: true)
        
        print("START CARDS: \(cardProject.cardGroups.last?.cards.count ?? -1) (\(selectedIndex))")

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            newCard.code = newCode
            newCard.param = param.text!
            newCard.image = drawCard(
                image: UIImage(named: newCode)!,
                param: param.text!
            )
            cardView.image = newCard.image
        } else if (newCode != selectedCard.code) {
            selectedCard.code = newCode
            selectedCard.param = param.text!
            selectedCard.image = drawCard(
                image: UIImage(named: newCode)!,
                param: param.text!
            )
            cardView.image = selectedCard.image
            updateSelectedCard()
        }
    }
    
    func textFieldShouldReturn(_ sender: UITextField) -> Bool {
        param.resignFirstResponder()
        return true
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
        
        let newImage = drawCard(image: UIImage(named: code)!, param: param.text!)
        selectedCard?.image = newImage
        newCard?.image = newImage
        cardView.image = newImage
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
        updateSelectedCard()
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        if (newCard != nil) {
            newCard.addToCardGroup(cardGroup: cardProject.cardGroups.last!, completion: {
                print("SAVED: \(self.cardProject.cardGroups.last?.cards.count)")
                self.performSegue(withIdentifier: "save-edit-segue", sender: nil)
            })
        } else {
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
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        uneditedCard.updateCard(card: selectedCard, completion: {
            self.performSegue(withIdentifier: "cancel-edit-segue", sender: nil)
        })
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
        
        if segue.identifier == "save-edit-segue" || segue.identifier == "cancel-edit-segue" {
            print("END CARDS: \(cardProject.cardGroups.last?.cards.count ?? -1) (\(selectedIndex))")
            let dvc = segue.destination as! ExecutionViewController
            dvc.cardProject = cardProject
            dvc.selectedIndex = selectedIndex
            dvc.paused = true
        }
    }
}


