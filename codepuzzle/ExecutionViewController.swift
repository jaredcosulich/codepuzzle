//
//  ExecutionViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 8/3/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import UIKit

class ExecutionViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var drawingScrollView: UIScrollView!
    
    @IBOutlet weak var drawingView: UIImageView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var output: UILabel!
    
    @IBOutlet weak var colorSwatch: UIView!
    
    @IBOutlet weak var speedButtons: UISegmentedControl!
    
    @IBOutlet weak var toolbar: UIToolbar!
        
    var cardProject: CardProject!
    
    var cards: [Card]!
    
    var timer = Timer()
    
    var speed = 500.0
    
    var paused = false
    
    var executionIndex = -1
    
    var functions: Functions!
    
    var executionLayer = CALayer()
    
    var executedLayers = [CALayer]()
    
    var scrollLayerWidth: CGFloat!
    
    var currentTranslation = CGFloat(0)
    
    var selectedIndex = -1

    var loops = [Loop]()
    
    var addPhoto: String!
    
    @IBOutlet weak var addMenuBlur: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imageView.layoutIfNeeded()        

        Util.proportionalFont(anyElement: output, bufferPercentage: nil)
        Util.proportionalFont(anyElement: speedButtons, bufferPercentage: 10)
        
        drawingScrollView.minimumZoomScale = 1.0
        drawingScrollView.maximumZoomScale = Functions.STARTING_ZOOM * 2
        
        let s = drawingView.bounds.size
        drawingScrollView.zoom(
            to: CGRect(
                x: s.width/Functions.STARTING_ZOOM * ((Functions.STARTING_ZOOM - 1) / 2),
                y: s.height/Functions.STARTING_ZOOM * ((Functions.STARTING_ZOOM - 1) / 2),
                width: s.width/Functions.STARTING_ZOOM,
                height: s.height/Functions.STARTING_ZOOM
            ),
            animated: false
        )

        let tap = UITapGestureRecognizer(target: self, action: #selector(closeAddMenu))
        tap.delegate = self
        addMenuBlur.addGestureRecognizer(tap)
        
        functions = Functions(uiImageView: drawingView, uiScrollView: drawingScrollView)
        
        cards = cardProject.allCards()
        
        print("CARDS: \(cards.count), SELECTED INDEX: \(selectedIndex), EXECUTION INDEX: \(executionIndex)")
        
        if (selectedIndex != -1) {
            pause()
        } else {
            for i in 0..<cards.count {
                let card = cards[i]
                if (card.error) {
                    Timer.scheduledTimer(
                        withTimeInterval: 0,
                        repeats: false,
                        block: {
                            (Timer) in
                            self.selectedIndex = i
                            self.performSegue(withIdentifier: "edit-command-segue", sender: nil)
                        }
                    )
                    return
                }
            }
        }
        
        initExecution()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return drawingView
    }
    
    func initExecution() {
        // start the timer
        var cardOffset = imageView.bounds.width / 2.0
        
        for card in cards {
            let functionLayer = CALayer()
            let image = card.image!
            
            functionLayer.contents = image.cgImage
            functionLayer.opacity = 0.50
        
            let ratio = (imageView.bounds.height - (imageView.bounds.height*0.05)) / image.size.height
            let layerWidth = image.size.width * ratio
            scrollLayerWidth = CGFloat(layerWidth + (layerWidth * 0.1))
            let layerHeight = (imageView.bounds.height - 5)
            let bounds = CGRect(x: 0, y: 0, width: layerWidth, height: layerHeight)
            
            functionLayer.bounds = bounds
            functionLayer.shadowColor = UIColor.black.cgColor
            functionLayer.shadowOffset = CGSize(width: 2, height: 2)
            functionLayer.shadowOpacity = 0.25
            functionLayer.shadowRadius = 2.0
            
            functionLayer.position = CGPoint(x: cardOffset, y: bounds.height/2.0)
            cardOffset += scrollLayerWidth
            
            if (card.disabled) {
                functionLayer.opacity = 0.25
                functionLayer.shadowOffset = CGSize(width: 0, height: 0)
            }
            
            executedLayers.append(functionLayer)
            executionLayer.addSublayer(functionLayer)
        }
        
        drawReplay(x: cardOffset)
        drawAddCard(x: cardOffset)

        imageView.layer.addSublayer(executionLayer)
        
        if (!paused) {
            play()
            executeNextCard()
            startTimer()
        } else if (selectedIndex > -1) {
            if (selectedIndex >= cards.count) {
                scrollToCard(index: selectedIndex - 1)
                highlightCard(index: selectedIndex - 1)
                paused = false
                executeNextCard()
            } else {
                scrollToCard(index: selectedIndex)
                highlightCard(index: selectedIndex)
            }
        }
    }
    
    func reset() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)

        timer.invalidate()
        executedLayers.removeAll()
        executionLayer.sublayers?.removeAll()
        executionLayer.position = CGPoint.zero
        imageView.layer.sublayers?.removeAll()
        clearExecution()

        CATransaction.commit()
    }
    
    func clearExecution() {
        executionIndex = -1
        functions.reset()
        loops.removeAll()
    }
    
    func startTimer() {
        timer.invalidate()
        if (!paused) {
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
        
        layer.position = CGPoint(x: x, y: (imageView.bounds.height * (1 / 5)))
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

    
    func drawAddCard(x: CGFloat) {
        let size:CGFloat = 10
        let layer = CAShapeLayer()
        layer.bounds = CGRect(x: 0, y: 0, width: scrollLayerWidth, height: scrollLayerWidth)
        
        let path = UIBezierPath()
        let mid = scrollLayerWidth / 2
        path.move(to: CGPoint(x: mid - size, y: mid))
        path.addLine(to: CGPoint(x: mid + size, y: mid))
        path.move(to: CGPoint(x: mid, y: mid - size))
        path.addLine(to: CGPoint(x: mid, y: mid + size))
        
        layer.position = CGPoint(x: x, y: ((imageView.bounds.height * (4 / 5)) - size))
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
        if (paused || executionIndex >= cards.count) {
            timer.invalidate()
            pause()
            return
        }

        executionIndex += 1
        
        scrollToCard(index: executionIndex)

        if (executionIndex >= cards.count) {
            output.text = "All cards executed."
            colorSwatch.isHidden = true
            selectedIndex = -1
            timer.invalidate()
            pause()
        } else {
            highlightCard(index: executionIndex)
            executeCard(index: executionIndex, redraw: false)
        }        
    }
    
    func findCardIndex(x: CGFloat) -> Int {
        for i in 0..<executedLayers.count {
            let l = executedLayers[i]
            let positionX = l.position.x - (scrollLayerWidth / 2) + (scrollLayerWidth / 8)
            if (positionX <= x && x < positionX + scrollLayerWidth) {
                return i
            }
        }
        return -1
    }
    
    func highlightCard(index: Int) {
        if index == -1 || index >= cards.count {
            return
        }
    
        for i in 0..<cards.count {
            let l = executedLayers[i]
            if (i == index && !cards[i].disabled) {
                l.opacity = 1.0
                l.shadowOffset = CGSize(width: 5, height: 5)
            } else if !cards[i].disabled {
                l.opacity = 0.50
                l.shadowOffset = CGSize(width: 2, height: 2)
            } else {
                l.opacity = 0.25
                l.shadowOffset = CGSize(width: 0, height: 0)
            }
        }
        
        if (index != executionIndex) {
            clearExecution()
            selectedIndex = index
            executeCard(index: 0, redraw: true)
        }
    }
    
    func scrollToCard(index: Int) {
        executionLayer.position.x = (CGFloat(index) * scrollLayerWidth * -1)
    }
    
    func executeCard(index: Int, redraw: Bool = false) {
        if index == -1 || index >= cards.count {
            return
        }
        
        let card = cards[index]

        var loopIndex = index

        var functionText: String!

        if (card.disabled) {
            functionText = "Deleted Card"
        } else {
            let loopCount = functions.execute(code: card.code, param: card.param, instant: (redraw || speed == 0))
            if loopCount > 0 {
                loops.append(Loop(startingIndex: index, count: loopCount))
                functionText = "Loop \(loops.last!.count) Times"
            } else if loopCount < 0 {
                loopIndex = loops.last!.increment()
                if loopIndex == -1 {
                    _ = loops.popLast()
                    functionText = "Loop Complete"
                } else {
                    functionText = "Loop \(loops.last!.completedCycles) / \(loops.last!.count)"
                }
            } else {
                functionText = Functions.signature(code: card.code, param: card.param)
            }
        }
        
        executionIndex = loopIndex > -1 ? loopIndex : index
        
        if (redraw && executionIndex < selectedIndex) {
            executeCard(index: executionIndex + 1, redraw: true)
        } else {
            output.text = functionText
            if functionText == "Fill Color" || functionText == "Pen Color" {
                colorSwatch.backgroundColor = ImageProcessor.colorFrom(text: card.param)
                colorSwatch.isHidden = false
            } else {
                colorSwatch.isHidden = true
            }
            selectedIndex = executionIndex
        }
    }
    
    @IBAction func speedbutton(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            speed = 500.0
        case 1:
            speed = 100.0
        default:
            speed = 0.0
        }
        speedButtons.isHidden = true

        if (selectedIndex == -1) {
            reset()
            initExecution()
        } else {
            play()
            startTimer()
        }
    }

    @IBAction func executionSwipe(sender: UIPanGestureRecognizer) {
//        print("TRANSLATION: \(sender.translation(in: imageView))")
//        print("VELOCITY: \(sender.velocity(in: imageView))")
        pause()

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
        let cardIndex = findCardIndex(x: (moveTo * -1) + (imageView.bounds.width / 2))
        highlightCard(index: cardIndex)

        CATransaction.commit()
        
        if (sender.state == UIGestureRecognizerState.ended) {
            currentTranslation = 0
        }
    }
    
    @IBAction func executionTap(sender: UITapGestureRecognizer) {
        if (paused) {
            let tapX = sender.location(in: imageView).x - executionLayer.position.x
            let tapY = sender.location(in: imageView).y - executionLayer.position.y
            let cardIndex = findCardIndex(x: tapX)
            if (cardIndex == cards.count) {
                if (tapY < imageView.bounds.size.height / 2) {
                    reset()
                    play()
                    initExecution()
                } else {
                    addMenuBlur.isHidden = false
                }
            } else {
                if (selectedIndex == cardIndex) {
                    performSegue(withIdentifier: "edit-command-segue", sender: nil)
                } else {
                    selectedIndex = cardIndex
                    scrollToCard(index: selectedIndex)
                    highlightCard(index: selectedIndex)
                }
            }
        } else {
            pause()
        }

    }
    
    @IBAction func closeAddMenu(_ sender: UIButton) {
        addMenuBlur.isHidden = true
    }
    
    func pause() {
        paused = true
        speedButtons.selectedSegmentIndex = -1
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.play, target: self, action: #selector(playbutton))
        toolbar.items?[2] = button
    }
    
    func play() {
        paused = false
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.pause, target: self, action: #selector(playbutton))
        toolbar.items?[2] = button
    }
    
    @IBAction func playbutton(_ sender: UIBarButtonItem) {
        if (paused) {
            speedButtons.isHidden = false
            play()
        } else {
            speedButtons.isHidden = true
            pause()
        }
    }
    
    @IBAction func editProject(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "edit-project-segue", sender: nil)
    }
    
    @IBAction func newPhoto(_ sender: UIButton) {
        switch sender.titleLabel!.text! {
        case "Take Photo":
            addPhoto = "take"
        default:
            addPhoto = "library"
        }

        performSegue(withIdentifier: "add-photo-segue", sender: nil)
    }
    
    @IBAction func newCard(_ sender: UIButton) {
        switch sender.titleLabel!.text! {
        case "To Beginning":
            selectedIndex = -1
        default:
            selectedIndex = cards.count
        }
        
        performSegue(withIdentifier: "edit-command-segue", sender: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        pause()
        
        for layer in executedLayers {
            layer.contents = nil
        }
        
        imageView?.removeFromSuperview()
        drawingView?.removeFromSuperview()
        
        if segue.identifier == "edit-command-segue" {
            let dvc = segue.destination as! EditCommandViewController
            dvc.cardProject = cardProject
            dvc.selectedIndex = selectedIndex
        } else if segue.identifier == "close-segue" {
            let dvc = segue.destination as! ProjectViewController
            dvc.cardProject = cardProject
        } else if segue.identifier == "add-photo-segue" {
            let dvc = segue.destination as! MenuViewController
            dvc.cardProject = cardProject
            dvc.addPhoto = addPhoto
        } else if segue.identifier == "edit-project-segue" {
            let dvc = segue.destination as! MenuViewController
            dvc.cardProject = cardProject
        }
    }
    

    
}
