//  Health Bars
//
//  Team: Team Rhythm
//
//  Fail.swift
//  Fail view for LongTones
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

class Fail: UIViewController, ProgressBarProtocol {
    
    var activityMode: ActivityMode = ._none
    var activity: Activity = ._none
    
    //MARK: Outlets
    @IBOutlet weak var activityNameLabel: UILabel!
    
    @IBAction func swipeLeftGesture(_ sender: UISwipeGestureRecognizer) {
        switch activity {
        case .LongTones:
            performSegue(withIdentifier: "segue_unwindtoLongTones", sender: self)
        case .ShakeIt:
            performSegue(withIdentifier: "segue_unwindtoShakeIt", sender: self)
        case .GuessThatInstrument:
            performSegue(withIdentifier: "segue_unwindtoGTI", sender: self)
            
        case ._none:
            NSLog("activity is _default in Fail screen, this should never happen")
        }
    }
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
        case .ShakeIt:
            titleText = "SHAKE IT"
        case .GuessThatInstrument:
            //TODO: make text dynamic so this fits properly
            titleText = "GUESS THAT INSTRUMENT"
            
        case ._none:
            NSLog("activity is _default in Fail screen, this should never happen")
        }
        progressBar.setVars(new_titleText: titleText)
        
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
