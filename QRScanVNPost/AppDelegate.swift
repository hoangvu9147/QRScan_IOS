//
//  AppDelegate.swift
//  QRScanVNPost
//
//  Created by lhvu on 2019/06/19.
//  Copyright © 2019 lhvu. All rights reserved.
//

import UIKit
import GRDB
import IQKeyboardManagerSwift


// The shared database queue
var dbQueue: DatabaseQueue!
var dbPath : String!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

     var barcodeScanZebra = BarcodeZebraConnect()
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupDatabase(in: application)
        return true
    }

    private func setupDatabase(in application: UIApplication) {
        print("UIDevice:\(UIDevice.current.identifierForVendor!.uuidString)")
        let databaseURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("quickScan.sqlite")
        dbPath = databaseURL.path
        print("dataBasePath:\(databaseURL.path)")
        dbQueue = try! QuickScanDatabase.openDatabase(atPath: databaseURL.path)
        dbQueue.setupMemoryManagement(in: application)
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

