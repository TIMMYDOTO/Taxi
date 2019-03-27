//
//  Route.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 30.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import Foundation

struct RouteResponse: Codable {
    let route: [Route]?
    let error: String?
}

struct Route: Codable {
    let actuallyTimeCity: Int
    let originLocation: RouteCoordinate
    let destinationLocation: RouteCoordinate
    let time: Int
    let actuallyDistanceCity: Int
    let actuallyTime: Int
    let overviewPolyline: String
    let timeCity: Int
    let origin: String
    let actuallyDistance: Int
    let destination: String
    let distance: Int
    let distanceCity: Int
    let bounds: RouteBounds
    
    enum CodingKeys: String, CodingKey {
        case overviewPolyline = "overview_polyline"
        case origin, destination, originLocation, destinationLocation, bounds, time, distance, timeCity, distanceCity, actuallyDistance, actuallyDistanceCity, actuallyTime, actuallyTimeCity
    }
    
}

struct RouteCoordinate: Codable {
    let lat: Double
    let lng: Double
}

struct RouteBounds: Codable {
    let northeast: RouteCoordinate
    let southwest: RouteCoordinate
}
