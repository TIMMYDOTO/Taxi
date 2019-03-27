//
//  Fare.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 30.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import Foundation

struct FareResponse: Codable {
    let fare: [Fare]
}

struct Fare: Codable {
//    let truckFare: TruckFare
//    let frameFare: FareInfo
//    let priceIntercity: FareInfo
//    let loaderFare: PriceInfo
//    let serviceFare: PriceInfo
    let totalPrice: Double
    
//    enum CodingKeys: String, CodingKey {
//        case priceIntercity = "price_intercity"
//        case truckFare, frameFare
//    }
}

//struct TruckFare: Codable {
//    let highDemandTimePrice: Double
//    let minPrice: Double
//    let overTimePrice: Double
//    let highDemandAreaPrice: Double
//    let intercityPrice: Double
//    let totalPrice: Double
//}

//struct FareInfo: Codable {
//    let min: MinCost
//    let basic: BasicCost
//}
//
//struct MinCost: Codable {
//    let cost: Double
//    let time: Int
//    let type: Int
//}
//
//struct BasicCost: Codable {
//
//}
//
//struct PriceInfo: Codable {
//    let totalPrice: Double
//}
