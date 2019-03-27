//
//  OrderDoubleInfoCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 01.04.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class OrderDoubleInfoCell: UITableViewCell {

    @IBOutlet var titles: [UILabel]! {
        willSet {
            newValue.forEach {
                $0.font = UIFont.cuprumFont(ofSize: 13.0)
                $0.textColor = UIColor.text_grey
            }
        }
    }
    
    @IBOutlet var bgViews: [UIView]! {
        willSet {
            newValue.forEach {
                $0.layer.masksToBounds = true
                $0.layer.cornerRadius = 20.0
                $0.layer.borderWidth = 1.0
                $0.layer.borderColor = UIColor.blue_main.cgColor
                $0.backgroundColor = .white
            }
        }
    }
    
    @IBOutlet var infos: [UILabel]! {
        willSet {
            newValue.forEach {
                $0.font = UIFont.cuprumFont(ofSize: 18.0)
                $0.textColor = .blue_main
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func setup(titles: [String], infos: [String]) {
        for (index, title) in titles.enumerated() {
            self.titles.filter({ $0.tag == index }).first?.text = title
        }
        for (index, info) in infos.enumerated() {
            self.infos.filter({ $0.tag == index }).first?.attributedText = nil
            self.infos.filter({ $0.tag == index }).first?.text = info.uppercased()
        }
    }
    
    func setup(titles: [String], infos: [NSAttributedString]) {
        for (index, title) in titles.enumerated() {
            self.titles.filter({ $0.tag == index }).first?.text = title
        }
        for (index, info) in infos.enumerated() {
            self.infos.filter({ $0.tag == index }).first?.text = nil
            self.infos.filter({ $0.tag == index }).first?.attributedText = info
        }
    }

}
