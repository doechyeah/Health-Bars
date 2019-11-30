//  Health Bars
//
//  Team: Team Rhythm
//
//  Success.swift
//  Success view for LongTones
//
//  Developers:
//  Michael Lin
//  Alvin David
//
//  Copyright © 2019 Team Rhythm. All rights reserved.
//
//  Changelog:
//  2019-10: Created
//

import UIKit

class Success: UIViewController, ProgressBarProtocol {
    
    let PDB = ProgClass.sharedInstance
    
    var activityMode: ActivityMode = ._none
    var activity: Activity = ._none
    var nextActivity: Activity = ._none
    
    var dailyExercisesDoneToday: [Bool] = [false, false, false]
    
    //MARK: Outlets
    @IBOutlet weak var swipeBoxLabel: UILabel!
    @IBOutlet weak var activityIconImage: UIImageView!
    
    func unwindSegueFromView() {
        NSLog("Success delegate unwind function")
        performSegue(withIdentifier: "segue_unwindtoNavigationMenu", sender: self)
    }
    
    
    @IBOutlet weak var progressBar: ProgressBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //TODO: pass data that was sent from AllExercises
        var titleText: String = ""
        
        switch activity {
        case .LongTones:
            titleText = "LONG TONES"
            activityIconImage.image = UIImage(named: "microphone")
        case .ShakeIt:
            titleText = "SHAKE IT"
            activityIconImage.image = UIImage(named: "equalizer")
        case .GuessThatInstrument:
            //TODO: make text dynamic so this fits properly
            titleText = "GUESS THAT INSTRUMENT"
            activityIconImage.image = UIImage(named: "memory")
            
        case ._none:
            NSLog("activity is _default in Success screen, this should never happen")
        }
        progressBar.setVars(new_titleText: titleText)
        dailyExercisesDoneToday = PDB.readDAct()
        progressBar.setCompletedActivities(activitiesCompleted: dailyExercisesDoneToday)
        
        dump(activityMode)

        nextActivity = determineNextActivity(currentActivity: activity)
        setSwipeBoxText(nextActivity: nextActivity)
    }
    
    // send data with segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        NSLog("success prepare()")
        NSLog(segue.destination.debugDescription)
        if let vc = segue.destination as? ShakeIt {
            NSLog("is ShakeIt")
            vc.activityMode = activityMode
        }
        if let vc = segue.destination as? GuessThatInstrument {
            NSLog("is GuessThatInstrument")
            vc.activityMode = activityMode
        }
    }
    
    @IBAction func swipeRightGesture(_ sender: UISwipeGestureRecognizer) {
        NSLog("success swipe right")
        //TODO: change swipe text based on activityMode and nextActivity
        if activityMode == .AllExercises {
            performSegue(withIdentifier: "segue_unwindtoAllExercises", sender: self)
        } else {
            if nextActivity == .ShakeIt {
                performSegue(withIdentifier: "segue_gotoShakeIt", sender: self)
            } else if nextActivity == .GuessThatInstrument {
                performSegue(withIdentifier: "segue_gotoGTI", sender: self)
            } else {
                performSegue(withIdentifier: "segue_unwindtoNavigationMenu", sender: self)
            }
        }
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
    
    func setSwipeBoxText(nextActivity: Activity) {
        if activityMode == .DailyExercises {
            if nextActivity != ._none {
                swipeBoxLabel.text = "SWIPE RIGHT FOR\nNEXT EXERCISE\n>>>"
            } else {
                swipeBoxLabel.text = "SWIPE RIGHT TO\nRETURN TO MENU\n>>>"
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
