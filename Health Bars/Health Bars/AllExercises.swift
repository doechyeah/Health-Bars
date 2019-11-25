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

class NavigationMenu: UIViewController {
    
    @IBOutlet weak var testView: ProgressBar!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        testView.setVars(new_titleText: "MAIN MENU")
    }
    
    // unwind segue function, called from other views
    @IBAction func unwindToNavigationMenu(_ unwindSegue: UIStoryboardSegue) {
        //let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
}
