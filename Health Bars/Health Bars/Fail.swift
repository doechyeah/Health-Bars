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

class Fail: UIViewController {
    
    var activity: Activity = ._default
    
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
            
        case ._default:
            NSLog("activity is _default in Fail screen, this should never happen")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog(self.debugDescription)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        switch activity {
        case .LongTones:
            activityNameLabel.text = "LONG TONES"
        case .ShakeIt:
            activityNameLabel.text = "SHAKE IT"
        case .GuessThatInstrument:
            //TODO: make text dynamic so this fits properly
            activityNameLabel.text = "GUESS THAT INSTRUMENT"
            
        case ._default:
            NSLog("activity is _default in Fail screen, this should never happen")
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
