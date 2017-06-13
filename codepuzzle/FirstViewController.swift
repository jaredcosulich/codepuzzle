//
//  FirstViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 6/8/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func revertbutton(_ sender: UIButton) {
        imageView.image = UIImage(named: "cardtest3_close.JPG");
    }
    
    @IBAction func cannybutton(_ sender: UIButton) {
        imageView.image = OpenCVWrapper.canny(imageView.image);
    }
}

