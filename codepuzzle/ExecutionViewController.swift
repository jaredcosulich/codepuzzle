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
    
    var speed = 2000.0
    
    var executionIndex = 0
    
    var functions: Functions!
    
    var executedLayers = [CALayer]()
    
    let scrollLayerWidth = CGFloat(85.0)
    
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
            imageView.layer.addSublayer(functionLayer)
        }
        
        drawReplay(x: cardOffset)

        executeCard()
        startTimer()
    }
    
    func reset() {
        timer.invalidate()
        imageView.layer.sublayers?.removeAll()
        drawingView.layer.sublayers?.removeAll()
        functions.reset()
        executionIndex = 0
        executedLayers.removeAll()
    }
    
    func startTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: TimeInterval(speed / 1000.0),
            target: self,
            selector: #selector(executeCard),
            userInfo: nil,
            repeats: true
        )
    }
    
    func drawReplay(x: CGFloat) {
        let radius = 10.0
        let triangleSide = 3.0

        let layer = CAShapeLayer()
        layer.bounds = CGRect(x: 0, y: 0, width: radius*2, height: (radius * 2) + (triangleSide / 2.0))
        
        let path = UIBezierPath()
        let center = CGPoint(x: radius, y: (radius + (triangleSide / 2.0)))
        path.addArc(
            withCenter: center,
            radius: CGFloat(radius),
            startAngle: 180*(CGFloat.pi/180.0),
            endAngle: 270*(CGFloat.pi/180.0),
            clockwise: false
        )

        path.move(to: CGPoint(x: radius - triangleSide, y: triangleSide / 2.0))
        path.addLine(to: CGPoint(x: radius, y: triangleSide))
        path.addLine(to: CGPoint(x: radius, y: 0))
        path.close()
        
        layer.position = CGPoint(x: x - CGFloat(radius), y: imageView.bounds.height/2.0)
        layer.path = path.cgPath
        layer.lineCap = kCALineCapButt
        layer.lineDashPattern = nil
        layer.lineDashPhase = 0.0
        layer.lineJoin = kCALineJoinMiter
        layer.lineWidth = 2.0
        layer.miterLimit = 10.0
        layer.strokeColor = UIColor.black.cgColor
        layer.fillColor = UIColor.clear.cgColor
        
        imageView.layer.addSublayer(layer)
        executedLayers.append(layer)
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
            if (i != executedLayers.count - 1) {  // Don't hide the replay button
                if (i == executionIndex) {
                    l.opacity = 1.0
                    l.shadowOffset = CGSize(width: 5, height: 5)
                } else {
                    l.opacity = 0.25
                    l.shadowOffset = CGSize(width: 2, height: 2)
                }
            }
            if (executionIndex > 0) {
                l.position = CGPoint(x: l.position.x - scrollLayerWidth, y: l.position.y)
            }
        }

        executionIndex += 1
    }
    
    @IBAction func speedbutton(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            speed = 0.0
        case 2:
            speed = 1500.0
        default:
            speed = 500.0
        }
        startTimer()
    }

    @IBAction func executionSwipe(sender: UIPanGestureRecognizer) {
        print("TRANSLATION: \(sender.translation(in: imageView))")
        print("VELOCITY: \(sender.velocity(in: imageView))")
    }
    
    @IBAction func executionTap(sender: UITapGestureRecognizer) {
        let tapX = sender.location(in: imageView).x
        for i in 0..<executedLayers.count {
            let l = executedLayers[i]
            let x = l.position.x - (scrollLayerWidth / 4)
            if (x <= tapX && tapX < x + scrollLayerWidth) {
                print("CLICKED ON \(i)")
                if (i == cards.count) {
                    reset()
                    initExecution()
                }
            }
        }
    }
    
}
