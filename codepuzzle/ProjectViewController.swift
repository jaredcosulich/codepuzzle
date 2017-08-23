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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        cardProjects = CardProject.mr_findAll() as! [CardProject]
        
        for cp in cardProjects {
            cp.persistedManagedObjectContext = cp.managedObjectContext!
        }

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        cell?.imageView?.image = cardProject.cardGroups.first?.image
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            projectLoader.delete  (at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
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
    
    @IBAction func newProjectButton(_ sender: UIButton) {
        projectTitleView.isHidden = false
        projectTitle.becomeFirstResponder()
    }
    
    @IBAction func startProjectButton(_ sender: UIButton) {
        var title = projectTitle.text
        if (title?.characters.count == 0) {
            title = "Project \(cardProjects.count)"
        }
        MagicalRecord.save({
            (localContext: NSManagedObjectContext!) in
            self.cardProject = CardProject.mr_createEntity(in: localContext)
            self.cardProject.title = self.projectTitle.text!
            self.cardProject.persistedManagedObjectContext = localContext
        })
        performSegue(withIdentifier: "start-project-segue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "start-project-segue" {
            let dvc = segue.destination as! MenuViewController
            dvc.cardProject = cardProject
        } else if segue.identifier == "execute-processed-segue" {
            let dvc = segue.destination as! ExecutionViewController
            dvc.cardProject = cardProject
        }
    }
    
}

