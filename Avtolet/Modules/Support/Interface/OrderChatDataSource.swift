//
//  OrderChatDataSource.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 06.04.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

protocol ChatMessageCell {
    func setup(message: ChatMessage)
}

class OrderChatDataSource: DataSource {

    var messages = [ChatMessage]()
    
    override func configurator(_ indexPath: IndexPath) -> ElementConfigurator {
        let message = messages[indexPath.row]
        let reuse = message.from == nil ? "ChatToCell" : "ChatFromCell"
        return ElementConfigurator(reuseIdentifier: reuse) {
            guard let cell = $0 as? UITableViewCell else { return }
            cell.selectionStyle = .none
            if let cell = cell as? ChatMessageCell {
                cell.setup(message: message)
            }
        }
    }
    
    override func numberOfElementsInSection(_ section: Int) -> Int {
        return messages.count
    }
    
    func update(messages: [ChatMessage]) {
        self.messages = messages
        tableView?.reloadData()
    }
}
