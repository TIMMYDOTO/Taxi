//
//  OrdersRequest.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 30.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class OrdersRequest: CommonRequest {
    enum Constant {
        static let orderId = "orderId"
        static let reason = "reason"
        static let origin = "origin"
        static let performerId = "performerId"
        static let rating = "rating"
    }
    
    func withOrderId(_ value: Int) -> Self {
        return withParameter(key: Constant.orderId, value: value)
    }
    
    func withReason(_ value: String) -> Self {
        return withParameter(key: Constant.reason, value: value)
    }
    
    func withOrigin(_ value: RouteCoordinate) -> Self {
        return withParameter(key: Constant.origin, value: "\(value.lat),\(value.lng)")
    }
    
    func withPerformerId(_ value: Int) -> Self {
        return withParameter(key: Constant.performerId, value: value)
    }
    
    func withRating(_ value: Int) -> Self {
        return withParameter(key: Constant.rating, value: value)
    }
}
