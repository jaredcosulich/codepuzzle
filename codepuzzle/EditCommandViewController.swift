//
//  EditCommandViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 8/5/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation

class EditCommandViewController: UIViewController, UIPickerViewDelegate {
    
    @IBOutlet weak var functionPicker: UIPickerView!
    
    @IBOutlet weak var cardView: UIImageView!
    
    var cards = [Card]()
    
    var selectedIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cardView.image = cards[selectedIndex].image
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "close-edit-command-segue" {
            let dvc = segue.destination as! ExecutionViewController
            dvc.cards = cards
            dvc.selectedIndex = selectedIndex
            dvc.paused = true
        }
    }
}


