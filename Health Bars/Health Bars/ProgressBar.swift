//
//  ProgressBar.swift
//  Health Bars
//
//  Created by Michael Lin on 2019-11-24.
//  Copyright © 2019 Team Rhythm. All rights reserved.
//

import UIKit

//TODO: add database reading
class ProgressBar: UIView {

    //MARK: Status variables
    var activityMode: ActivityMode!
    var currentActivity: Activity!
    
    //MARK: Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleTextLabel: UILabel!
    
    @IBOutlet weak var homeButton: UIButton!
    
    @IBOutlet weak var iconsStackView: UIStackView!
    
    @IBOutlet weak var voiceIcon: UIImageView!
    @IBOutlet weak var rhythmIcon: UIImageView!
    @IBOutlet weak var memoryIcon: UIImageView!
    
    // Custom view in code
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    // Custom view in storyboard
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ProgressBar", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func setVars(new_activityMode: ActivityMode = ._none, new_currentActivity: Activity = ._none, new_titleText: String) {
        activityMode = new_activityMode
        currentActivity = new_currentActivity
        titleTextLabel.text = new_titleText
        setVisibleElements()
    }
    
    //TODO: read database here or make another function for that
    func setVisibleElements() {
        
    }
    
    // add checkmark on top of icon if completed for daily exercises
    func setCompletedActivityMarks() {
        
    }
    
    // show current activity with green circle border
    func setCurrentActivityMark() {
        
    }
}
