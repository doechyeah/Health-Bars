//
//  NavigationController.swift
//  Health Bars
//
//  Created by Michael Lin on 2019-11-22.
//  Copyright © 2019 Team Rhythm. All rights reserved.
//

import UIKit

// the three activities
enum Activity {
    // avoid conflict with optionals' .none
    case _none
    case LongTones
    case ShakeIt
    case GuessThatInstrument
}

enum ActivityMode {
    // avoid conflict with optionals' .none
    case _none
    case AllExercises
    case DailyExercises
}

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
