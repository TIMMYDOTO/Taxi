//
//  SearchAddressCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 29.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class SearchAddressCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 20.0
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = UIColor.border_color_main.cgColor
        }
    }
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var titleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.cuprumFont(ofSize: 20.0)
            newValue.textColor = .black
        }
    }
    
    @IBOutlet weak var infoLabel: UILabel! {
        willSet {
            newValue.font = UIFont.cuprumFont(ofSize: 18.0)
            newValue.textColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        bgView.alpha = highlighted ? 0.5 : 1.0
    }
    
    func setup(address: SearchAddress) {
        titleLabel.text = address.address
        infoLabel.text = address.city
        infoLabel.isHidden = address.city == nil
    }

}
