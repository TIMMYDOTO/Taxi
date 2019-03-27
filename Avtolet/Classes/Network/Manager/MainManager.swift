//
//  MainManager.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 28.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit

class MainManager: NetworkManager {
    
    enum Endpoint {
        static let getTariffs = "client/getCars"
        static let getRouteData = "client/getRouteData"
        static let getRouteFare = "client/getRouteFare"
        static let setFirebaseToken = "client/setFirebaseToken"
        static let checkPromocode = "client/checkPromoCode"
    }
    
    func getCars() -> Promise<[Car]> {
        let request = MainRequest.create(url: baseApiURL + Endpoint.getTariffs, method: .get)
        return firstly {
                performRequest(request)
            }.map { [weak self] (data) -> [Car] in
                guard let `self` = self else { throw RCError.cancel }
                guard let data = data else { throw RCError.noResponse }
                let carResponse = try self.decoder.decode(CarsResponse.self, from: data)
                return carResponse.cars
            }
    }
    
    func getRouteInfo(origin: String, destination: String, requestHandler: ((DataRequest) -> ())? = nil) -> Promise<RouteResponse> {
        let request = MainRequest.create(url: baseApiURL + Endpoint.getRouteData, method: .get)
            .withOrigin(origin)
            .withDestination(destination)
        return firstly {
                performRequest(request, requestHandler: requestHandler)
            }.map { [weak self] (data) -> RouteResponse in
                guard let `self` = self else { throw RCError.cancel }
                guard let data = data else { throw RCError.noResponse }
                return try self.decoder.decode(RouteResponse.self, from: data)
            }
    }
    
    func checkPromocode(promocode: String) -> Promise<(Bool, String?, Int?)> {
        let request = MainRequest.create(url: baseApiURL + Endpoint.checkPromocode, method: .get)
            .withPromocode(promocode)
        return firstly {
                performRequestJSON(request)
            }.map({ (json) -> (Bool, String?, Int?) in
                guard let json = json as? JSON else { throw RCError.noResponse }
                return ((json["status"] as? String) == "success", (json["message"] as? String), (json["id"] as? Int))
            })
    }
    
    func getRouteFare(truckCategoryId: Int,
                      truckFrameId: Int,
                      durationRoute: Int,
                      distanceRoute: Int,
                      overviewPolyline: String,
                      countLoaders: Int,
                      servicesId: [Int],
                      promoCodeId: Int?, requestHandler: ((DataRequest) -> ())? = nil) -> Promise<Fare> {
        let request = MainRequest.create(url: baseApiURL + Endpoint.getRouteFare, method: .get)
            .withTruckCategoryId(truckCategoryId)
            .withTruckFrameId(truckFrameId)
            .withDurationRoute(durationRoute)
            .withDistanceRoute(distanceRoute)
            .withOverviewPolyline(overviewPolyline)
            .withCountLoaders(countLoaders)
            .withServicesId(servicesId)
        if let promoCodeId = promoCodeId {
            let _ = request.withPromoCodeId(promoCodeId)
        }
        return firstly {
                performRequest(request, requestHandler: requestHandler)
            }.map { [weak self] (data) -> Fare in
                guard let `self` = self else { throw RCError.cancel }
                guard let data = data else { throw RCError.noResponse }
                let response = try self.decoder.decode(FareResponse.self, from: data)
                guard let fare = response.fare.first else { throw RCError.noResponse }
                return fare
        }
    }
    
    func setFirebaseToken(token: String) -> Promise<Bool> {
        let request = MainRequest.create(url: baseApiURL + Endpoint.setFirebaseToken, method: .get)
            .withFirebaseToken(token)
        return firstly {
            performRequestJSON(request)
        }.map({ (json) -> Bool in
            guard let json = json as? JSON else { throw RCError.noResponse }
            return (json["status"] as? String) == "success"
        })
    }
}
