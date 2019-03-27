//
//  OrdersOrdersPresentationModel.swift
//  avtolet
//
//  Created by Igor Tyukavkin on 30/03/2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class OrdersPresentationModel: PresentationModel {

    let manager = OrderManager()
    var updateHandler: ((Order) -> ())?
    var workAccepted: ((Bool) -> ())?
    var showHUDHandler: ((Bool) -> ())?
    var showErrorHandler: (() -> ())?
    
    func loadOrder(id: Int) {
        loadingHandler?(true)
        manager.getOrderInfo(orderId: id).done { [weak self] (order) in
            self?.loadingHandler?(false)
            self?.updateHandler?(order)
        }.catch { [weak self] (_) in
            self?.loadingHandler?(false)
            self?.errorHandler?(RCError.connectionError)
        }
    }

    
    func acceptWork(performerId: Int, orderId: Int, rating: Int?) {
        showHUDHandler?(true)
        manager.acceptWork(performerId: performerId,
                           orderId: orderId,
                           rating: rating).done { [weak self] (completed) in
            self?.showHUDHandler?(false)
            self?.workAccepted?(completed)
        }.catch { [weak self] (_) in
            self?.showHUDHandler?(false)
            self?.showErrorHandler?()
        }
    }
    
}
