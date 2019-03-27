//
//  RegistrationRegistrationPresentationModel.swift
//  avtolet
//
//  Created by Igor Tyukavkin on 28/03/2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class RegistrationPresentationModel: PresentationModel {

    let manager = AuthManager()
    
    var registrationCompleted: (() -> ())?
    
    func registerClient(name: String, email: String, city: String) {
        loadingHandler?(true)
        manager.registerClient(name: name, email: email, city: city).done { [weak self] (result) in
            self?.loadingHandler?(false)
            if result {
                self?.saveUser(name: name, email: email, city: city)
            } else {
                self?.errorHandler?(RCError.incorrectData)
            }
        }.catch { [weak self] (error) in
            self?.loadingHandler?(false)
            if let error = error as? RCError {
                self?.errorHandler?(error)
            } else {
                self?.errorHandler?(RCError.connectionError)
            }
        }
    }
    
    func saveUser(name: String, email: String, city: String) {
        let user = User.current
        user.name = name
        user.email = email
        user.city = city
        user.needRegister = false
        user.synchronize()
        registrationCompleted?()
    }
    
}
