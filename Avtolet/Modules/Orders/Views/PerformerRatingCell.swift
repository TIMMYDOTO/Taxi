//
//  PerformerRatingCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 06.04.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class PerformerRatingCell: UITableViewCell {

    @IBOutlet var stars: [UIButton]! {
        willSet {
            newValue.forEach({
                $0.setImage(#imageLiteral(resourceName: "icon-star").changeColor(color: UIColor.blue_main), for: .selected)
                $0.setImage(#imageLiteral(resourceName: "icon-star").changeColor(color: UIColor.blue_main), for: .highlighted)
                $0.setImage(#imageLiteral(resourceName: "icon-star").changeColor(color: UIColor.border_color_main), for: .normal)
            })
        }
    }
    
    @IBOutlet weak var bgView: UIView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 20.0
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = UIColor.border_color_main.cgColor
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.cuprumFont(ofSize: 17.0)
            newValue.textColor = .black
        }
    }
    
    var ratingSelected: ((Int) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func setup(title: String, rating: Int) {
        titleLabel.text = title
        setRating(rating: rating)
    }
    
    @IBAction func starTap(star: UIButton) {
        setRating(rating: star.tag)
        ratingSelected?(star.tag)
    }
    
    fileprivate func setRating(rating: Int) {
        stars.forEach({ $0.isSelected = $0.tag <= rating })
    }
}
