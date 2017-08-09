//
//  EditCommandViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 8/5/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation

struct TempCard {
    var code: String
    var param: String
    var image: UIImage
    var originalCode: String
    var originalParam: String
    var originalImage: UIImage
    
    func addToCardGroup(cardGroup: CardGroup) -> Card {
        return cardGroup.addCard(code: code, param: param, image: image, originalCode: originalCode, originalParam: originalParam, originalImage: originalImage)
    }

    func updateCard(card: Card) {
        card.code = code
        card.param = param
        card.image = image
        card.originalCode = originalCode
        card.originalParam = originalParam
        card.originalImage = originalImage
    }
}

class EditCommandViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var functionPicker: UIPickerView!
    
    @IBOutlet weak var param: UITextField!
    @IBOutlet weak var cardView: UIImageView!
    
    var uneditedCard: TempCard!
    
    var selectedIndex: Int!
    
    var functionCodes = [String]()
    
    var pickerData = [[String]]()
    
    var cardGroup: CardGroup!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let selectedCard = cardGroup.cards[selectedIndex]
        let selectedCode = selectedCard.code
        param.text = selectedCard.param
        cardView.image = selectedCard.image
        
        uneditedCard = TempCard(
            code: selectedCard.code,
            param: selectedCard.param,
            image: selectedCard.image,
            originalCode: selectedCard.originalCode,
            originalParam: selectedCard.originalParam,
            originalImage: selectedCard.originalImage
        )
        
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
        let selectedCard = cardGroup.cards[selectedIndex]
        let newCode = functionCodes[row]
        if (newCode != selectedCard.code) {
            selectedCard.code = newCode
            selectedCard.param = param.text!
            selectedCard.image = drawCard(
                image: UIImage(named: newCode)!,
                param: param.text!
            )
            cardView.image = selectedCard.image
            cardGroup.cards[selectedIndex] = selectedCard
        }
    }
    
    func textFieldShouldReturn(_ sender: UITextField) -> Bool {
        param.resignFirstResponder()
        return true
    }

    @IBAction func showParam(_ sender: Any) {
        let selectedCard = cardGroup.cards[selectedIndex]
        selectedCard.param = param.text!
        
        let code = selectedCard.code
        
        selectedCard.image = drawCard(image: UIImage(named: code)!, param: param.text!)
        cardView.image = selectedCard.image
        cardGroup.cards[selectedIndex] = selectedCard
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
        if segue.identifier == "cancel-edit-segue" {
            uneditedCard.updateCard(card: cardGroup.cards[selectedIndex])
        }
        
        if segue.identifier == "save-edit-segue" || segue.identifier == "cancel-edit-segue" {
            let dvc = segue.destination as! ExecutionViewController
            dvc.cardGroup = cardGroup
            dvc.selectedIndex = selectedIndex
            dvc.paused = true
        }
    }
}


