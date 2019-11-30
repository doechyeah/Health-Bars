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

import UIKit

// don't need progress bar protocol because unwind button is not needed
class AllExercises: UIViewController, ProgressBarProtocol {
    
    @IBOutlet weak var progressBar: ProgressBar!
    
    func unwindSegueFromView() {
        NSLog("All Exercises delegate unwind function")
        performSegue(withIdentifier: "segue_unwindtoNavigationMenu", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.delegate = self
        progressBar.setVars(new_titleText: "ALL EXERCISES")
    }
    
    // send data with segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        NSLog("all exercises prepare()")
        NSLog(segue.destination.debugDescription)
        NSLog(type(of: segue.destination).debugDescription())
        
        if let vc = segue.destination as? LongTones {
            NSLog("is LongTones")
            vc.activityMode = .AllExercises
        }
        if let vc = segue.destination as? ShakeIt {
            NSLog("is ShakeIt")
            vc.activityMode = .AllExercises
        }
        if let vc = segue.destination as? GuessThatInstrument {
            NSLog("is GuessThatInstrument")
            vc.activityMode = .AllExercises
        }
    }
    
    // unwind segue function, called from other views
    @IBAction func unwindToAllExercises(_ unwindSegue: UIStoryboardSegue) {
        //let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
}
