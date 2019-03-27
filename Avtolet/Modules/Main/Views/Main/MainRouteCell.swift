//
//  MainRouteCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 29.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class MainRouteCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 24.0
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = UIColor.blue_main.cgColor
            newValue.backgroundColor = .white
        }
    }
    @IBOutlet weak var label: UILabel! {
        willSet {
            newValue.font = UIFont.cuprumFont(ofSize: 18.0)
            newValue.textColor = .blue_main
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        bgView.alpha = highlighted ? 0.5 : 1.0
    }
    
    func setup(title: String) {
        label.text = title.uppercased()
    }
    
}
