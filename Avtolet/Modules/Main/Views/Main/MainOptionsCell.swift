//
//  MainOptionsCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 29.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class MainOptionsCell: UITableViewCell {
    
    @IBOutlet var optionButtons: [UIButton]! {
        willSet {
            newValue.forEach({
                $0.layer.masksToBounds = true
                $0.layer.cornerRadius = TariffColectionCell.defaultHeight / 2.0
                $0.layer.borderWidth = 1.0
                $0.layer.borderColor = UIColor.blue_main.cgColor
                $0.setTitleColor(UIColor.blue_main, for: .normal)
                $0.setTitleColor(UIColor.white, for: .selected)
                $0.setTitleColor(UIColor.white, for: .highlighted)
                $0.setBackgroundColor(UIColor.white, forState: .normal)
                $0.setBackgroundColor(UIColor.blue_main, forState: .selected)
                $0.setBackgroundColor(UIColor.blue_main, forState: .highlighted)
                $0.titleLabel?.font = TariffColectionCell.TariffFont
            })
        }
    }

    var optionSelected: ((Int) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func setup(options: [(String, Int)], selectedOptions: [Int]) {
        options.forEach({ [unowned self] option in
            self.optionButtons.filter({ $0.tag == option.1 }).first?.setTitle(option.0.uppercased(), for: .normal)
            self.optionButtons.filter({ $0.tag == option.1 }).first?.isSelected = selectedOptions.contains(option.1)
        })
    }
    
    @IBAction func buttonTapped(button: UIButton) {
        button.isSelected = !button.isSelected
        optionSelected?(button.tag)
    }
    
}
