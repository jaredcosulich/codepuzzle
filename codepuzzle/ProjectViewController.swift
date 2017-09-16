//
//  ProjectViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 8/8/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation
import MagicalRecord

class ProjectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var projectTitleView: UIView!
    
    @IBOutlet weak var projectTitle: UITextField!
    
    var cardProjects = [CardProject]()
    
    var cardProject: CardProject!
    
    @IBOutlet weak var splash: UIImageView!
    
    @IBOutlet weak var startProjectButton: UIButton!
    
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        loadCardProjects()

        tableView.delegate = self
        tableView.dataSource = self
        
        startProjectButton.layer.cornerRadius = 6
        startButton.layer.cornerRadius = 6
        projectTitleView.layer.cornerRadius = 10
        
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 1,
            delay: 1,
            options: .curveEaseOut,
            animations: {
                self.splash.alpha = 0.0
            }, completion: { (position) in
                self.splash.removeFromSuperview()
            }
        )
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadCardProjects() {
        cardProjects = CardProject.mr_findAll() as! [CardProject]
        
        for cp in cardProjects {
            cp.persistedManagedObjectContext = cp.managedObjectContext!
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "Cell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
        
        let cardProject = cardProjects[indexPath.row]
        cell?.textLabel?.text = cardProject.title
        cell?.detailTextLabel?.text = "\(cardProject.cardGroups.count) Card Photos"
        
        if (cardProject.cardGroups.count > 0 && cell?.imageView != nil) {
            let thumbnail = cardProject.cardGroups.first!.image!
            cell!.imageView!.image = ImageProcessor.scale(image: thumbnail, view: tableView)
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cardProject = self.cardProjects[indexPath.row]
            cardProject.persistedManagedObjectContext.mr_save({
                (localContext: NSManagedObjectContext!) in
                cardProject.mr_deleteEntity(in: cardProject.persistedManagedObjectContext)
            }, completion: {
                (MRSaveCompletionHandler) in
                self.loadCardProjects()
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                cardProject.persistedManagedObjectContext.mr_saveToPersistentStoreAndWait()
            })
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath){
        cardProject = cardProjects[indexPath.row]
        
        if cardProject.cardGroups.count == 0 {
            performSegue(withIdentifier: "start-project-segue", sender: nil)
        } else {
            for cardGroup in cardProject.cardGroups {
                if cardGroup.isProcessed {
                } else {
                    performSegue(withIdentifier: "start-project-segue", sender: nil)
                    return
                }
            }
            performSegue(withIdentifier: "execute-processed-segue", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return cardProjects.count
    }
    
    @IBAction func startProject(_ sender: UIButton) {
        projectTitleView.alpha = 0.0
        projectTitleView.isHidden = false
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.projectTitleView.alpha = 1.0
            }
        )

        projectTitle.becomeFirstResponder()
    }
    
    @IBAction func createProject(_ sender: UIButton) {
        var title = projectTitle.text
        if (title?.characters.count == 0) {
            title = "Project \(cardProjects.count)"
        }
        MagicalRecord.save({
            (localContext: NSManagedObjectContext!) in
            self.cardProject = CardProject.mr_createEntity(in: localContext)
            self.cardProject.title = self.projectTitle.text!
            self.cardProject.persistedManagedObjectContext = localContext
        }, completion: {
            (MRSaveCompletionHandler) in
            self.cardProject.persistedManagedObjectContext.mr_saveToPersistentStoreAndWait()
            self.performSegue(withIdentifier: "start-project-segue", sender: nil)
        })
    }
    
    @IBAction func cancelStartProject(_ sender: UIButton) {
        projectTitle.resignFirstResponder()
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.projectTitleView.alpha = 0.0
            }, completion: { (position) in
                self.projectTitleView.isHidden = true
            }
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        tableView?.removeFromSuperview()
        projectTitleView?.removeFromSuperview()

        if segue.identifier == "start-project-segue" {
            let dvc = segue.destination as! MenuViewController
            dvc.cardProject = cardProject
        } else if segue.identifier == "execute-processed-segue" {
            let dvc = segue.destination as! ExecutionViewController
            dvc.cardProject = cardProject
        }
    }
    
}

