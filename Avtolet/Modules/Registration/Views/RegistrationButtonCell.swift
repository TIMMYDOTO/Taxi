//
//  RegistrationButtonCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 28.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class RegistrationButtonCell: UITableViewCell {

    @IBOutlet weak var button: UIButton! {
        willSet {
            newValue.titleLabel?.font = UIFont.cuprumFont(ofSize: 20.0)
            newValue.layer.backgroundColor = UIColor.blue_main.cgColor
            newValue.setTitleColor(.white, for: .normal)
            newValue.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)
            newValue.setTitleColor(.text_grey, for: .disabled)
            newValue.layer.cornerRadius = 25.0
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = UIColor.clear.cgColor
            newValue.addShadow()
        }
    }
    
    var buttonTappedHandler: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func setup(title: String) {
        button.setTitle(title.uppercased(), for: .normal)
    }
    
    @IBAction func buttonTapped() {
        buttonTappedHandler?()
    }

}
