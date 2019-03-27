//
//  RegistrationTextFieldCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 28.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

enum RegistrationTextFieldCellType {
    case name, email
}

class RegistrationTextFieldCell: UITableViewCell {

    @IBOutlet weak var cornerView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 20.0
            newValue.layer.masksToBounds = true
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = UIColor.placeholder_grey.cgColor
        }
    }
    
    @IBOutlet weak var textField: UITextField! {
        willSet {
            newValue.font = UIFont.cuprumFont(ofSize: 18.0)
            newValue.textColor = UIColor.text_grey
            newValue.tintColor = UIColor.text_grey
            newValue.delegate = self
            newValue.addTarget(self, action: #selector(self.editingChanged(textField:)), for: .editingChanged)
        }
    }
    
    var textFieldDidChange: ((String) -> ())?
    var type = RegistrationTextFieldCellType.name
    
    func setup(placeholder: String, type: RegistrationTextFieldCellType) {
        self.type = type
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedStringKey.foregroundColor: UIColor.placeholder_grey])
        textField.keyboardType = type == .name ? .default : .emailAddress
        textField.autocapitalizationType = type == .name ? .words : .none
    }
    
    @objc fileprivate func editingChanged(textField: UITextField) {
        textFieldDidChange?(textField.text ?? "")
    }
    
    func highlight(_ need: Bool) {
        cornerView.layer.borderColor = need ? UIColor.red.cgColor : UIColor.placeholder_grey.cgColor
    }

}

extension RegistrationTextFieldCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if type == .name {
            guard string != " " else { return true }
            let characters = CharacterSet.alphanumerics.inverted
            let digitsSet = CharacterSet(charactersIn: "1234567890")
            if NSString(string: string).rangeOfCharacter(from: characters).location != NSNotFound || NSString(string: string).rangeOfCharacter(from: digitsSet).location != NSNotFound {
                return false
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
