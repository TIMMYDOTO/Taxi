//
//  OrderManager.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 30.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit

class OrderManager: NetworkManager {

    enum Endpoint {
        static let createOrder = "client/createOrder"
        static let getActiveOrder = "client/getActiveOrder"
        static let cancelOrder = "client/cancelOrder"
        static let getLastOrders = "client/getLastOrders"
        static let getOrderInfo = "client/getOrderInfo"
        static let getNearbyPerformers = "client/getNearbyPerformers"
        static let acceptWork = "client/acceptWork"
    }
    
    func createOrder(newOrder: NewOrder) throws -> Promise<Order> {
        let request = try CodableRequest.create(url: baseApiURL + Endpoint.createOrder, method: .post)
            .withObject(newOrder)
        return firstly {
                performRequest(request)
            }.map({ [weak self] (data) in
                guard let `self` = self else { throw RCError.cancel }
                guard let data = data else { throw RCError.noResponse }
                return try self.decoder.decode(Order.self, from: data)
            })
    }
    
    func getActiveOrder() -> Promise<Order?> {
        let request = OrdersRequest.create(url: baseApiURL + Endpoint.getActiveOrder, method: .get)
        return firstly {
                performRequest(request)
            }.map({ [weak self] (data) in
                guard let `self` = self else { throw RCError.cancel }
                guard let data = data else { throw RCError.noResponse }
                let request = try self.decoder.decode(ActiveOrder.self, from: data)
                User.updateOrderInfo(order: request.order)
                return request.order
            })
    }
    
    func cancelOrder(orderId: Int, reason: String) -> Promise<String?> {
        let request = OrdersRequest.create(url: baseApiURL + Endpoint.cancelOrder, method: .get)
            .withOrderId(orderId)
            .withReason(reason)
        return firstly {
            performRequestJSON(request)
        }.map({ (json) -> String? in
            guard let json = json as? JSON else { throw RCError.noResponse }
            return json["errorMsg"] as? String
        })
    }
    
    func getLastOrders(requestHandler: ((DataRequest) -> ())? = nil) -> Promise<OrdersResponse> {
        let request = OrdersRequest.create(url: baseApiURL + Endpoint.getLastOrders, method: .get)
        return firstly {
                performRequest(request, requestHandler: requestHandler)
            }.map({ [weak self] (data) -> OrdersResponse in
                guard let `self` = self else { throw RCError.cancel }
                guard let data = data else { throw RCError.noResponse }
                return try self.decoder.decode(OrdersResponse.self, from: data)
            })
    }
    
    func getOrderInfo(orderId: Int) -> Promise<Order> {
        let request = OrdersRequest.create(url: baseApiURL + Endpoint.getOrderInfo, method: .get)
            .withOrderId(orderId)
        return firstly {
                performRequest(request)
            }.map({ [weak self] (data) in
                guard let `self` = self else { throw RCError.cancel }
                guard let data = data else { throw RCError.noResponse }
                let response = try self.decoder.decode(MyOrderResponse.self, from: data)
                return response.info
            })
    }
    
    func getNearbyPerformers(origin: RouteCoordinate) -> Promise<[NearbyPerformer]> {
        let request = OrdersRequest.create(url: baseApiURL + Endpoint.getNearbyPerformers, method: .get)
            .withOrigin(origin)
        return firstly {
                performRequest(request)
            }.map({ [weak self] (data) in
                guard let `self` = self else { throw RCError.cancel }
                guard let data = data else { throw RCError.noResponse }
                let response = try self.decoder.decode(NearbyPerformersResponse.self, from: data)
                return response.performers ?? []
            })
    }
    
    func acceptWork(performerId: Int, orderId: Int, rating: Int?) -> Promise<Bool> {
        let request = OrdersRequest.create(url: baseApiURL + Endpoint.acceptWork, method: .get)
            .withOrderId(orderId)
            .withPerformerId(performerId)
        if let rating = rating, rating > 0 {
            let _ = request.withRating(rating)
        }
        return firstly {
                performRequestJSON(request)
            }.map({ (json) in
                guard let json = json as? JSON else { throw RCError.noResponse }
                if (json["status"] as? String) == "success" {
                    return (json["orderCompleted"] as? Bool) ?? false
                } else {
                    throw RCError.noResponse
                }
        })
    }
    
}
