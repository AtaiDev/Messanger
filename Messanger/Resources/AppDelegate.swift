//
//  AppDelegate.swift
//  Messanger
//
//  Created by admin on 2/1/22.


import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        
        var flag: Bool = false
        if ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                  annotation: options[UIApplication.OpenURLOptionsKey.annotation]) {
            
            // Handle Facebook URL scheme
            flag = ApplicationDelegate.shared.application(app, open: url,
                                                          sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        } else {
            // Handle Google URL scheme
            flag = GIDSignIn.sharedInstance.handle(url)
        }
        return flag
        
    }
}



