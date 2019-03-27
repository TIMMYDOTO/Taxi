//
//  AuthTextFieldCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 26.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import SwiftPhoneNumberFormatter

class AuthTextFieldCell: UITableViewCell {

    @IBOutlet weak var cornerView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 20.0
            newValue.layer.masksToBounds = true
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = UIColor.placeholder_grey.cgColor
        }
    }
    
    @IBOutlet weak var textField: PhoneFormattedTextField! {
        willSet {
            newValue.font = UIFont.cuprumFont(ofSize: 18.0)
            newValue.textColor = UIColor.text_grey
            newValue.tintColor = UIColor.text_grey
            newValue.config.defaultConfiguration = PhoneFormat(defaultPhoneFormat: "+7 (###) ###-##-##")
            newValue.delegate = self
        }
        didSet {
            textField.textDidChangeBlock = { [weak self] _ in
                guard let `self` = self else { return }
                self.textFieldDidChange?(self.textField) 
            }
        }
    }
    
    var textFieldDidChange: ((PhoneFormattedTextField) -> ())?
    
    func setup(placeholder: String, isValidationMode: Bool) {
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedStringKey.foregroundColor: UIColor.placeholder_grey])
        cornerView.layer.borderColor = isValidationMode ? UIColor.red.cgColor : UIColor.placeholder_grey.cgColor
    }

}

extension AuthTextFieldCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
