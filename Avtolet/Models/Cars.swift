//
//  Cars.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 28.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import Foundation

struct CarsResponse: Codable {
    let cars: [Car]
}

struct Car: Codable {
    let id: Int
    let name: String
    let frames: [CarFrame]
}

struct CarFrame: Codable {
    let id: Int
    let name: String
}
