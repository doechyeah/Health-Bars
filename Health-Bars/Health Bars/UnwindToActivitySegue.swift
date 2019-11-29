//  Health Bars
//
//  Team: Team Rhythm
//
//  UnwindToActivitySegue.swift
//  Custom animation for unwind segue to, animation is performed in the other direction
//
//  Developers:
//  Michael Lin
//
//  Copyright © 2019 Team Rhythm. All rights reserved.
//
//  Changelog:
//  2019-11-15: Created
//

import UIKit

class UnwindToActivitySegue: UIStoryboardSegue {
    
    override func perform() {
        NSLog("my custon segue perform()")
        
        let toViewController = destination
        let fromViewController = source
        
        let containerView = fromViewController.view.superview
        let screenBounds = UIScreen.main.bounds
        
        let finalToFrame = screenBounds
        let finalFromFrame = finalToFrame.offsetBy(dx: -screenBounds.size.width, dy: 0)
        
        toViewController.view.frame = finalToFrame.offsetBy(dx: screenBounds.size.width, dy: 0)
        containerView?.addSubview(toViewController.view)
        
        UIView.animate(withDuration: 2, animations: {
            toViewController.view.frame = finalToFrame
            fromViewController.view.frame = finalFromFrame
        }, completion: { finished in
            let fromVC: UIViewController = self.source
            let toVC: UIViewController = self.destination
            // more general than popViewController
            fromVC.navigationController?.popToViewController(toVC, animated: false)
            //debug
            NSLog("\(toVC.navigationController?.viewControllers.debugDescription ?? "can't get stack!")")
        })
        
    }
}
