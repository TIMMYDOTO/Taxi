////
////  TariffPresentationModel.swift
////  Avtolet
////
////  Created by Igor Tyukavkin on 27.03.2018.
////  Copyright © 2018 Igor Tyukavkin. All rights reserved.
////
//
//import UIKit
//
//class TariffPresentationModel: PresentationModel {
//    
//    let manager = TariffsManager()
//    
//    var updateHandler: (([Tariff]) -> ())?
//    
//    func loadData() {
//        loadingHandler?(true)
//        manager.getTariffs().done { [weak self] (tariffs) in
//            self?.loadingHandler?(false)
//            self?.updateHandler?(tariffs)
//        }.catch { [weak self] (error) in
//            self?.loadingHandler?(false)
//            if let error = error as? RCError {
//                self?.errorHandler?(error)
//            } else {
//                self?.errorHandler?(RCError.connectionError)
//            }
//        }
//    }
//    
//}
