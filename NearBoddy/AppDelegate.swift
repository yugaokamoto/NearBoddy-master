//
//  AppDelegate.swift
//  NearBoddy
//
//  Created by 岡本　優河 on 2018/07/15.
//  Copyright © 2018年 岡本　優河. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDynamicLinks
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UITabBar.appearance().tintColor = UIColor.black
        FirebaseApp.configure()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let dynamiclink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url){
            print("I am handling a link through the openURL method!")
            self.handleIncomingDynamicLink(dynamiclink: dynamiclink)
            return true
        }
        return false
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
//        if let incomingURL = userActivity.webpageURL {
//            let linkhandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { [weak self] (dynamiclink, error) in
//                guard let strongSelf = self else{ return }
//                if let dynamiclink = dynamiclink, let _ = dynamiclink.url{
//                    strongSelf.handleIncomingDynamicLink(dynamiclink: dynamiclink)
//                }
//            }
//            return linkhandled
//        }
//        return false
       
          return userActivity.webpageURL.flatMap(handlePasswordlessSignIn)!
        
    }

    func handleIncomingDynamicLink(dynamiclink:DynamicLink){
        print("Your Incoming link parameter is \(dynamiclink.url)")
      
    }
    
    func handlePasswordlessSignIn(withURL url: URL) -> Bool {
        let link = url.absoluteString
     
        if Auth.auth().isSignIn(withEmailLink: link) {
            UserDefaults.standard.set(link, forKey: "Link")
            return true
        }
        return false
    }
    
}

