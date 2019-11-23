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
    case _default  // should never be used except for initialization
    case LongTones
    case ShakeIt
    case GuessThatInstrument
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
