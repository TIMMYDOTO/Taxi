//
//  ChatFromCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 06.04.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class ChatFromCell: UITableViewCell, ChatMessageCell {

    @IBOutlet weak var bgView: UIView! {
        willSet {
            newValue.backgroundColor = UIColor.blue_main
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 16.0
        }
    }
    
    @IBOutlet weak var messageLabel: UILabel! {
        willSet {
            newValue.textColor = .white
            newValue.font = UIFont.cuprumFont(ofSize: 18.0)
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var timeLabel: UILabel! {
        willSet {
            newValue.textColor = UIColor.text_grey
            newValue.font = UIFont.cuprumFont(ofSize: 12.0)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func setup(message: ChatMessage) {
        messageLabel.text = message.text
        timeLabel.text = DateFormatter.timeFormatter.string(from: Date(timeIntervalSince1970: message.timestamp))
    }

}
