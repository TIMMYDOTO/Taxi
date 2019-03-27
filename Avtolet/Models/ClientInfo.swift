//
//  ClientInfo.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 28.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

struct ClientInfo: Codable {
    let name: String
    let rating: String?
    let needRegister: Bool
    let hasActiveOrder: Bool
    let email: String?
    let city: String?
    let status: Int?
    
    enum CodingKeys: String, CodingKey {
        case needRegister = "need_registration"
        case name, rating, hasActiveOrder, email, city, status
    }
}
