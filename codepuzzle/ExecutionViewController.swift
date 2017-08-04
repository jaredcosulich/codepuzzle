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
    
    @IBOutlet weak var speedButtons: UISegmentedControl!
    
    var cards = [Card]()
    
    var timer = Timer()
    
    var speed = 500.0
    
    var paused = false
    
    var executionIndex = 0
    
    var functions: Functions!
    
    var executionLayer = CALayer()
    
    var executedLayers = [CALayer]()
    
    let scrollLayerWidth = CGFloat(85.0)
    
    var currentTranslation = CGFloat(0)
    
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
        
        var cardOffset = imageView.bounds.width / 2.0
        
        for i in 0..<cards.count {
            let card = cards[i]

            let functionLayer = CALayer()
            let image = card.image
            
            functionLayer.contents = image.cgImage
            functionLayer.opacity = 0.25
        
            let ratio = (imageView.bounds.height - 5) / image.size.height
            let layerWidth = image.size.width * ratio
            let layerHeight = (imageView.bounds.height - 5)
            let bounds = CGRect(x: 0, y: 0, width: layerWidth, height: layerHeight)
            
            functionLayer.bounds = bounds
            functionLayer.shadowColor = UIColor.black.cgColor
            functionLayer.shadowOffset = CGSize(width: 2, height: 2)
            functionLayer.shadowOpacity = 0.25
            functionLayer.shadowRadius = 2.0
            
            functionLayer.position = CGPoint(x: cardOffset, y: bounds.height/2.0)
            cardOffset += scrollLayerWidth
            
            executedLayers.append(functionLayer)
            executionLayer.addSublayer(functionLayer)
        }
        
        drawReplay(x: cardOffset)

        imageView.layer.addSublayer(executionLayer)
        
        paused = false

        executeNextCard()
        startTimer()
    }
    
    func reset() {
        timer.invalidate()
        executionIndex = 0
        executedLayers.removeAll()
        executionLayer.sublayers?.removeAll()
        executionLayer.position = CGPoint.zero
        imageView.layer.sublayers?.removeAll()
        drawingView.layer.sublayers?.removeAll()
        functions.reset() // this must come last
    }
    
    func startTimer() {
        timer.invalidate()
        if (!paused && speed > -1) {
            timer = Timer.scheduledTimer(
                timeInterval: TimeInterval(speed / 1000.0),
                target: self,
                selector: #selector(executeNextCard),
                userInfo: nil,
                repeats: true
            )
        }
    }
    
    func drawReplay(x: CGFloat) {
        let radius = CGFloat(10.0)
        let triangleSide = CGFloat(3.0)

        let layer = CAShapeLayer()
        layer.bounds = CGRect(x: 0, y: 0, width: scrollLayerWidth, height: (radius * 2) + (triangleSide / 2.0))
        
        let path = UIBezierPath()
        let center = CGPoint(x: scrollLayerWidth / 2, y: radius + (triangleSide / 2.0))
        path.addArc(
            withCenter: center,
            radius: CGFloat(radius),
            startAngle: 180*(CGFloat.pi/180.0),
            endAngle: 270*(CGFloat.pi/180.0),
            clockwise: false
        )

        let centerX = (scrollLayerWidth / 2)
        path.move(to: CGPoint(x: centerX - triangleSide, y: triangleSide / 2.0))
        path.addLine(to: CGPoint(x: centerX, y: triangleSide))
        path.addLine(to: CGPoint(x: centerX, y: 0))
        path.close()
        
        layer.position = CGPoint(x: x, y: imageView.bounds.height/2.0)
        layer.path = path.cgPath
        layer.lineCap = kCALineCapButt
        layer.lineDashPattern = nil
        layer.lineDashPhase = 0.0
        layer.lineJoin = kCALineJoinMiter
        layer.lineWidth = 2.0
        layer.miterLimit = 10.0
        layer.strokeColor = UIColor.black.cgColor
        layer.fillColor = UIColor.clear.cgColor
        
        executionLayer.addSublayer(layer)
        executedLayers.append(layer)
    }
    
    func executeNextCard() {
        if (paused || speed == -1 || executionIndex >= executedLayers.count) {
            return
        }
        
        if (executionIndex >= cards.count) {
            output.text = "All cards executed."
            timer.invalidate()
        } else {
            let card = cards[executionIndex]
            output.text = functions.signature(code: card.code, param: card.param)
            functions.execute(code: card.code, param: card.param, instant: (speed == 0))
        }
        
        for i in 0..<executedLayers.count {
            let l = executedLayers[i]
            if (i != executedLayers.count - 1) {  // Don't hide the replay button
                if (i == executionIndex) {
                    l.opacity = 1.0
                    l.shadowOffset = CGSize(width: 5, height: 5)
                } else {
                    l.opacity = 0.25
                    l.shadowOffset = CGSize(width: 2, height: 2)
                }
            }
        }

        if (executionIndex > 0) {
            executionLayer.position.x -= scrollLayerWidth
        }

        executionIndex += 1
    }
    
    @IBAction func speedbutton(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            speed = -1
            paused = true
        case 1:
            speed = 1500.0
            paused = false
        case 2:
            speed = 500.0
            paused = false
        default:
            speed = 0.0
            paused = false
        }
        startTimer()
        speedButtons.isHidden = true
    }

    @IBAction func executionSwipe(sender: UIPanGestureRecognizer) {
//        print("TRANSLATION: \(sender.translation(in: imageView))")
//        print("VELOCITY: \(sender.velocity(in: imageView))")
        paused = true

        let maxX = executedLayers[executedLayers.count - 1].position.x

        let translation = sender.translation(in: imageView).x
        let deltaTranslation = translation - currentTranslation
        currentTranslation = translation
        
        var moveTo = executionLayer.position.x + deltaTranslation
        if moveTo < (maxX - (imageView.bounds.width / 2)) * -1 {
            moveTo = (maxX - (imageView.bounds.width / 2)) * -1
        }
        
        if moveTo > 0 {
            moveTo = 0
        }
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        executionLayer.position.x = moveTo
        CATransaction.commit()
        
        if (sender.state == UIGestureRecognizerState.ended) {
            currentTranslation = 0
        }
    }
    
    @IBAction func executionTap(sender: UITapGestureRecognizer) {
        paused = true
        let tapX = sender.location(in: imageView).x - executionLayer.position.x
        for i in 0..<executedLayers.count {
            let l = executedLayers[i]
            let x = l.position.x - (scrollLayerWidth / 2)
            if (x <= tapX && tapX < x + scrollLayerWidth) {
                if (i == cards.count) {
                    reset()
                    initExecution()
                }
            }
        }
    }
    
    @IBAction func play(_ sender: UIBarButtonItem) {
        speedButtons.isHidden = !speedButtons.isHidden
    }
}
