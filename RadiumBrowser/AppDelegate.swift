//
//  AppDelegate.swift
//  RadiumBrowser
//
//  Created by bslayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import Then
import SnapKit
import RealmSwift
import StoreKit
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
	
	@objc var mainController: MainViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
		
		#if arch(i386) || arch(x86_64)
			let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
			NSLog("Document Path: %@", documentsPath)
		#endif
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                if purchase.transaction.transactionState == .purchased || purchase.transaction.transactionState == .restored {
                    if purchase.needsFinishTransaction {
                        UserDefaults.standard.set(true, forKey: SettingsKeys.adBlockPurchased)
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("purchased: \(purchase)")
                }
            }
        }
        
        MigrationManager.shared.attemptMigration()
		
        WebServer.shared.startServer()
        
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: SettingsKeys.firstRun) {
            defaults.set(true, forKey: SettingsKeys.firstRun)
            performFirstRunTasks()
        }
        
        #if DEBUG
            defaults.set(true, forKey: SettingsKeys.adBlockPurchased)
        #endif
        defaults.set(false, forKey: SettingsKeys.adBlockLoaded)
        defaults.set(false, forKey: SettingsKeys.stringLiteralAdBlock)
        defaults.set(false, forKey: SettingsKeys.blackHostsLoaded)
        
        mainController = MainViewController()
        self.window?.rootViewController = mainController
        self.window?.makeKeyAndVisible()
        
        AppReview.triggerEvent()
        AppReview.tryToExecute { didExecute in
            if didExecute {
                if #available(iOS 10.3, *) {
                    SKStoreReviewController.requestReview()
                }
            }
        }
        
        return true
    }

    func performFirstRunTasks() {
        UserDefaults.standard.set(true, forKey: SettingsKeys.trackHistory)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions 
        // (such as an incoming phone call or SMS message) or when the user quits the application and it begins the 
        // transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks.
        // Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to 
        // restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; 
        // here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive.
        // If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        mainController?.tabContainer?.saveBrowsingSession()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        do {
            let source = try String(contentsOf: url, encoding: .utf8)
            mainController?.openEditor(withSource: source, andName: url.deletingPathExtension().lastPathComponent)
        } catch {
            print("Could not open file")
        }
        
        return true
    }
}
