//
//  AppDelegate.swift
//  Time & Attendance
//
//  Created by Roman Chubatyy on 27/7/20.
//  Copyright © 2020 OlivsMatic Pty Ltd. All rights reserved.
//

import UIKit
import SwiftPublicIP
import Reachability

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window : UIWindow?
    private var reachability:Reachability!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if #available(iOS 13.0, *) {
                    // In iOS 13 setup is done in SceneDelegate
                } else {
                    SQLHelper.instance.openDatabase()
                    
                    if (LoginService.instance.loggedIn){
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let checkInVC = FilesListService.instance.dbSelected ?
                            storyboard.instantiateViewController(withIdentifier: "CheckInVC") as! CheckInViewController :
                            storyboard.instantiateViewController(withIdentifier: "BusinessFileVC") as! BusinessFileViewController
                        let nav = UINavigationController(rootViewController: checkInVC)
                        nav.isNavigationBarHidden = true
                        self.window?.rootViewController = nav
                        self.window?.makeKeyAndVisible()
                    }
                }
        return true
    }
    
    /*func obtainPublicIP(){
        SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) { (string, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let string = string {
                PUBLIC_IP = string
            }
        }
    }*/
    
    @objc func checkForReachability(notification:NSNotification){
        let networkReachability = notification.object as! Reachability;
        _ = networkReachability.connection
        /*switch(remoteHostStatus){
        case .wifi:
            obtainPublicIP()
        case .cellular:
            obtainPublicIP()
        default:
            PUBLIC_IP = "127.0.0.1"
        }*/
        }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

