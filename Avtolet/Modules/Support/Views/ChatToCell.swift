//
//  ChatToCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 06.04.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class ChatToCell: UITableViewCell, ChatMessageCell {

    @IBOutlet weak var bgView: UIView! {
        willSet {
            newValue.backgroundColor = UIColor.white
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 16.0
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = UIColor.blue_main.cgColor
        }
    }
    
    @IBOutlet weak var messageLabel: UILabel! {
        willSet {
            newValue.textColor = .blue_main
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
