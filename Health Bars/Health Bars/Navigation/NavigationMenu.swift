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

    let PDB = ProgClass.sharedInstance
    
    @IBOutlet weak var progressBar: ProgressBar!
    
    @IBOutlet weak var dailyExercisesButtonView: UIView!
    @IBOutlet weak var dailyExercisesButton: UIButton!
    
    var doneAllDailyExercises: Bool = false
    var nextDailyExercise: Activity = ._none
    
    var dailyExercisesDoneToday: [Bool] = [false, false, false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.setVars(new_titleText: "MAIN MENU")
        progressBar.iconsStackView.isHidden = false
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //read from db here
        PDB.dumpAll()
        dailyExercisesDoneToday = PDB.readDAct()
        progressBar.setCompletedActivities(activitiesCompleted: dailyExercisesDoneToday)
        
        // if all daily exercises are done
        if dailyExercisesDoneToday == [true, true, true] {
            dailyExercisesButtonView.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            dailyExercisesButton.isEnabled = false
        }
    }
    
    @IBAction func dailyExercisesPressed(_ sender: UIButton) {
        NSLog("Daily Exercises button pressed")
        // determine next activity for daily exercises mode
        // returning ._none means done
        // order is memory, rhythm, voice
        if !dailyExercisesDoneToday[2] {
            performSegue(withIdentifier: "segue_gotoDailyExercisesLongTones", sender: self)
        } else if !dailyExercisesDoneToday[1] {
            performSegue(withIdentifier: "segue_gotoDailyExercisesShakeIt", sender: self)
        } else if !dailyExercisesDoneToday[0] {
                   performSegue(withIdentifier: "segue_gotoDailyExercisesGTI", sender: self)
        }
    }

    // send data with segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        NSLog("navigation menu prepare()")
        NSLog(segue.destination.debugDescription)
        NSLog(type(of: segue.destination).debugDescription())
        
        if let vc = segue.destination as? LongTones {
            NSLog("is LongTones")
            vc.activityMode = .DailyExercises
        }
        if let vc = segue.destination as? ShakeIt {
            NSLog("is ShakeIt")
            vc.activityMode = .DailyExercises
        }
        if let vc = segue.destination as? GuessThatInstrument {
            NSLog("is GuessThatInstrument")
            vc.activityMode = .DailyExercises
        }
    }
    
    // unwind segue function, called from other views
    @IBAction func unwindToNavigationMenu(_ unwindSegue: UIStoryboardSegue) {
        //let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    // determine next activity for daily exercises mode
    // returning ._none means done
    func determineNextActivity(currentActivity: Activity) -> Activity {
        // order is memory, rhythm, voice
        let dailyExercisesDoneToday = PDB.readDAct()
        var nextActivity: Activity = ._none
        if currentActivity == .LongTones {
            if dailyExercisesDoneToday[1] {
                if dailyExercisesDoneToday[0] {
                    nextActivity = ._none
                } else {
                    nextActivity = .GuessThatInstrument
                }
            } else {
                nextActivity = .ShakeIt
            }
        } else if currentActivity == .ShakeIt {
            if dailyExercisesDoneToday[0] {
                nextActivity = ._none
            } else {
                nextActivity = .GuessThatInstrument
            }
        } else if currentActivity == .GuessThatInstrument {
            nextActivity = ._none
        }
        return nextActivity
    }
}
