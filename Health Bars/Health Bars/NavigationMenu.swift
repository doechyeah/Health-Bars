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

import UIKit

//TODO: read from db and choose where to go for daily exercises
class NavigationMenu: UIViewController {
    
    @IBOutlet weak var progressBar: ProgressBar!
    
    var completedExercises: Array<Activity> = []
    var doneAllDailyExercises: Bool = false
    var nextDailyExercise: Activity = ._none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.setVars(new_titleText: "MAIN MENU")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //read from db here
    }
    
    @IBAction func dailyExercisesPressed(_ sender: UIButton) {
        NSLog("Daily Exercises button pressed")
        
    }
    
    // unwind segue function, called from other views
    @IBAction func unwindToNavigationMenu(_ unwindSegue: UIStoryboardSegue) {
        //let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
}
