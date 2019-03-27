////
////  TariffsManager.swift
////  Avtolet
////
////  Created by Igor Tyukavkin on 27.03.2018.
////  Copyright © 2018 Igor Tyukavkin. All rights reserved.
////
//
//import UIKit
//import Alamofire
//import PromiseKit
//
//class TariffsManager: NetworkManager {
//    
//    enum Endpoint {
//        static let getTariffs = "client/getTariffs"
//    }
//    
//    func getTariffs() -> Promise<[Tariff]> {
//        let request = CommonRequest.create(url: baseApiURL + Endpoint.getTariffs, method: .get)
//        return firstly {
//            performRequest(request)
//        }.map { [weak self] (data) -> [Tariff] in
//            guard let `self` = self else { throw RCError.cancel }
//            guard let data = data else { throw RCError.noResponse }
//            let response = try self.decoder.decode(TariffsResponse.self, from: data)
//            return response.tariffs
//        }
//    }
//    
//}
