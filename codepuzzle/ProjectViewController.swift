//
//  ProjectViewController.swift
//  codepuzzle
//
//  Created by Jared Cosulich on 8/8/17.
//  Copyright © 2017 Irrational Design. All rights reserved.
//

import Foundation

class ProjectViewController: UIViewController {
    
    @IBOutlet weak var projectTitleView: UIView!
    
    @IBOutlet weak var projectTitle: UITextField!
    
    var projectLoader: ProjectLoader!
    
    var project: CodeProject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        projectLoader = ProjectLoader(appDelegate: appDelegate)
        
        print("EXISTING PROJECTS: \(projectLoader.projects.count)")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func newProjectButton(_ sender: UIButton) {
        projectTitleView.isHidden = false
    }
    
    @IBAction func startProjectButton(_ sender: UIButton) {
        var title = projectTitle.text
        if (title?.characters.count == 0) {
            title = "Project \(projectLoader.projects.count)"
        }
        project = projectLoader.addProject(title: projectTitle.text!)
        performSegue(withIdentifier: "start-project-segue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "start-project-segue" {
            let dvc = segue.destination as! MenuViewController
            dvc.project = project
        }
    }
    
    
}

