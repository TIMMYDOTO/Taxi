//
//  MainDescriptionCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 29.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class MainDescriptionCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 24.0
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = UIColor.blue_main.cgColor
            newValue.backgroundColor = .white
        }
    }
    
    @IBOutlet weak var textView: UITextView! {
        willSet {
            newValue.resetStyles()
            newValue.font = UIFont.cuprumFont(ofSize: 18.0)
            newValue.tintColor = UIColor.text_grey
            newValue.delegate = self
        }
    }
    
    let placeholderColor = UIColor.border_color_main
    fileprivate var placeholder: String = ""
    var valueChanged: ((String) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func setup(placeholder: String) {
        self.placeholder = placeholder
    }
    
    func update(value: String?) {
        textView.text = value ?? ""
        checkPlaceholder()
    }
    
    func checkPlaceholder() {
        if textView.text.trim().isEmpty {
            textView.text = placeholder
            textView.textColor = placeholderColor
        } else {
            textView.textColor = .black
        }
    }
    
}

extension MainDescriptionCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        checkPlaceholder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        valueChanged?(textView.text.trim())
    }
}
