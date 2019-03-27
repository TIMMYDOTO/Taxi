//
//  RegistrationTitleCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 28.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class RegistrationTitleCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.cuprumFont(ofSize: 13.0)
            newValue.textColor = UIColor.text_grey
        }
    }
    
    func setup(title: String) {
        titleLabel.text = title
    }

}
