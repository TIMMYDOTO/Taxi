//
//  ChatManager.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 03.04.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import PromiseKit
import Alamofire

class ChatManager: NetworkManager {
    enum Endpoint {
        static let sendMessage = "client/sendMessage"
    }
    
    func sendMessage(message: String, performerId: Int) -> Promise<Bool> {
        let request = ChatRequest.create(url: baseApiURL + Endpoint.sendMessage, method: .get)
            .withPerformerId(performerId)
            .withText(message)
        return firstly {
                performRequestJSON(request)
            }.map({ (json) -> Bool in
                guard let json = json as? JSON else { throw RCError.noResponse }
                return (json["status"] as? String) == "success"
            })
    }
    
    func getChatReport(identifier: String) {
        let url = URL(string: host + getInfoReportPath + "?" + AvtoletService.shared.getToken() + "&report_id=" + identifier)
        Alamofire.request(url!)
            .responseJSON { (response:DataResponse<Any>) in
                switch(response.result) {
                case .success(_):
                    print("responce", response.result.value!)
                    break
                    
                case .failure(_):
                    
                    break
                }
        }
    }
    
    func sendChatMessage(message: String) {
        
    }
    
}
struct ChatReport {
    let report_id: Int
    let checked: Bool
    let topic: String
    let date: String
    let text: String
    let answer: String
}
