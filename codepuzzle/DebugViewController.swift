
//
//  DebugView.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 8/15/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import UIKit

class DebugViewController: UIViewController, UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var cardProject: CardProject!
    var selectedIndex = -1
    
    @IBOutlet weak var cardGroupView: UIScrollView!
    @IBOutlet weak var cardGroupImageView: UIImageView!

    @IBOutlet weak var output: UILabel!
    
    let cardList = CardListWrapper()!
//    let tesseract = G8Tesseract()

    var image: UIImage!
    
    var timer = Timer()
    var cardIndex = 0
    
    @IBOutlet weak var functionPicker: UIPickerView!
    var pickerData = [String: [String]]()
    var processType: String!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        cardGroupView.minimumZoomScale = 1.0
        cardGroupView.maximumZoomScale = 6.0
        
        cardGroupImageView.image = image
        
//        tesseract.language = "eng+fra"
//        tesseract.engineMode = .tesseractOnly
//        tesseract.pageSegmentationMode = .auto
//        tesseract.maximumRecognitionTime = 60.0
        
        pickerData["View All"] = [
            "Cards",
            "Functions",
            "Parameters",
            "Hex"
        ]
        
        pickerData["View Each"] = [
            "Card",
            "Function",
            "Parameter",
            "Hex"
        ]
        
        if (selectedIndex > -1) {
            let cardGroup = cardProject.cardGroups[selectedIndex]
            for option in ["Card", "Parameter", "Function", "Hex", "Color"] {
                pickerData["View Individual \(option)"] = [String]()
                for i in 0..<cardGroup.cards.count {
                    pickerData["View Individual \(option)"]?.append("\(option) \(i + 1)")
                }
            }
        }
        
        pickerData["View OpenCV Transformation"] = [
            "Color Transformation",
            "Canny Transformation",
            "Dilation Transformation",
            "Threshold Transformation",
            "All Transformations"
        ]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return cardGroupImageView
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_
        pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int
        ) -> Int {
        if (component == 0) {
            return pickerData.keys.count
        } else {
            let sortedKeys = [String](pickerData.keys).sorted()
            return pickerData[sortedKeys[pickerView.selectedRow(inComponent: 0)]]!.count
        }
    }
    
    func pickerView(_
        pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int
        ) -> String? {
        return fetchPickerLabel(component: component, row: row)
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
                      didSelectRow row: Int,
                      inComponent component: Int) {
        pickerView.reloadComponent(1)
    }
    
    func pickerView(_
        pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        
        var pickerLabel = view as? UILabel;
        
        if (pickerLabel == nil) {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont(name: "Arial", size: 10)
            pickerLabel?.textAlignment = NSTextAlignment.center
        }
        
        pickerLabel?.text = fetchPickerLabel(component: component, row: row)
        
        return pickerLabel!;
    }
    
    func fetchPickerLabel(component: Int, row: Int) -> String {
        let sortedKeys = [String](pickerData.keys).sorted()
        if (component == 0) {
            return sortedKeys[row]
        } else {
            return (pickerData[sortedKeys[functionPicker.selectedRow(inComponent: 0)]]?[row])!
        }
    }
    
    @IBAction func processImage(_ sender: UIButton) {
        let component0Row = fetchPickerLabel(component: 0, row: functionPicker.selectedRow(inComponent: 0))
        let component1Row = functionPicker.selectedRow(inComponent: 1)
        
        switch component0Row {
        case "View All":
            process()
            switch component1Row {
            case 0:
                cardGroupImageView.image = ImageProcessor.borderCards(image: image, cardList: cardList, index: -1, style: "full")
            case 1:
                cardGroupImageView.image = ImageProcessor.borderCards(image: image, cardList: cardList, index: -1, style: "function")
            case 1:
                cardGroupImageView.image = ImageProcessor.borderCards(image: image, cardList: cardList, index: -1, style: "param")
            default:
                cardGroupImageView.image = ImageProcessor.borderCards(image: image, cardList: cardList, index: -1, style: "hex")
            }
        case "View Each":
            switch component1Row {
            case 0:
                processType = "full"
            case 1:
                processType = "function"
            case 2:
                processType = "param"
            default:
                processType = "hex"
            }
            startIndividualCards()
        case "View Individual Card", "View Individual Parameter", "View Individual Function", "View Individual Hex", "View Individual Color":
            process()
            switch component0Row {
            case "View Individual Card":
                processType = "full"
            case "View Individual Function":
                processType = "function"
            case "View Individual Param":
                processType = "param"
            case "View Individual Color":
                processType = "color"
            default:
                processType = "hex"
            }
            cardIndex = component1Row
            showNextCard()
        default:
            if component1Row == functionPicker.numberOfRows(inComponent: 1) - 1 {
                cardGroupImageView.image = OpenCVWrapper.debug(image)
            } else {
                cardGroupImageView.image = OpenCVWrapper.individualProcess(image, Int32(component1Row))
            }
        }
    }
    
    func process() {
        cardList.clear()
        OpenCVWrapper.process(image, cardList)
        output.text = "Found: \(cardList.count())"
    }

    func startIndividualCards() {
        process()
        cardIndex = 0
        timer.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(showNextCard),
            userInfo: nil,
            repeats: true
        )
        showNextCard()
    }
    
    func showNextCard() {
        cardGroupImageView.contentMode = .scaleAspectFit

        let rotation = cardList.getRotation(Int32(cardIndex))
        var rect: CGRect!
        var paramRect: CGRect!
        
        switch processType {
        case "full":
            rect = cardList.getFullRect(Int32(cardIndex))
        case "function":
            rect = cardList.getFunctionRect(Int32(cardIndex))
        case "param":
            rect = cardList.getParamRect(Int32(cardIndex))
        case "color":
            paramRect = cardList.getParamRect(Int32(cardIndex))
            rect = CGRect(
                x: paramRect.midX - 5,
                y: paramRect.minY + (paramRect.height * 3 / 4) - 5,
                width: 10,
                height: 10
            )
            cardGroupImageView.contentMode = .topLeft
        default:
            rect = cardList.getHexRect(Int32(cardIndex))
        }
        
        let hexRect = cardList.getFunctionRect(Int32(cardIndex))
//        tesseract.image = ImageProcessor.cropCard(image: image, rect: functionRect, hexRect: hexRect, rotation: rotation).g8_blackAndWhite()
//        tesseract.recognize()
        cardGroupImageView.image = ImageProcessor.cropCard(image: image, rect: rect, hexRect: hexRect, rotation: rotation)
        
        if (processType == "color") {
            let colorSample = cardGroupImageView.image!.averageColor()
            let pathLayer = CAShapeLayer()
            pathLayer.fillColor = colorSample.cgColor
            pathLayer.strokeColor = UIColor.white.cgColor
            pathLayer.lineWidth = 10
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 50, y:50))
            path.addLine(to: CGPoint(x: 100, y:50))
            path.addLine(to: CGPoint(x: 100, y:100))
            path.addLine(to: CGPoint(x: 50, y:100))
            path.close()
            path.stroke()
            path.fill()
            pathLayer.path = path.cgPath
 
            cardGroupImageView.layer.addSublayer(pathLayer)
        }
//        output.text = "Code: \(tesseract.recognizedText!)"
        cardIndex += 1
        if (Int32(cardIndex) >= cardList.count()) {
            timer.invalidate()
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        image = nil
        cardGroupImageView.removeFromSuperview()
        cardGroupView.removeFromSuperview()
        functionPicker.removeFromSuperview()
        
        if segue.identifier == "cancel-debug-segue" {
            let dvc = segue.destination as! MenuViewController
            dvc.cardProject = cardProject
        }
    }
}
