//  Health Bars
//
//  Team: Team Rhythm
//
//  NavigationMenu.swift
//
//  Developers:
//  Michael Lin
//
//  Copyright © 2019 Team Rhythm. All rights reserved.
//
//  Changelog:
//  2019-11-14: Created
//


import Foundation

import UIKit

class AllExercises: UIViewController, ProgressBarProtocol {
    
    func unwindSegueFromView() {
        NSLog("All Exercises delegate unwind function")
        performSegue(withIdentifier: "segue_unwindtoNavigationMenu", sender: self)
    }
    
    
    @IBOutlet weak var progressBar: ProgressBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.delegate = self
        progressBar.setVars(new_titleText: "ALL EXERCISES")
    }
    
    // unwind segue function, called from other views
    @IBAction func unwindToAllExercises(_ unwindSegue: UIStoryboardSegue) {
        //let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
}
