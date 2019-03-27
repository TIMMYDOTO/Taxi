//
//  AuthInfoCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 26.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class AuthInfoCell: UITableViewCell {

    var interactHandler: ((String) -> ())?
    
    @IBOutlet weak var textView: UITextView! {
        willSet {
            newValue.delegate = self
            newValue.resetStyles()
            newValue.textColor = UIColor.placeholder_grey
            newValue.tintColor = UIColor.blue_main
            newValue.font = UIFont.cuprumFont(ofSize: 13.0)
        }
    }

    func setup(info: NSAttributedString) {
        textView.attributedText = info
    }
    
}

extension AuthInfoCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        interactHandler?(URL.absoluteString)
        return true
    }
}
