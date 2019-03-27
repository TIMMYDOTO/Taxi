//
//  AuthAuthPresentationModel.swift
//  avtolet
//
//  Created by Igor Tyukavkin on 26/03/2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class AuthPresentationModel: PresentationModel {

    let manager = AuthManager()
    var codeObtained: (() -> ())?
    var obtainCodeFailed: (() -> ())?
    var codeConfirmed: ((CodeConfirmation) -> ())?
    var showMessageHandler: ((String) -> ())?

    func requestSMSCode(phone: String) {
        manager.requestSmsCode(phone: phone).done { [weak self] (result) in
            self?.codeObtained?()
        }.catch { [weak self] (error) in
            self?.obtainCodeFailed?()
            if let error = error as? RCError {
                self?.errorHandler?(error)
            } else {
                self?.errorHandler?(RCError.connectionError)
            }
        }
    }
    
    func confirmCode(phone: String, code: String) {
        loadingHandler?(true)
        manager.confirmCode(phone: phone, code: code).done { [weak self] (codeConfirmation) in
            self?.loadingHandler?(false)
            guard let `self` = self else { return }
            self.confirm(codeConfirmation: codeConfirmation, phone: phone)
        }.catch { [weak self] (error) in
            self?.loadingHandler?(false)
            if let error = error as? RCError {
                self?.errorHandler?(error)
            } else{
                let error = error as NSError
                if error.statusCode == 429 {
                    self?.showMessageHandler?("Превышен лимит запросов кода на указанный номер телефона. Повторите попытку позже.")
                } else if error.statusCode == 401 {
                    self?.showMessageHandler?("Код из СМС введён неверно.")
                } else {
                    self?.errorHandler?(RCError.connectionError)
                }
            }
        }
    }
    
    fileprivate func confirm(codeConfirmation: CodeConfirmation, phone: String) {
        let user = User.current
        user.accessToken = codeConfirmation.token
        user.phone = phone
        user.needRegister = codeConfirmation.needRegister
        user.synchronize()
        codeConfirmed?(codeConfirmation)
    }
    
}
