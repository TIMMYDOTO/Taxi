//
//  Card.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 11/3/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit


struct Card: Decodable {
    let id: Int
    let card_id: String
    let client_id: Int
    let pan: String
    let exp_date: String
    let created_at: String
  
    
    
}
