//
//  RegistrationBigTitleCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 28.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class RegistrationBigTitleCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.cuprumFont(ofSize: 21.0)
            newValue.textColor = UIColor.text_grey
        }
    }
    
    @IBOutlet weak var separator: UIView! {
        willSet {
            newValue.backgroundColor = UIColor.placeholder_grey
        }
    }
    
    func setup(title: String) {
        titleLabel.text = title
    }

}
