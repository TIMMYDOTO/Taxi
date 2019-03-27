//
//  File.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 12/29/18.
//  Copyright © 2018 Artyom Schiopu. All rights reserved.
//

import Foundation

struct OrderInfoResponse: Decodable {
    let status: String
    let order_info: OrderInfo
}

struct OrderInfo: Decodable{
    let id: Int
    let client_id: Int
    let created_at: String
    let updated_at: String
    let transportation_tariff_id: Int
    let service_ids: String
    let promo_code_id: Int?
    let payment_type: Int
    let order_source: Int
    let card_id: Int?
    let favorite_performer_id: Int?
    let counting_type: Int
    let status: Int
    let origin_text: String
    let destination_text: String
    let full_name: String
    let phone_number: String
    let transportation_tariff_name: String
    let trip_time: String
    let trip_distance: String
    let transmit_cost: Int
    let cost_in_zone: Int
    let outdoor_zone_cost: Int
    let sub_zones_cost: Int
    let perform_cost: Int
    let services_cost: Int
    let min_cost: Int
    let discount_by_promo: Int
    let result_trip_cost: Int
    let trip_cost: Int
    let trip_cost_with_discount: Int
    let route_polyline: [Polyline]
    let _debug_sub_zones_info: String
    let _debug: String
    let origin_latitude: String
    let origin_longitude: String
    let destination_latitude: String
    let destination_longitude: String
    let services: [Aservice]
    
}

struct Aservice: Decodable {
    let name: String
}
