//
//  HealthBarsController.swift
//  HeathBarsUI
//
//  Created by Reem Mustafa on 2019-11-11.
//  Copyright © 2019 ESKIKURT. All rights reserved.
//

import UIKit

class HealthBarsController: UIViewController {
    /*
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var labe2: UILabel!
    @IBOutlet weak var labe3: UILabel!
    
    let relativeFontCpnstant1: CGFloat = 0.046
    let relativeFontCpnstant3: CGFloat = 0.060*/
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
       /* label1.font=label1.font.withSize(self.view.frame.height = relativeFontCpnstant1)
        
        label3.font=label3.font.withSize(self.view.frame.height = relativeFontCpnstant3)*/
        
        setCustomBackImage()
        
    }
    
    func setCustomBackImage(){
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "Button: Home.png")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "Button: Home.png")
    }
}

