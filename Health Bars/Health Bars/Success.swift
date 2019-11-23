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

class Success: UIViewController {
    
    var activity: Activity = ._default
    
    //MARK: Outlets
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var activityIconImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        switch activity {
        case .LongTones:
            activityNameLabel.text = "LONG TONES"
            activityIconImage.image = UIImage(named: "microphone")
        case .ShakeIt:
            activityNameLabel.text = "SHAKE IT"
            activityIconImage.image = UIImage(named: "equalizer")
        case .GuessThatInstrument:
            //TODO: make text dynamic so this fits properly
            activityNameLabel.text = "GUESS THAT INSTRUMENT"
            activityIconImage.image = UIImage(named: "memory")
            
        case ._default:
            NSLog("activity is _default in Success screen, this should never happen")
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
