//
//  SearchAddress.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 29.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import Foundation

struct SearchAddress {
    let address: String
    let city: String?
    var query: String {
        return address + (city != nil ? (", " + city!.components(separatedBy: ",").first!) : "") 
    }
}
