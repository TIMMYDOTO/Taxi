//
//  MyOrdersPresentationModel.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 31.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import Alamofire

class MyOrdersPresentationModel: PresentationModel {

    let manager = OrderManager()
    var updateHandler: ((OrdersResponse) -> ())?
    weak var currentRequest: DataRequest?
    
    func getOrders() {
        currentRequest?.cancel()
        currentRequest = nil
        loadingHandler?(true)
        manager.getLastOrders() { [unowned self] request in
            self.currentRequest = request
        }.done { [weak self] (response) in
            self?.loadingHandler?(false)
            self?.updateHandler?(response)
        }.catch { [weak self] (error) in
            let error = error as NSError
            guard error.code != -999 else { return }
            self?.loadingHandler?(false)
            self?.errorHandler?(RCError.connectionError)
            
        }
    }
    
}
