//
//  ConfirmCodeTextFieldCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 27.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class ConfirmCodeTextFieldCell: UITableViewCell {

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
    
    func setup(placeholder: String) {
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedStringKey.foregroundColor: UIColor.placeholder_grey])
    }
    
    @objc fileprivate func editingChanged(textField: UITextField) {
        textFieldDidChange?(textField.text ?? "")
    }

}

extension ConfirmCodeTextFieldCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let digits = "1234567890"
        return string.count == 0 || (string.count == 1 && digits.contains(string))
    }
}
