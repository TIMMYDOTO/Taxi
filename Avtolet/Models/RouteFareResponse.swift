//
//  RouteResponse.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 12/10/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import CoreLocation
struct RouteFareResponse: Decodable {
    let status: String
    let trip_cost: Trip_cost
}
struct Trip_cost: Decodable {
    
    let start_address: String
    let end_address: String
    let trip_time: Int
    let trip_distance: String
    
    let transmit_cost: Int
    let cost_in_zone: Int
    let outdoor_zone_cost: Int
    let sub_zones_cost: Int
    
    let perform_cost: Int
    let services_cost: Int
    let min_cost: Int
    let discount_by_promo: Int
    let result_trip_cost:Int
    let trip_cost: Int
    let trip_cost_with_discount: Int
    let route_polyline: [Polyline]

//    let _debug_sub_zones_info: String//Dict
    let _debug: Debug
    
    
}

struct Polyline: Decodable {
    var lat: Double
    var long: Double

    init(from decoder: Decoder) throws {
        var longLat = try decoder.unkeyedContainer()
        lat = try longLat.decode(Double.self)
        long = try longLat.decode(Double.self)
        
//        long = Double(String(format: "%0.2f", long))!
//        lat = Double(String(format: "%0.2f", lat))!
    }
}

struct Debug: Codable {
    let trip_distance: Int
    let trip_time: Int
    let zone_distance: Double
    let zone_time: Int
    let out_zone_distance: Double
    let out_zone_time: Int
//    let transmit_distance: NSNull
//    let transmit_time: NSNull
    let tariff_price_prefix: String
}
