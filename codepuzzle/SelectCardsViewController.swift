//
//  EditCommandViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 8/5/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation
import MagicalRecord

class SelectCardsViewController: UIViewController, UIScrollViewDelegate {
   
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var output: UILabel!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!

    let cardList = CardListWrapper()!
    
    var cardProject: CardProject!
    
    var cardGroup: CardGroup!
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
        Util.proportionalFont(anyElement: output, bufferPercentage: nil)

        cardGroup = cardProject.cardGroups[selectedIndex]
        
        imageView.image = ImageProcessor.scale(image: cardGroup.image!, view: imageView)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    
        initCardList(nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
        
    @IBAction func initCardList(_ sender: Any?) {
        output.text = "Scanning photo for cards..."
        cardList.clear()
        activityView.startAnimating()
        
        Timer.scheduledTimer(
            timeInterval: 0,
            target: self,
            selector: #selector(startCardProcessing),
            userInfo: nil,
            repeats: false
        )
    }
    
    func startCardProcessing() {
        OpenCVWrapper.process(cardGroup.image, self.cardList, 0.5)
        
        if self.cardList.count() == 0 || self.cardList.getHexRect(0).width < 40 {
            self.cardList.clear()
            OpenCVWrapper.process(cardGroup.image, self.cardList, 2)
        } else if self.cardList.count() == 0 || self.cardList.getHexRect(0).width < 75 {
            self.cardList.clear()
            OpenCVWrapper.process(cardGroup.image, self.cardList, 1)
        }
        
        if self.cardList.count() == 0 || self.cardList.getHexRect(0).width > 400 {
            self.cardList.clear()
            OpenCVWrapper.process(cardGroup.image, self.cardList, 0.2)
        }
        
        setProcessedImage(
            image: ImageProcessor.borderCards(image: cardGroup.image!, cardList: cardList, index: -1, width: 8, deleteIcon: true),
            completion: {
                if let processedImage = self.cardGroup.processedImage {
                    self.imageView.image = ImageProcessor.scale(image: processedImage, view: self.imageView)
                    
                    self.activityView.stopAnimating()
                    
                    if (self.cardList.count() == 0) {
                        self.output.text = "Unable to find any cards. Please try a new photo."
                    } else {
                        self.output.text = "Identified \(self.cardList.count()) cards\r\rAdd a card: Tap in the hexagon of the card.\rRemove a card: Tap the X in the card\r(pinch to zoom in and out)"
                    }
                } else {
                    self.startCardProcessing()
                }
            }
        )
    }
    
    func setProcessedImage(image: UIImage, completion: @escaping () -> Void) {
        if let context = self.cardProject.persistedManagedObjectContext {
            context.mr_save({
                (localContext: NSManagedObjectContext!) in
                self.cardGroup.processedImage = image
            }, completion: {
                (MRSaveCompletionHandler) in
                context.mr_saveToPersistentStoreAndWait()
                completion()
            })
        }
    }
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let offsetX = (imageView.frame.size.width - imageView.image!.size.width) / 2
        let offsetY = (imageView.frame.size.height - imageView.image!.size.height) / 2
        let scale = cardGroup.image!.size.width / scrollView.bounds.width

        print("OFFSETS: \(offsetX) x \(offsetY)")
        
        let tap = tapGestureRecognizer.location(in: imageView)
        let scaledTap = CGPoint(
            x: (tap.x - offsetX) * scale,
            y: (tap.y - offsetY) * scale
        )
        
        let hexWidth = cardList.getHexRect(0).size.width
        let hexHeight = cardList.getHexRect(0).size.height
        let bufferX = hexWidth / -2
        let bufferY = hexHeight / -2
        
        var addCard = true
        for i in 0..<cardList.count() {
            let hexRect = cardList.getHexRect(i).insetBy(dx: bufferX, dy: bufferY)
            if hexRect.contains(scaledTap) {
                addCard = false
                cardList.remove(i)
                break
            }
        }
        
        if addCard {
            cardList.add(Double(scaledTap.x), Double(scaledTap.y), Double(hexWidth), Double(hexHeight), 0)
        }
        print("COUNT: \(cardList.count())")
        imageView.image = ImageProcessor.borderCards(image: cardGroup.image!, cardList: cardList, index: -1, width: 8, deleteIcon: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    

}


