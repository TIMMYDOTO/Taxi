//
//  ChatChatPresentationModel.swift
//  avtolet
//
//  Created by Igor Tyukavkin on 03/04/2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ChatPresentationModel: PresentationModel {

    let manager = ChatManager()
    let disposeBag = DisposeBag()
    var updateHandler: (([ChatMessage]) -> ())?
    var messageSended: (() -> ())?
    var performer: OrderPerformer
    
    required init(performer: OrderPerformer, errorHandler: ErrorHandler?) {
        self.performer = performer
        super.init(errorHandler: errorHandler)
    }
    
    func setup() {
        observeChat()
    }
    
    required init(errorHandler: ErrorHandler?) {
        fatalError("init(errorHandler:) has not been implemented")
    }
    
    fileprivate func observeChat() {
        ChatService.shared.messages.asObservable().subscribe(onNext: { [weak self] (messages) in
            let messages = messages.filter({ $0.from == self?.performer.performer?.id || $0.to == self?.performer.performer?.id })
            self?.updateHandler?(messages)
        }).disposed(by: disposeBag)
    }
    
    func sendMessage(message: String, performerId: Int) {
        let chatMessage = ChatMessage(id: UUID().uuidString, from: nil, to: performerId, text: message, status: .pending, timestamp: Date().timeIntervalSince1970)
        sendChatMessage(message: chatMessage)
    }
    
    func resendMessage(message: ChatMessage) {
        sendChatMessage(message: message)
    }
    
    fileprivate func sendChatMessage(message: ChatMessage) {
        guard let to = message.to else { return }
        loadingHandler?(true)
        var message = message
        message.status = .pending
//        ChatService.shared.updateMessage(message: message)
        manager.sendMessage(message: message.text, performerId: to).done { [weak self] (result) in
            self?.loadingHandler?(false)
            message.status = result == true ? .delivered : .error
            ChatService.shared.updateMessage(message: message)
            self?.messageSended?()
            }.catch { [weak self] (_) in
                self?.loadingHandler?(false)
                self?.errorHandler?(RCError.connectionError)
                message.status = .error
//                ChatService.shared.updateMessage(message: message)
        }
    }
    
}
