//
//  SceneDelegate.swift
//  alamotesting
//
//  Created by Daniel Song on 2019-12-01.
//  Copyright © 2019 Daniel Song. All rights reserved.
//

import UIKit
import SwiftUI
import Alamofire
import Dispatch

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var test: Dictionary<String, Any> = [:]
    let x = testme()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()
//        let sem = DispatchSemaphore(value: 0)
        
        
        sleep(3)
        test = x.test
//        sem.wait()
//        postCreatePlayer(success: { (response) -> Void in
//            self.test = response!
//        })
//        )
//        CreatePlayer()
        dump(test)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

//        return test


}

func postCompCreate(compHandler: @escaping (Dictionary<String, Any>?) -> Void) {
    postCreatePlayer(success: compHandler)
//    dump(compHandler)
    print("TEST HANDLE")
}

//, failure: @escaping (_ error: NSError?) -> Void
class testme {
    var test: Dictionary<String, Any> = [:]
        func CreatePlayer() {
        AF.request("https://advanture.wixsite.com/health-bars-g9/_functions-dev/CreatePlayer", method: .post,  parameters: test, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    self.test = value as! Dictionary<String, Any>
    //                dump(test)
                case .failure(let error):
                    print(error)
                   
                }
        }
    }
    init() {
        CreatePlayer()
    }
}
func postCreatePlayer(success: @escaping (_ response:Dictionary<String, Any>?) -> Void) {
    AF.request("https://advanture.wixsite.com/health-bars-g9/_functions-dev/CreatePlayer", method: .post,  parameters: ["title":"testplayer"], encoding: JSONEncoding.default)
        .responseJSON { response in
                switch response.result {
                case .success(let value):
                    success(value as? Dictionary<String, Any>)
//                    dump(value)
                case .failure(let error):
                    print(error)
//                    failure(error as NSError)
                }
            print("wait")
        }
    
}


