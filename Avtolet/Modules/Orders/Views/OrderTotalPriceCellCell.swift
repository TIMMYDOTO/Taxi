//
//  OrderTotalPriceCellCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 02.04.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class OrderTotalPriceCellCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 20.0
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = UIColor.border_color_main.cgColor
        }
    }
    
    @IBOutlet weak var priceLabel: UILabel! {
        willSet {
            newValue.font = UIFont.cuprumFont(ofSize: 46.0)
            newValue.textColor = UIColor.text_black
        }
    }
    
    @IBOutlet weak var infoLabel: UILabel! {
        willSet {
            newValue.font = UIFont.cuprumFont(ofSize: 17.0)
            newValue.textColor = UIColor.text_grey
            newValue.text = "Итоговая стоимость"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func setup(totalPrice: Double) {
        priceLabel.text = PriceFormatter.stringFromPrice(price: ceil(totalPrice))
    }

}
