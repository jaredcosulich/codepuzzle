//
//  ClassViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 9/27/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation
import MagicalRecord

class ClassViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var instructions: UILabel!
    @IBOutlet weak var registerClassButton: UIButton!
    
    
    @IBOutlet weak var classCodeLabel: UILabel!
    @IBOutlet weak var classCodeInput: UITextField!
    @IBOutlet weak var classCodeButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var parentClass: ParentClass?
    
    let puzzleSchool = PuzzleSchool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Util.proportionalFont(anyElement: instructions, bufferPercentage: nil)
        
        registerClassButton.layer.cornerRadius = 6
        Util.proportionalFont(anyElement: registerClassButton, bufferPercentage: 10)
        
        Util.proportionalFont(anyElement: classCodeLabel, bufferPercentage: 10)

        Util.proportionalFont(anyElement: classCodeInput, bufferPercentage: 15)
        classCodeInput.delegate = self
        classCodeInput.returnKeyType = .done

        classCodeButton.layer.cornerRadius = 6
        Util.proportionalFont(anyElement: classCodeButton, bufferPercentage: 5)        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ sender: UITextField) -> Bool {
        classCodeInput.resignFirstResponder()
        return true
    }
    
    @IBAction func registerClass(_ sender: UIButton) {
        if let url = URL(string: "http://puzzleschool.com") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func submitClassCode(_ sender: UIButton) {
        if var slug = classCodeInput.text {
            slug = slug.trimmingCharacters(in: .whitespacesAndNewlines)

            let identifier = puzzleSchool.getClassName(slug: slug)
            
            classCodeButton.isHidden = true
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            Timer.scheduledTimer(
                withTimeInterval: 0.1,
                repeats: true,
                block: {
                    (timer) in
                    if self.puzzleSchool.processing(identifier: identifier) {
                        return
                    }
                    
                    if self.puzzleSchool.results[identifier] == nil {
                        print("HANDLE THIS! NO CLASS FOUND")
                        return
                    }
                    
                    timer.invalidate()
                    
                    let existingClasses = ParentClass.mr_findAll() as! [ParentClass]
                    for c in existingClasses {
                        if c.slug == slug {
                            self.parentClass = c
                        }
                    }
                    
                    MagicalRecord.save({
                        (localContext: NSManagedObjectContext!) in
                        if (self.parentClass == nil) {
                            self.parentClass = ParentClass.mr_createEntity(in: localContext)
                        }
                        
                        self.parentClass!.name = self.puzzleSchool.results[identifier]!!
                        self.parentClass!.slug = slug
                        self.parentClass!.persistedManagedObjectContext = localContext
                    }, completion: {
                        (MRSaveCompletionHandler) in
                        self.parentClass!.persistedManagedObjectContext.mr_saveToPersistentStoreAndWait()
                        self.performSegue(withIdentifier: "projects-segue", sender: nil)
                    })

                }
            )

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "projects-segue" {
            let dvc = segue.destination as! ProjectViewController
            dvc.parentClass = parentClass
        }
    }
    
}
