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
    private let uid = "YOUR_UNIQUE_ID";
      private let appId = "YOUR_APP_ID"; //ID - is a string with following format @"idXXXXXXXX"
      private let devKey = "YOUR_DEV_KEY";
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            AFSDKLessClient.shared.registerForAdNetworkAttribution()
            
            if self.isDailyUpdateConversionWindowExpired() {
                AFSDKLessClient.shared.requestConversionValue(withUID: self.uid, devKey: self.devKey, appID: self.appId) { (result, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                    }
                    
                    if let result = result {
                        if #available(iOS 13.0, *) {
                            self.updateSKANConversion(with: result)
                        }
                    }
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
            if self.isDailyUpdateConversionWindowExpired() {
                AFSDKLessClient.shared.requestConversionValue(withUID: uid, devKey: devKey, appID: appId) { (result, error) in
                    if let result = result {
                        if #available(iOS 13.0, *) {
                            self.updateSKANConversion(with: result)
                        }
                        UserDefaults.standard.setValue(Date(), forKey: "kSDKLessWindow")
                        completionHandler(.newData)
                    } else {
                        completionHandler(.failed)
                    }
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
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        }
    }


    extension AppDelegate {
        private func isDailyUpdateConversionWindowExpired() -> Bool {
            // If there is no "kSDKLessWindow" value in UserDefaults, return true.
            guard let date = UserDefaults.standard.value(forKey: "kSDKLessWindow") as? Date else { return true }
            // If timeDiff == nil, that means, that `date` value is 'nil', return false
            guard let timeDiff = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour else { return false }
            //If difference between current time and stored 'kSDKLessWindow' is more than 24 hours, return true
            return timeDiff > 24
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
                operation.completionBlock = { [unowned self] in
                    if self.isDailyUpdateConversionWindowExpired() {
                        AFSDKLessClient.shared.requestConversionValue(withUID: self.uid, devKey: self.devKey, appID: self.appId) { (result, error) in
                            if let result = result {
                                updateSKANConversion(with: result)
                                UserDefaults.standard.setValue(Date(), forKey: "kSDKLessWindow")
                                task.setTaskCompleted(success: true)
                            } else {
                                task.setTaskCompleted(success: false)
                            }
                                
                        }
                    }
                }
                
                // Start the operation
                OperationQueue.main.addOperation(operation)
            }
        
        
        // This method contains all available SKAN upcv API usage examples.
        // Please, choose one, depending on your expected postback version + iOS version, according to the Apple SKAdNetwork doc
        // These methods are basically SKAdNetwork API wrappers, you can call Apple API directly.
        func updateSKANConversion(with message: SDKLessS2SMessage) {
            // Example for iOS 16.1 version may also contain `lockWindow` parameter
            if #available(iOS 16.1.1, *) {
                AFSDKLessClient.shared.updatePostbackConversionValue(Int(message.conversionValue), coarseValue: message.getCoarseValueRepresentation()) { skanErr in
                    print("SKAN Err: \(skanErr?.localizedDescription)")
                }
            }
            
            
            if #available(iOS 15.4, *) {
                AFSDKLessClient.shared.updatePostbackConversionValue(Int(message.conversionValue)) { skanErr in
                    print("SKAN Err: \(skanErr?.localizedDescription)")
                }
            }
            
            
            // Example for iOS 11.3 and higher
            AFSDKLessClient.shared.updateConversionValue(Int(message.conversionValue))
        }
    }


