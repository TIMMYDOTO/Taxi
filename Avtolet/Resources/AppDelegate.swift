//
//  AppDelegate.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 26.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import SVProgressHUD
import GooglePlaces
import GoogleMaps
import UserNotifications
import Firebase
import IQKeyboardManagerSwift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var networkActivityCounter: Int = 0 {
        didSet {
            UIApplication.shared.isNetworkActivityIndicatorVisible = networkActivityCounter > 0
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        FirebaseApp.configure()
        
        IQKeyboardManager.shared.enable = true

        PushNotificationsService.shared.setup()
        checkFirstLaunch()
        ChatService.shared.setup()
        GMSServices.provideAPIKey(kGoogleApiKey)
        GMSPlacesClient.provideAPIKey(kGoogleApiKey)
        setupAppearance()
        if User.isAuthorized {
            loadInterface("Main")
        } else {
           
            loadInterface("Auth")
        }
        return true
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
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let notification = Notification.create(userInfo: userInfo) else { completionHandler(.noData) ; return }
        if application.applicationState != .active {
            if notification.isBackground != true {
                showLocalNotification(notification: notification, userInfo: userInfo)
            }
            AvtoletService.shared.handleBackggroundWork(object: notification)
        } else {
            if notification.isBackground == true {
                PushNotificationsService.shared.handleSilentForegroundNotification(userInfo: userInfo)
            } else {
                showLocalNotification(notification: notification, userInfo: userInfo)
            }
        }
        completionHandler(.newData)
    }
}

extension AppDelegate {
    fileprivate func loadInterface(_ named: String) {
        let vc = UIStoryboard(name: named, bundle: nil).instantiateInitialViewController()
        let window = UIWindow()
        window.rootViewController = vc
        self.window = window
        window.makeKeyAndVisible()
    }
    
    fileprivate func checkFirstLaunch() {
        User.checkFirstLaunch()
    }
    
    fileprivate func setupAppearance() {
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setForegroundColor(UIColor.blue_main)
        UIBarButtonItem.appearance().tintColor = .white
    }
    
    fileprivate func showLocalNotification(notification: Notification, userInfo: [AnyHashable: Any]) {
        guard let title = notification.title, let alert = notification.message else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = alert
        content.userInfo = userInfo
        content.sound = UNNotificationSound.init(named: "notification.mp3")
        let identifier = UUID().uuidString
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

