//
//  AuthTitleCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 26.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class AuthTitleCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.cuprumFont(ofSize: 13.0)
            newValue.textColor = UIColor.text_grey
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func setup(title: String) {
        titleLabel.text = title
    }

}
