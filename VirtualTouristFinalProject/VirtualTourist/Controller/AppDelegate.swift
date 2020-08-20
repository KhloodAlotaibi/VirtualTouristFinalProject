//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Khlood on 7/29/20.
//  Copyright © 2020 Khlood. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let dataController = DataController(modelName: "VirtualTourist")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        dataController.load()
        let navigationController = window?.rootViewController as! UINavigationController
        let travelLocationsMapViewController = navigationController.topViewController as! TravelLocationsMapViewController
        travelLocationsMapViewController.dataController = dataController
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        saveContext()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }

    func saveContext () {
        try? dataController.viewContext.save()
    }
}
