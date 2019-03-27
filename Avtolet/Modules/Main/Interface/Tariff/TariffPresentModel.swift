//
//  TariffPresentModel.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 12/6/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import Foundation


struct TariffPresentModel: Codable{
    
    let id: Int
    let tariff_name: String
    
    let dayCosts: Int
    let nightCosts: Int
    let holidayCosts: Int

    let dayAfter10MinutesCots: Int
    let nightAfter10MinutesCosts: Int
    let holidayAfter10MinutesCosts: Int
    
    
    let freeWaitingTime: Int
    
    init(tariff: Tarif) {
        id = tariff.id
        dayCosts = tariff.min_cost
        nightCosts = tariff.night_min_cost
        holidayCosts = tariff.weekend_min_cost
        
        dayAfter10MinutesCots = tariff.perform_cost_minute
        nightAfter10MinutesCosts = tariff.night_perform_cost_minute
        holidayAfter10MinutesCosts = tariff.weekend_perform_cost_minute
        
        tariff_name = tariff.name
        freeWaitingTime = tariff.waiting_free_minutes
    }
    
    
    
}
