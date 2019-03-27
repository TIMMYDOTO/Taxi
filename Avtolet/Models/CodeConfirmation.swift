//
//  CodeConfirmation.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 27.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import Foundation


struct CodeConfirmation: Codable {
    let token: String
    let needRegister: Bool
    
    enum CodingKeys: String, CodingKey {
        case needRegister = "need_reg"
        case token
    }
}
