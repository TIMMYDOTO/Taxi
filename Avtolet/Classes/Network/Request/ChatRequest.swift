//
//  ChatRequest.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 03.04.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class ChatRequest: CommonRequest {
    enum Constant {
        static let performerId = "performerId"
        static let text = "text"
    }
    
    func withPerformerId(_ value: Int) -> Self {
        return withParameter(key: Constant.performerId, value: value)
    }
    
    func withText(_ value: String) -> Self {
        return withParameter(key: Constant.text, value: value)
    }
    
}
