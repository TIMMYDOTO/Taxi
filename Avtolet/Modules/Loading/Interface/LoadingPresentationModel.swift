//
//  LoadingLoadingPresentationModel.swift
//  avtolet
//
//  Created by Igor Tyukavkin on 28/03/2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class LoadingPresentationModel: PresentationModel {

    let manager = AuthManager()
    let orderManager = OrderManager()
    var clientInfoLoaded = false
    
    func getClientInfo() {
        loadingHandler?(true)
        manager.getClientInfo().done { [weak self] (clientInfo) in
            if clientInfo.status == -1 {
                print("blocked user")
            } else if clientInfo.needRegister {
                self?.loadingHandler?(false)
                RegistrationRouter(presenter: nil).presentRegistration()
            } else if clientInfo.hasActiveOrder {
                self?.getActiveOrder()
            } else {
                User.updateOrderInfo(order: nil)
                self?.loadingHandler?(false)
                MainRouter(presenter: nil).showMain()
            }
        }.catch { [weak self] (_) in
            self?.loadingHandler?(false)
            self?.errorHandler?(RCError.connectionError)
        }
    }
    
    func getActiveOrder() {
        clientInfoLoaded = true
        loadingHandler?(true)
        orderManager.getActiveOrder().done { [weak self] (order) in
            User.updateOrderInfo(order: order)
            self?.loadingHandler?(false)
            MainRouter(presenter: nil).showMain()
        }.catch { [weak self] (_) in
            self?.loadingHandler?(false)
            self?.errorHandler?(RCError.connectionError)
        }
    }

    
}
