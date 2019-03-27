//
//  Tariffs.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 12/6/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

struct TarrifsResponce: Codable {
        let status: String
        let tariffs:[Tarif]
    }
    
struct Tarif: Codable {
    let id: Int
    let name: String
    let available: Int
    let created_at: String
    let updated_at: String
    let min_cost: Int
    let waiting_free_minutes: Int
    let waiting_cost_minutes: Int
    let transmit_car_kilometer_cost: Int
    let transmit_car_minute_cost: Int
    let transmit_car_free_minutes: Int
    let transmit_car_free_kilometers: Int
    let perform_cost_minute: Int
    let perform_cost_kilometer: Int
    let outdoor_zone_cost_minute: Int
    let outdoor_zone_cost_kilometer: Int
    let description: String?
    let night_min_cost: Int
    let night_waiting_free_minutes: Int
    let night_waiting_cost_minutes: Int
    let night_transmit_car_kilometer_cost: Int
    let night_transmit_car_minute_cost: Int
    let night_transmit_car_free_minutes: Int
    let night_transmit_car_free_kilometers: Int
    let night_perform_cost_minute: Int
    let night_perform_cost_kilometer: Int
    let night_outdoor_zone_cost_minute: Int
    let night_outdoor_zone_cost_kilometer: Int
    let weekend_min_cost: Int
    let weekend_waiting_free_minutes: Int
    let weekend_waiting_cost_minutes: Int
    let weekend_transmit_car_kilometer_cost: Int
    let weekend_transmit_car_minute_cost: Int
    let weekend_transmit_car_free_minutes: Int
    let weekend_transmit_car_free_kilometers: Int
    let weekend_perform_cost_minute: Int
    let weekend_perform_cost_kilometer: Int
    let weekend_outdoor_zone_cost_minute: Int
    let weekend_outdoor_zone_cost_kilometer: Int
    let zone_name: String?
//    let zone_coordinates: Array<Any>?
    
    
    struct TariffCoodinate: Codable {
        let long: Double
        let lat: Double
    }
 
}

