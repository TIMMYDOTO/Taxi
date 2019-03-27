//
//  MainRequest.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 28.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class MainRequest: CommonRequest {

    enum Constant {
        static let origin = "origin"
        static let destination = "destination"
        static let truckCategoryId = "truckCategoryId"
        static let truckFrameId = "truckFrameId"
        static let durationRoute = "durationRoute"
        static let distanceRoute = "distanceRoute"
        static let overviewPolyline = "overview_polyline"
        static let countLoaders = "countLoaders"
        static let servicesId = "servicesId"
        static let firebaseToken = "firebase_token"
        static let code = "code"
        static let promoCodeId = "promoCodeId"
    }
    
    func withOrigin(_ value: String) -> Self {
        return withParameter(key: Constant.origin, value: value)
    }
    
    func withDestination(_ value: String) -> Self {
        return withParameter(key: Constant.destination, value: value)
    }
    
    func withTruckCategoryId(_ value: Int) -> Self {
        return withParameter(key: Constant.truckCategoryId, value: value)
    }
    
    func withTruckFrameId(_ value: Int) -> Self {
        return withParameter(key: Constant.truckFrameId, value: value)
    }
    
    func withDurationRoute(_ value: Int) -> Self {
        return withParameter(key: Constant.durationRoute, value: value)
    }
    
    func withDistanceRoute(_ value: Int) -> Self {
        return withParameter(key: Constant.distanceRoute, value: value)
    }
    
    func withOverviewPolyline(_ value: String) -> Self {
        return withParameter(key: Constant.overviewPolyline, value: value)
    }
    
    func withCountLoaders(_ value: Int) -> Self {
        return withParameter(key: Constant.countLoaders, value: value)
    }
    
    func withServicesId(_ value: [Int]) -> Self {
        guard value.count > 0 else { return self }
        return withParameter(key: Constant.servicesId, value: value.map({ "\($0)" }).joined(separator: ","))
    }
    
    func withFirebaseToken(_ value: String) -> Self {
        return withParameter(key: Constant.firebaseToken, value: value)
    }
    
    func withPromocode(_ value: String) -> Self {
        return withParameter(key: Constant.code, value: value)
    }
    
    func withPromoCodeId(_ value: Int) -> Self {
        return withParameter(key: Constant.promoCodeId, value: value)
    }
}
