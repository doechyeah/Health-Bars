//  Health Bars
//
//  Team: Team Rhythm
//
//  ProgressBar.swift
//  Progress bar at top of views, replaces navigation bar
//
//  Developers:
//  Michael Lin
//
//  Copyright © 2019 Team Rhythm. All rights reserved.
//
//  Changelog:
//  2019-11-23: Created
//

import UIKit

// protocol meeded so that home button can be called from view controller (which adopts this protocol)
// segues can only be called from view controllers
protocol ProgressBarProtocol {
    func unwindSegueFromView()
}

//TODO: add database reading
class ProgressBar: UIView {

    var delegate: ProgressBarProtocol?
    
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
    
    // starts out hidden
    @IBOutlet weak var voiceCheckmark: UIImageView!
    @IBOutlet weak var rhythmCheckmark: UIImageView!
    @IBOutlet weak var memoryCheckmark: UIImageView!
    
    
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
    
    // set checkmarks on activity icons
    // order is memory rhythm voice
    func setCompletedActivities(activitiesCompleted: [Bool]) {
        if activitiesCompleted[0] {
            memoryCheckmark.isHidden = false
        }
        if activitiesCompleted[1] {
            rhythmCheckmark.isHidden = false
        }
        if activitiesCompleted[2] {
            voiceCheckmark.isHidden = false
        }
    }
    
    // every view controller that uses Progress Bar must call this function via outlet before displaying
    func setVars(new_activityMode: ActivityMode = ._none, new_currentActivity: Activity = ._none, new_titleText: String) {
        activityMode = new_activityMode
        currentActivity = new_currentActivity
        titleTextLabel.text = new_titleText
        setVisibleElements()
    }
    
    // home button
    @IBAction func unwindToNavigationMenuButton(_ sender: UIButton) {
        NSLog("Progress Bar home button pressed")
        self.delegate?.unwindSegueFromView()
    }
    
    //TODO: read database here or make another function for that
    func setVisibleElements() {
        if activityMode == ._none {
            iconsStackView.isHidden = true
        }
    }
    
    // show current activity with green circle border
    func setCurrentActivityMark() {
        
    }
}
