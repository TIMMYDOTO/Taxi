//
//  User.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 26.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import Foundation
import KeychainSwift

class User: Codable {
    
    enum Constant {
        static let kUserUserDefaults = "kUserUserDefaults"
        static let kAccessToken = "accessToken"
        static let kNotFirstLaunch = "kNotFirstLaunch"
    }
    
    var name: String?
    var rating: String?
    var phone: String?
    var secondPhoneNumber: String?
    var sex: String?
    var birthDay: String?
    var id: String?
    var status: String?
    
    var email: String?
    var city: String?
    var needRegister: Bool?
    var hasActiveOrder: Bool = false
    var activeOrder: Order?
    
    static var clean: User {
        return User()
    }
    
    var accessToken: String? {
        get {
            let keychain = KeychainSwift()
            keychain.synchronizable = false
            return keychain.get(Constant.kAccessToken)
        }
        set {
            let keychain = KeychainSwift()
            if let newValue = newValue {
                keychain.set(newValue, forKey: Constant.kAccessToken)
            } else {
                KeychainSwift().delete(Constant.kAccessToken)
            }
        }
    }
    
    func synchronize() {
        User.current = self
    }
    
    static var isAuthorized: Bool {
        return UserDefaults.standard.object(forKey: "token") != nil
    }
    
    static var needRegister: Bool {
        return User.current.needRegister ?? true
    }
    
    static func update(clientInfo: ClientInfo) {
        let user = current
        user.name = clientInfo.name
        if let email = clientInfo.email {
            user.email = email
        }
        if let city = clientInfo.city {
            user.city = city
        }
        user.rating = clientInfo.rating
        user.needRegister = clientInfo.needRegister
        user.hasActiveOrder = clientInfo.hasActiveOrder
        user.synchronize()
    }
    
    static func updateOrderInfo(order: Order?) {
        let user = current
        user.activeOrder = order
        user.hasActiveOrder = order != nil
        user.synchronize()
    }
    
    func logout() {
        let user = User.clean
        user.synchronize()
        KeychainSwift().delete(Constant.kAccessToken)
    }
    
    static func checkFirstLaunch() {
        if !UserDefaults.standard.bool(forKey: Constant.kNotFirstLaunch) {
            User.current.logout()
            UserDefaults.standard.set(true, forKey: Constant.kNotFirstLaunch)
            UserDefaults.standard.synchronize()
        }
    }
    
}

extension User {
    
    static var current: User {
        set {
            let data = try! JSONEncoder().encode(newValue)
            UserDefaults.standard.setValue(data, forKey: Constant.kUserUserDefaults)
            UserDefaults.standard.synchronize()
        }
        get {
            if let userData = UserDefaults.standard.value(forKey: Constant.kUserUserDefaults) as? Data,
                let user = try? JSONDecoder().decode(User.self, from: userData) {
                return user
            }
            return User.clean
        }
    }
    
}
