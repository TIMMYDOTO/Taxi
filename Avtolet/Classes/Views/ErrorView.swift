//
//  ErrorView.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 27.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class ErrorView: UIView {

    @IBOutlet weak var label: UILabel! {
        willSet {
            newValue.textColor = UIColor.text_grey
            newValue.font = UIFont.cuprumFont(ofSize: 18.0)
            newValue.text = kDefaultErrorMessage
        }
    }
    
    @IBOutlet weak var button: UIButton! {
        willSet {
            newValue.setTitle("Повторить".uppercased(), for: .normal)
            newValue.titleLabel?.font = UIFont.cuprumFont(ofSize: 18.0)
            newValue.setTitleColor(UIColor.blue_main, for: .normal)
        }
    }
    
    var buttonTappedHandler: (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        nibSetup()
    }
    
    fileprivate func nibSetup() {
        guard let view = Bundle.main.loadNibNamed("ErrorView", owner: self, options: nil)?.filter({ $0 is UIView }).first as? UIView else { return }
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        view.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0.0).isActive = true
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0.0).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0.0).isActive = true
        layoutIfNeeded()
    }
    
    @IBAction func buttonTapped() {
        buttonTappedHandler?()
    }
    
}
