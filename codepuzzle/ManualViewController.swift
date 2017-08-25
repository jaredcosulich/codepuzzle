//
//  ManualViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 8/5/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation
import MagicalRecord

class ManualViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var functionPicker: UIPickerView!
    
    @IBOutlet weak var param: UITextField!
    @IBOutlet weak var cardView: UIImageView!
    
    var selectedIndex: Int!
    
    var functionCodes = [String]()
    
    var pickerData = [[String]]()
    
    var cardProject: CardProject!
    
    var selectedCard: Card!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        selectedCard = cardProject.allCards()[selectedIndex]
        let selectedCode = selectedCard.code
        param.text = selectedCard.param
        cardView.image = selectedCard.image
        
        var selectedFunctionIndex = -1
        
        functionCodes = Array(Functions.functionInfo.keys).sorted()
        
        var functionNames = [String]()
        for i in 0..<Functions.functionInfo.count {
            let functionCode = functionCodes[i]
            if (functionCode == selectedCode) {
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
        if (newCode != selectedCard.code) {
            selectedCard.code = newCode
            selectedCard.param = param.text!
            selectedCard.image = drawCard(
                image: UIImage(named: newCode)!,
                param: param.text!
            )
            cardView.image = selectedCard.image
            setNewCard()
        }
    }
    
    func textFieldShouldReturn(_ sender: UITextField) -> Bool {
        param.resignFirstResponder()
        return true
    }
    
    func setNewCard() {
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
        selectedCard.param = param.text!
        
        let code = selectedCard.code
        
        selectedCard.image = drawCard(image: UIImage(named: code)!, param: param.text!)
        cardView.image = selectedCard.image
    }
    
    @IBAction func saveParam(_ sender: Any) {
        showParam(sender: sender)
        setNewCard()
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
        setNewCard()
    }
    
    func drawCard(image: UIImage, param: String) -> UIImage {
        let textColor = UIColor.black
        let textFont = UIFont(name: "Helvetica Bold", size: 45)!
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            ] as [String : Any]
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let x = (image.size.width - CGFloat(25 * param.characters.count)) / 2
        let textOrigin = CGPoint(x: x, y: 180)
        let rect = CGRect(origin: textOrigin, size: image.size)
        param.draw(in: rect, withAttributes: textFontAttributes)
        
        let newCardImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newCardImage!
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        functionPicker.removeFromSuperview()
        cardView.removeFromSuperview()
        param.removeFromSuperview()
        
        if segue.identifier == "save-segue" {
            let dvc = segue.destination as! ExecutionViewController
            dvc.cardProject = cardProject
            dvc.selectedIndex = selectedIndex
            dvc.paused = true
        }
    }
}


