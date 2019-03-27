//
//  AuthRequest.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 27.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class AuthRequest: CommonRequest {
    enum Constant {
        static let phoneNumber = "phone_number"
        static let code = "code_confirmation"
        static let name = "name"
        static let email = "email"
        static let city = "city"
    }
    
    func withPhoneNumber(_ value: String) -> Self {
        return withParameter(key: Constant.phoneNumber, value: value)
    }
    
    func withCode(_ value: String) -> Self {
        return withParameter(key: Constant.code, value: value)
    }
    
    func withName(_ value: String) -> Self {
        return withParameter(key: Constant.name, value: value)
    }
    
    func withEmail(_ value: String) -> Self {
        return withParameter(key: Constant.email, value: value)
    }
    
    func withCity(_ value: String) -> Self {
        return withParameter(key: Constant.city, value: value)
    }
}
