//
//  MainPromocodeCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 09.04.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MainPromocodeCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 24.0
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = UIColor.blue_main.cgColor
            newValue.backgroundColor = .white
        }
    }
    
    @IBOutlet weak var textField: UITextField! {
        willSet {
            newValue.font = UIFont.cuprumFont(ofSize: 18.0)
            newValue.textColor = .black
            newValue.attributedPlaceholder = "Введите код".attributed(attributes: [NSAttributedStringKey.foregroundColor: UIColor.border_color_main])
            newValue.tintColor = UIColor.text_grey
            newValue.delegate = self
            newValue.rx.text.subscribe(onNext: { [weak self] (text) in
                self?.textDidChangeHandler?(text)
            }).disposed(by: disposeBag)
        }
    }
    
    @IBOutlet weak var button: UIButton! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 24.0
            newValue.layer.backgroundColor = UIColor.blue_main.cgColor
            newValue.titleLabel?.font = TariffColectionCell.TariffFont
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.setTitle("Применить".uppercased(), for: .normal)
        }
    }
    
    let disposeBag = DisposeBag()
    
    var promocode: String?
    var applyPromocodeHandler: ((String) -> ())?
    var textDidChangeHandler: ((String?) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    func setup(promocode: String?, draft: String?) {
        self.promocode = (promocode?.isEmptyOrWhitespace ?? true) ? nil : promocode
        textField.text = promocode ?? draft
        (promocode?.isEmptyOrWhitespace ?? true) ? button.setTitle("Применить".uppercased(), for: .normal) : button.setTitle("Отменить".uppercased(), for: .normal)
    }
    
    @IBAction func applyPromocode() {
        textField.resignFirstResponder()
        self.applyPromocodeHandler?(promocode != nil ? "" : textField.text?.trim() ?? "")
    }
    
}

extension MainPromocodeCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return promocode == nil
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        applyPromocode()
        return true
    }
}
