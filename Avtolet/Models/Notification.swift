//
//  Notification.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 03.04.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import Foundation
import UserNotifications

struct Notification: Codable {
    let image: String?
    let isBackground: Bool?
    let payload: NotificationPayload?
    let title: String?
    let message: String?
    let timestamp: String?
    
    enum CodingKeys: String, CodingKey {
        case isBackground = "is_background"
        case image, payload, title, message, timestamp
    }
    
    static func create(userInfo: [AnyHashable: Any]) -> Notification? {
        guard let notificationData = userInfo["data"] as? String else { return nil }
        guard let data = notificationData.data(using: String.Encoding.utf8) else { return nil }
        guard let object = try? JSONDecoder().decode(Notification.self, from: data) else { return nil }
        return object
    }
    
}

enum NotificationAction: String, Codable {
    case performerCompletedOrder, statusPerformerChanged, locationPerformerChanged, newPerformer, clientStatusChanged, newMessage
}

struct NotificationPayload: Codable {
    let performer: OrderPerformerInfo?
    let performers: [OrderPerformer]?
    let text: String?
    let userId: Int?
    let timestamp: TimeInterval?
    let action: NotificationAction?
    let status: Int?
}
