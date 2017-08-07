//
//  EditCommandViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 8/5/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation

class EditCommandViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var functionPicker: UIPickerView!
    
    @IBOutlet weak var cardView: UIImageView!
    
    var cards = [Card]()
    
    var uneditedCard: Card!
    
    var selectedIndex: Int!
    
    var functionCodes = [String]()
    
    var pickerData = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let selectedCard = cards[selectedIndex]
        let selectedCode = Functions.processedCode(code: selectedCard.code)
        cardView.image = selectedCard.image
        
        uneditedCard = Card(
            image: selectedCard.image,
            code: selectedCard.code,
            param: selectedCard.param,
            originalImage: selectedCard.originalImage,
            originalCode: selectedCard.originalCode,
            originalParam: selectedCard.originalParam
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
        var selectedCard = cards[selectedIndex]
        let newCode = functionCodes[row]
        if (newCode != selectedCard.code) {
            selectedCard.code = newCode
            selectedCard.image = UIImage(named: newCode)!
            cardView.image = selectedCard.image
            cards[selectedIndex] = selectedCard
        }
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        cards[selectedIndex] = uneditedCard
        self.dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "save-edit-segue" || segue.identifier == "cancel-edit-segue" {
            let dvc = segue.destination as! ExecutionViewController
            dvc.cards = cards
            dvc.selectedIndex = selectedIndex
            dvc.paused = true
        }
    }
}


