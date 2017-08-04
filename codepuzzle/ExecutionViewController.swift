//
//  ExecutionViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 8/3/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import UIKit

class ExecutionViewController: UIViewController {
    
    @IBOutlet weak var drawingView: UIImageView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var output: UILabel!
    
    var cards = [Card]()
    
    var timer = Timer()
    
    var speed = 1500.0
    
    var executionIndex = 0
    
    var functions: Functions!
    
    var executedLayers = [CALayer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        drawingView.contentMode = .bottomLeft
        
        functions = Functions(uiImageView: drawingView)
        
        initExecution()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initExecution() {
        // start the timer
        
        for i in 0..<cards.count {
            let card = cards[i]

            let functionLayer = CALayer()
            let image = card.image

            functionLayer.contents = image.cgImage
        
            let ratio = (imageView.bounds.height - 5) / image.size.height
            let layerWidth = image.size.width * ratio
            let layerHeight = (imageView.bounds.height - 5)
            let bounds = CGRect(x: 0, y: 0, width: layerWidth, height: layerHeight)
            
            functionLayer.bounds = bounds
            functionLayer.shadowColor = UIColor.black.cgColor
            functionLayer.shadowOffset = CGSize(width: 5, height: 10)
            functionLayer.shadowOpacity = 0.25
            functionLayer.shadowRadius = 2.0
            
            let cardOffset = (imageView.bounds.width / 2.0) + (bounds.width + 20) * CGFloat(i + 1)
            functionLayer.position = CGPoint(x: cardOffset, y: bounds.height/2.0)
        
            executedLayers.append(functionLayer)
            imageView.layer.addSublayer(functionLayer)
        }
        
        timer.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: TimeInterval(speed / 1000.0),
            target: self,
            selector: #selector(executeCard),
            userInfo: nil,
            repeats: true
        )
    }
    
    func executeCard() {
        if (executionIndex >= cards.count) {
            output.text = "All cards executed."
            timer.invalidate()
            return
        }
        
        let card = cards[executionIndex]
        output.text = functions.signature(code: card.code, param: card.param)
        functions.execute(code: card.code, param: card.param)

        for i in 0..<executedLayers.count {
            let l = executedLayers[i]
            if (i == executionIndex) {
                l.opacity = 1.0
            } else {
                l.opacity = 0.5
            }
            l.position = CGPoint(x: l.position.x - (l.bounds.width + 20), y: l.position.y)
        }

        executionIndex += 1
    }
    
    @IBAction func speedbutton(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            speed = 200.0
        case 2:
            speed = 5000.0
        default:
            speed = 1500.0
        }
        initExecution()
    }

    
}
