//
//  PushNotificationsService.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 02.04.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import UserNotifications
import RxCocoa

typealias NotificationSwowOptionsHandler = (UNNotificationPresentationOptions) -> ()
typealias NotificationInteractionHandler = () -> (type: NotificationResponseType, userInfo: [AnyHashable: Any])
typealias NotificationShowOptionsTuple = (userInfo: [AnyHashable: Any], handler: NotificationSwowOptionsHandler?)

enum NotificationResponseType: String {
    case `default`, dismiss
    static func type(_ value: String) -> NotificationResponseType {
        return value == UNNotificationDefaultActionIdentifier ? .default : .dismiss
    }
}

class PushNotificationsService: NSObject {

    fileprivate static let defaultOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
    fileprivate static let presentationOptions: UNNotificationPresentationOptions = [.alert, .sound, .badge]
    
    static let shared = PushNotificationsService()
    fileprivate(set) var granted: BehaviorRelay<Bool?> = BehaviorRelay(value: nil)
    fileprivate(set) var notificationShowOptionsHandler: BehaviorRelay<NotificationShowOptionsTuple?> = BehaviorRelay(value: nil)
    fileprivate(set) var notificationInteractionHandler: BehaviorRelay<NotificationInteractionHandler?> = BehaviorRelay(value: nil)
    var userData: BehaviorRelay<[String: Any]> = BehaviorRelay(value: [:])
    
    fileprivate var alwaysHandle = true
    
    private override init() {}
}

// MARK: - Setup

extension PushNotificationsService {
    func setup(options: UNAuthorizationOptions = PushNotificationsService.defaultOptions, alwaysHandle: Bool = true) {
        self.alwaysHandle = alwaysHandle
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: options) { [unowned self] (granted, _) in
            self.granted.accept(granted)
            DispatchQueue.main.async {
                if granted { UIApplication.shared.registerForRemoteNotifications() }
            }
        }
    }
}

// MARK: - NotificationsHandling

extension PushNotificationsService {
    fileprivate func handleNotification(response: UNNotificationResponse) {
        defer { self.notificationInteractionHandler.accept(nil) }
        let userInfo = response.notification.request.content.userInfo
        notificationInteractionHandler.accept { () -> (NotificationResponseType, [AnyHashable : Any]) in
            return (NotificationResponseType.type(response.actionIdentifier), userInfo)
        }
    }
    fileprivate func optionsForNotification(notifiation: UNNotification, handler: @escaping NotificationSwowOptionsHandler) {
        defer { self.notificationShowOptionsHandler.accept(nil) }
        let userInfo = notifiation.request.content.userInfo
        let tuple: NotificationShowOptionsTuple = (userInfo, handler)
        self.notificationShowOptionsHandler.accept(tuple)
    }
    func handleSilentForegroundNotification(userInfo: [AnyHashable: Any]) {
        defer { self.notificationShowOptionsHandler.accept(nil) }
        let tuple: NotificationShowOptionsTuple = (userInfo, nil)
        self.notificationShowOptionsHandler.accept(tuple)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension PushNotificationsService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        handleNotification(response: response)
        completionHandler()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        var handled = false
        optionsForNotification(notifiation: notification) { 
            handled = true
            completionHandler($0)
        }
        guard alwaysHandle else { return }
        // Если никто не обработал
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (_) in
            guard !handled else { return }
            completionHandler(PushNotificationsService.presentationOptions)
        }
    }
}
