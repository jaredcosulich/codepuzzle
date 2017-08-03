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
        imageView.image = card.image
        output.text = functions.signature(code: card.code, param: card.param)
        functions.execute(code: card.code, param: card.param)
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
