//
//  AvtoletService.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 02.04.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import RxCocoa

class AvtoletService {

    let manager = MainManager()
    let backggroundWorkActions: [NotificationAction] = [.clientStatusChanged, .newMessage, .performerCompletedOrder]
    let disposeBag = DisposeBag()
    fileprivate(set) var performersToReview = [OrderPerformer]()
    var isAccountLocked = false
    
    static let shared = AvtoletService()
    private init() {
        setFirebaseToken()
    }
    
    func setup() {}
    
    func reset() {
        performersToReview = []
    }
    
    func setFirebaseToken() {
        PushNotificationsService.shared.userData.asObservable().subscribe(onNext: { [weak self] (data) in
            guard let `self` = self else { return }
            guard let token = data[kFCMTokenKey] as? String else { return }
            self.manager.setFirebaseToken(token: token).done({ (result) in
                #if DEBUG
                if result == true {
                    print("Token success")
                } else {
                    print("Token response error")
                }
                #endif
            }).catch({ (_) in
                #if DEBUG
                print("Token error")
                #endif
            })
        }).disposed(by: disposeBag)
    }
    
    func handleBackggroundWork(object: Notification) {
        guard let action = object.payload?.action else { return }
        switch action {
        case .newMessage:
            guard let text = object.payload?.text,
                let userId = object.payload?.userId else { return }
            ChatService.shared.handleMessage(message: text, userId: userId)
        case .performerCompletedOrder:
            guard let performer = object.payload?.performer, let performers = object.payload?.performers else { return }
            guard let index = performers.index(where: { performer == $0.performer }) else { return }
            performersToReview.append(performers[index])
        case .clientStatusChanged:
            guard let status = object.payload?.status else { return }
            isAccountLocked = status == -1
        default:()
        }
    }
    
    func addPerformerToReview(performer: OrderPerformer) {
        guard let performerInfo = performer.performer else { return }
        guard performersToReview.index(where: { performerInfo == $0.performer }) == nil else { return }
        performersToReview.append(performer)
    }
    
    func performerReviewed(performer: OrderPerformer) {
        guard let performer = performer.performer else { return }
        guard let index = performersToReview.index(where: { performer == $0.performer }) else { return }
        performersToReview.remove(at: index)
    }
    func setToken(token: String){
        var token = "token=" + token
        UserDefaults.standard.set(token, forKey: "token")
    }
    func getToken() -> String {
        let token = UserDefaults.standard.object(forKey: "token") as? String ?? ""
        return token
    }
    func removeToken() {
        UserDefaults.standard.removeObject(forKey: "token")
        
    }
}
