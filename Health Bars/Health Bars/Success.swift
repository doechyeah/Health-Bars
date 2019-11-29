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
    
    var activityMode: ActivityMode = ._none
    var activity: Activity = ._none
    
    //MARK: Outlets
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
        
        NSLog("\(activityMode)")
    }
    
    @IBAction func swipeRightGesture(_ sender: UISwipeGestureRecognizer) {
        NSLog("success swipe right")
        //TODO: determine whether to go back to all exercises or continue to next activity
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
