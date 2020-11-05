//
//  AppDelegate.swift
//  AppsFlyerSDKLessSKAdNetworkClient_Example-Swift
//
//  Created by Ivan Obodovskyi on 02.11.2020.
//  Copyright © 2020 Ivan. All rights reserved.
//

import UIKit
import AppsFlyerSDKLessSKAdNetworkClient
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow? 
    private let uid = "YOUR_APPSFLYER_ID"; //AppsFlyerLib.shared().getAppsFlyerUID()
    private let appId = "YOUR_APP_ID"; //ID - is a string with following format @"idXXXXXXXX"
    private let devKey = "YOUR_DEV_KEY";
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AFSDKLessClient.shared.requestConversionValue(withUID: self.uid, devKey: self.devKey, appID: self.appId) { (cv, error) in
            if let cv = cv?.intValue {
                AFSDKLessClient.shared.updateConversionValue(cv)
                AFSDKLessClient.shared.registerForAdNetworkAttribution()
            }
                
        }
        if #available(iOS 13.0, *) {
            // Test with `e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"scheduleEventAF"]`
            BGTaskScheduler.shared.register(forTaskWithIdentifier: "scheduleEventAF", using: nil) { (task) in
                    self.handleAppRefresh(task: task as! BGAppRefreshTask)
            }
        }
           
        UIApplication.shared.setMinimumBackgroundFetchInterval(3600 * 8)
        if #available(iOS 13.0, *) {
            scheduleAppRefresh()
        }
        // Set minimum timeout interval to call background task.
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AFSDKLessClient.shared.requestConversionValue(withUID: uid, devKey: devKey, appID: appId) { (conversion, error) in
            if let cv = conversion?.intValue {
                AFSDKLessClient.shared.updateConversionValue(cv)
                AFSDKLessClient.shared.registerForAdNetworkAttribution()
                completionHandler(.newData)
            } else {
                completionHandler(.failed)
            }
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if #available(iOS 13.0, *) {
            scheduleAppRefresh()
        }
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

@available(iOS 13.0, *)
extension AppDelegate {
        func scheduleAppRefresh() {
            let request = BGAppRefreshTaskRequest(identifier: "scheduleEventAF")
            // Fetch no earlier than 15 seconds from now
            request.earliestBeginDate = Date(timeIntervalSinceNow: 3600 * 8)
            
            do {
                try BGTaskScheduler.shared.submit(request)
            } catch {
                print("Could not schedule app refresh: \(error)")
            }
        }
        
        func handleAppRefresh(task: BGAppRefreshTask) {
            scheduleAppRefresh()
            // Create an operation that performs the main part of the background task
            let operation = Operation()
            
            // Provide an expiration handler for the background task
            // that cancels the operation
            task.expirationHandler = {
                print("log event task scheduler cancel")
            }
            
            // Inform the system that the background task is complete
            // when the operation completes
            operation.completionBlock = { [weak self] in
                guard let self = self else { return }
                AFSDKLessClient.shared.requestConversionValue(withUID: self.uid, devKey: self.devKey, appID: self.appId) { (cv, error) in
                    if let cv = cv?.intValue {
                        AFSDKLessClient.shared.updateConversionValue(cv)
                        AFSDKLessClient.shared.registerForAdNetworkAttribution()
                        task.setTaskCompleted(success: true)
                    } else {
                        task.setTaskCompleted(success: false)
                    }
                        
                }
            }
            
            // Start the operation
            OperationQueue.main.addOperation(operation)
        }
}

