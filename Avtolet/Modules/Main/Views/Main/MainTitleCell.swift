//
//  MainTitleCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 28.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class MainTitleCell: UITableViewCell {

    @IBOutlet weak var label: UILabel! {
        willSet {
            newValue.font = UIFont.cuprumFont(ofSize: 16.0)
            newValue.textColor = .black
        }
    }
    
    @IBOutlet weak var bgView: UIView! {
        willSet {
            newValue.backgroundColor = UIColor.white
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 18.0
            newValue.layer.borderColor = UIColor.border_color_main.cgColor
            newValue.layer.borderWidth = 1.0
        }
    }
    
    @IBOutlet weak var lineView: UIView! {
        willSet {
            newValue.backgroundColor = UIColor.border_color_main
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func setup(title: String) {
        label.text = title
    }
    
}
