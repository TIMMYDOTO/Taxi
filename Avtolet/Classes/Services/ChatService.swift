//
//  ChatService.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 03.04.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ChatService {
    
    enum Constant {
        static let messagesKey = "kUDMessages"
    }
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate(set) var messages: BehaviorRelay<[ChatMessage]> = BehaviorRelay(value: {
        if let data = UserDefaults.standard.object(forKey: Constant.messagesKey) as? Data,
            let messages = try? JSONDecoder().decode([ChatMessage].self, from: data) {
            return messages
        }
        return []
    }())
    static let shared = ChatService()
    
    private init() {
        synchronizable()
    }
    
    func setup() {
        PushNotificationsService.shared.notificationShowOptionsHandler
            .asObservable()
            .subscribe(onNext: { [weak self] (tuple) in
                guard let `self` = self else { return }
                guard let tuple = tuple else { return }
                guard let notification = Notification.create(userInfo: tuple.userInfo) else { return }
                guard notification.payload?.action == .newMessage else { return }
                guard let message = notification.payload?.text,
                    let userId = notification.payload?.userId else { return }
                self.handleMessage(message: message, userId: userId)
                tuple.handler?([.alert, .badge, .sound])
        }).disposed(by: disposeBag)
    }
    
    func updateMessage(message: ChatMessage) {
        var chatMessages = messages.value
        if let index = chatMessages.index(where: { $0.id == message.id }) {
            chatMessages.remove(at: index)
        }
        chatMessages.append(message)
        chatMessages = chatMessages.sorted(by: { $0.timestamp < $1.timestamp })
        messages.accept(chatMessages)
    }
    
    func reset() {
        messages.accept([])
    }
    
    fileprivate func synchronizable() {
        self.messages.asObservable().subscribe(onNext: { (messages) in
            let data = try? JSONEncoder().encode(messages)
            UserDefaults.standard.set(data, forKey: Constant.messagesKey)
            UserDefaults.standard.synchronize()
        }).disposed(by: disposeBag)
    }
    
    func handleMessage(message: String, userId: Int) {
        let cmessage = ChatMessage(id: UUID().uuidString, from: userId, to: nil, text: message, status: ChatMessageStatus.default, timestamp: Date().timeIntervalSince1970)
        updateMessage(message: cmessage)
    }
}

enum ChatMessageStatus: Int, Codable {
    case `default` = 0, pending, delivered, error
}

struct ChatMessage: Codable {
    let id: String
    let from: Int?
    let to: Int?
    let text: String
    var status: ChatMessageStatus
    let timestamp: TimeInterval
}
