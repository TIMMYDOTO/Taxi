//
//  AuthButtonCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 26.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class AuthButtonCell: UITableViewCell {

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
    
    func setup(title: String) {
        button.setTitle(title.uppercased(), for: .normal)
    }
    
    func setupWithTimer(canRepeat: Bool) {
        button.isEnabled = canRepeat
        if canRepeat {
            button.layer.cornerRadius = 25.0
            button.layer.backgroundColor = UIColor.blue_main.cgColor
            button.layer.borderColor = UIColor.clear.cgColor
            button.addShadow()
        } else {
            button.layer.cornerRadius = 20.0
            button.layer.backgroundColor = UIColor.white.cgColor
            button.layer.borderColor = UIColor.placeholder_grey.cgColor
            button.removeShadow()
        }
    }
    
    @IBAction func buttonTapped() {
        buttonTappedHandler?()
    }
    
}
