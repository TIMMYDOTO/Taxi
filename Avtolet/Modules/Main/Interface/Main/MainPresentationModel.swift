//
//  MainMainPresentationModel.swift
//  avtolet
//
//  Created by Igor Tyukavkin on 26/03/2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import Alamofire

class MainPresentationModel: PresentationModel {

    let manager = MainManager()
    let orderManager = OrderManager()
    
    var carsObtained: (([Car]) -> ())?
    var carsLoadingHandler: ((Bool) -> ())?
    var carsErrorHandler: ((RCError) -> ())?
    var routeObtained: ((Route) -> ())?
    var fareObtained: ((Fare) -> ())?
    var showAlertMessage: ((String) -> ())?
    var orderCreated: (() -> ())?
    var promocodeApplyedHandler: ((String, Int) -> ())?
    
    weak var currentRouteRequest: DataRequest?
    weak var currentFareRequest: DataRequest?
    
    var error: String?
    
    func getCars() {
        carsLoadingHandler?(true)
        manager.getCars().done { [weak self] (cars) in
            self?.carsLoadingHandler?(false)
            self?.carsObtained?(cars)
        }.catch { [weak self] (_) in
            self?.carsLoadingHandler?(false)
            self?.carsErrorHandler?(RCError.connectionError)
        }
    }
    
    func getRoute(origin: String, destination: String) {
        guard ConnectionStatus != .notReachable else {
            loadingHandler?(false)
            showAlertMessage?("Проверьте соединение с интернетом и попробуйте снова")
            return
        }
        let kSameDirectionsError = "Пункт отправления и пункт назначения совпадают"
        guard origin != destination else {
            loadingHandler?(false)
            showAlertMessage?(kSameDirectionsError)
            return
        }
        error = nil
        self.currentRouteRequest?.cancel()
        self.currentRouteRequest = nil
        manager.getRouteInfo(origin: origin, destination: destination) { [unowned self] request in
            self.currentRouteRequest = request
        }.done { [weak self] (response) in
            self?.loadingHandler?(false)
            if let route = response.route?.first {
                self?.routeObtained?(route)
            } else if var error = response.error {
                error = error == "same_directions" ? kSameDirectionsError : kDefaultErrorMessage
                self?.error = error
                self?.showAlertMessage?(error)
            } else {
                self?.errorHandler?(RCError.noResponse)
            }
        }.catch { [weak self] (_) in
            self?.loadingHandler?(false)
            self?.errorHandler?(RCError.connectionError)
        }
    }
    
    func getFare(truckCategoryId: Int,
                 truckFrameId: Int,
                 durationRoute: Int,
                 distanceRoute: Int,
                 overviewPolyline: String,
                 countLoaders: Int,
                 servicesId: [Int],
                 promoCodeId: Int?) {
        self.currentFareRequest?.cancel()
        self.currentFareRequest = nil
        manager.getRouteFare(truckCategoryId: truckCategoryId, truckFrameId: truckFrameId, durationRoute: durationRoute, distanceRoute: distanceRoute, overviewPolyline: overviewPolyline, countLoaders: countLoaders, servicesId: servicesId, promoCodeId: promoCodeId) { [unowned self] request in
            self.currentFareRequest = request
        }.done { [weak self] (fare) in
            self?.fareObtained?(fare)
        }.catch { (_) in}
    }

    func createOrder(newOrder: NewOrder) throws {
        guard ConnectionStatus != .notReachable else {
            showAlertMessage?("Проверьте соединение с интернетом и попробуйте снова")
            return
        }
        loadingHandler?(true)
        try orderManager.createOrder(newOrder: newOrder).done { [weak self] (order) in
            self?.loadingHandler?(false)
            if let error = order.errorMsg {
                self?.showAlertMessage?(error)
            } else {
                User.updateOrderInfo(order: order)
                self?.orderCreated?()
            }
        }.catch({ [weak self] (_) in
            self?.loadingHandler?(false)
            self?.errorHandler?(RCError.connectionError)
        })
    }
    
    func checkPromocode(promocode: String) {
        guard ConnectionStatus != .notReachable else {
            showAlertMessage?("Проверьте соединение с интернетом и попробуйте снова")
            return
        }
        loadingHandler?(true)
        manager.checkPromocode(promocode: promocode).done { [weak self] (result, message, id) in
            self?.loadingHandler?(false)
            if let id = id, result == true {
                self?.showAlertMessage?(message ?? "Промокод успешно применён")
                self?.promocodeApplyedHandler?(promocode, id)
            } else {
                self?.showAlertMessage?(message ?? kDefaultErrorMessage)
            }
        }.catch { [weak self] (_) in
            self?.loadingHandler?(false)
            self?.errorHandler?(RCError.connectionError)
        }
    }
}
