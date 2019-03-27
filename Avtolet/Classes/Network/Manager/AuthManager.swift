//
//  AuthManager.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 27.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit

class AuthManager: NetworkManager {
    enum Endpoint {
        static let requestSMSCodeClient = "requestSMSCodeClient"
        static let authenticateClients = "authenticateClients"
        static let registration = "client/registration"
        static let getClientInfo = "client/getInfo"
    }
    
    func requestSmsCode(phone: String) -> Promise<Bool> {
        let request = AuthRequest.create(url: baseApiURL + Endpoint.requestSMSCodeClient, method: .get)
            .withPhoneNumber(phone)
        return firstly {
            performRequestJSON(request)
        }.map({ (json) -> Bool in
            guard let json = json as? JSON else { throw RCError.noResponse }
            return (json["status"] as? String) == "success"
        })
    }
    
    func confirmCode(phone: String, code: String) -> Promise<CodeConfirmation> {
        let request = AuthRequest.create(url: baseApiURL + Endpoint.authenticateClients, method: .post)
            .withPhoneNumber(phone)
            .withCode(code)
        request.encoding = JSONEncoding.default
        return firstly {
                performRequest(request)
            }.map({ [weak self] (data) -> CodeConfirmation in
                guard let `self` = self else { throw RCError.cancel }
                guard let data = data else { throw RCError.noResponse }
                return try self.decoder.decode(CodeConfirmation.self, from: data)
            })
    }
    
    func registerClient(name: String, email: String, city: String) -> Promise<Bool> {
        let request = AuthRequest.create(url: baseApiURL + Endpoint.registration, method: .post)
            .withName(name)
            .withEmail(email)
            .withCity(city)
        request.encoding = JSONEncoding.default
        return firstly {
                performRequestJSON(request)
            }.map({ (json) -> Bool in
                guard let json = json as? JSON else { throw RCError.noResponse }
                return (json["status"] as? String) == "success"
            })
    }
    
    func getClientInfo() -> Promise<ClientInfo> {
        let request = AuthRequest.create(url: baseApiURL + Endpoint.getClientInfo, method: .get)
        return firstly {
                performRequest(request)
            }.map({ [weak self] (data) -> ClientInfo in
                guard let `self` = self else { throw RCError.cancel }
                guard let data = data else { throw RCError.noResponse }
                let clientInfo = try self.decoder.decode(ClientInfo.self, from: data)
                User.update(clientInfo: clientInfo)
                return clientInfo
            })
    }
}
