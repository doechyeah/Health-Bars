//  Health Bars
//
//  Team: Team Rhythm
//
//  AllExercises.swift
//  All exercises menu which lists all the exercises available
//
//  Developers:
//  Michael Lin
//  Alvin David
//
//  Copyright © 2019 Team Rhythm. All rights reserved.
//
//  Changelog:
//  2019-11-01: Created
//

import Foundation

import UIKit

// don't need progress bar protocol because unwind button is not needed
class NavigationMenu: UIViewController {
    
    @IBOutlet weak var progressBar: ProgressBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.setVars(new_titleText: "MAIN MENU")
    }
    
    // unwind segue function, called from other views
    @IBAction func unwindToNavigationMenu(_ unwindSegue: UIStoryboardSegue) {
        //let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
}
