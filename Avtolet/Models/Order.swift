//
//  Order.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 30.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import Foundation
import CoreLocation

struct NewOrder: Codable {
    let token: String
    let truckCategoryId: Int
    let truckFrameId: Int
    let cargoDescription: String?
    let countLoaders: Int
    let servicesId: String?
    let routeData: Route
    let promoCodeId: Int?
}

struct ActiveOrder: Codable {
    let order: Order?
}

struct Order: Codable {
    let errorMsg: String?
    let orderId: Int?
    var performers: [OrderPerformer]?
    let routeData: Route?
    let origin: String?
    let destination: String?
    let reason: String?
    let cargoDescription: String?
    let totalPrice: Double?
    let fare: [OrderPerformerFare]?
    
    mutating func update(performers: [OrderPerformer]?) {
        self.performers = performers
    }
    
    var title: String {
        guard let orderId = orderId else { return "" }
        return "Заказ №\(orderId)"
    }
}

enum OrderPerformerStatus: Int, Codable {
    case offline = 0, online, onTheWay, onTheAddress, working, willFree, completed
    var title: String {
        switch self {
        case .offline:
            return "Недоступен"
        case .online:
            return "Свободен"
        case .onTheWay:
            return "В пути"
        case .onTheAddress:
            return "По адресу"
        case .working:
            return "Работает"
        case .willFree:
            return "Освобождается"
        case .completed:
            return "Закончил работу"
        }
    }
}

enum PerformerType: Int, Codable {
    case driver = 0, clerk
}

struct OrderPerformer: Codable {
    let fare: [OrderPerformerFare]?
    let type: PerformerType
    let endTime: TimeInterval
    let startTime: TimeInterval
    let totalFee: Double
    let performer: OrderPerformerInfo?
    var imageURL: URL? {
        guard let token = User.current.accessToken else { return nil }
        guard let id = performer?.id else { return nil }
        var result = ""
        if type == .driver {
            result = baseApiURL + "client/photoDriver/\(id)/photo_driver.jpg?token=" + token
        } else {
            result = baseApiURL + "client/photoLoader/\(id)/photo_loader.jpg?token=" + token
        }
        return URL(string: result)
    }
}

struct OrderPerformerFare: Codable {
    let name: String
    let minTime: Int
    let minPrice: Double
    let overTime: Int
    let overTimePrice: Double
    let intercityPrice: Double
    let intercityDistance: Double
    let highDemandAreaPrice: Double
    let highDemandTimePrice: Double
}

struct OrderPerformerInfo: Codable {
    let id: Int
    let auto: OrderPerformerAuto?
    let type: PerformerType
    let rating: String
    let status: OrderPerformerStatus
    let location: OrderCoordinate
    let fullName: OrderPerformerInfoName
    let phoneNumber: String
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(location.lat) ?? 0.0, longitude: Double(location.lng) ?? 0.0)
    }
    
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case id, auto, type, rating, status, location, phoneNumber
    }
    
    static func == (lhs: OrderPerformerInfo, rhs: OrderPerformerInfo?) -> Bool {
        return lhs.id == rhs?.id
    }
}

struct OrderCoordinate: Codable {
    let lat: String
    let lng: String
    let timestamp: TimeInterval?
}

struct OrderPerformerInfoName: Codable {
    let name: String
    let surname: String
    let middleName: String
}

struct OrderPerformerAuto: Codable {
    let reg: String
    let type: Int
    let frame: Int
    let model: String
    let volume: Float
    let proportions: OrderPerformerAutoProportions
}

struct OrderPerformerAutoProportions: Codable {
    let width: Float
    let height: Float
    let length: Float
    
    var descriptionString: String {
        let ls = ((NumberFormatter.volumeFormatter.string(from: length as NSNumber) ?? "") + "х")
        let ws = ((NumberFormatter.volumeFormatter.string(from: width as NSNumber) ?? "") + "х")
        let hs = ((NumberFormatter.volumeFormatter.string(from: height as NSNumber) ?? "") + " м")
        return ls + ws + hs
    }
}

struct OrdersResponse: Codable {
    let completedOrders: [ShortOrder]?
    let canceledOrders: [ShortOrder]?
}

struct ShortOrder: Codable {
    let id: Int
    let startTime: TimeInterval
    let endTime: TimeInterval
    let distanceRoute: Double
    let durationRoute: Int
    let totalPrice: Double
    
    var title: String {
        return "Заказ №\(id)"
    }
}

struct MyOrderResponse: Codable {
    let info: Order
}

struct NearbyPerformersResponse: Codable {
    let performers: [NearbyPerformer]?
}

struct NearbyPerformer: Codable {
    let id: Int
    let type: PerformerType
    let location: OrderCoordinate
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(location.lat) ?? 0.0, longitude: Double(location.lng) ?? 0.0)
    }
}

extension CLLocationCoordinate2D {
    static func == (lsh: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lsh.latitude == rhs.latitude && lsh.longitude == rhs.longitude
    }
    static func != (lsh: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lsh.latitude != rhs.latitude || lsh.longitude != rhs.longitude
    }
}
