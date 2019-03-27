//
//  ConfirmCodeAnotherNumberCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 27.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class ConfirmCodeAnotherNumberCell: UITableViewCell {

    @IBOutlet weak var button: UIButton! {
        willSet {
            newValue.titleLabel?.font = UIFont.cuprumFont(ofSize: 15.0)
            newValue.setTitleColor(UIColor.blue_main, for: .normal)
        }
    }
    
    var buttonHandler: (() -> ())?

    @IBAction func buttonTapped() {
        buttonHandler?()
    }
    
    func setup(title: String) {
        button.setTitle(title.uppercased(), for: .normal)
    }
    
}
