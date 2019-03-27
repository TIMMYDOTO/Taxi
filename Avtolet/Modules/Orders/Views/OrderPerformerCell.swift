//
//  OrderPerformerCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 01.04.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import Kingfisher

class OrderPerformerCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 20.0
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = UIColor.border_color_main.cgColor
        }
    }
    
    @IBOutlet weak var performerImageView: UIImageView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 37.0
            newValue.layer.borderWidth = 3.0
            newValue.layer.borderColor = UIColor.blue_main.cgColor
            newValue.backgroundColor = UIColor.default_bgColor
        }
    }
    
    @IBOutlet weak var performerNameLabel: UILabel! {
        willSet {
            newValue.font = UIFont.cuprumFont(ofSize: 20.0)
            newValue.textColor = .black
        }
    }
    
    @IBOutlet weak var performerInfoLabel: UILabel! {
        willSet {
            newValue.font = UIFont.cuprumFont(ofSize: 16.0)
            newValue.textColor = UIColor.text_grey
        }
    }
    
    @IBOutlet weak var performerTypeImageView: UIImageView!
    
    @IBOutlet weak var communicateBtn: UIButton! {
        willSet {
            newValue.setImage(#imageLiteral(resourceName: "icon-communicate").changeColor(color: UIColor.blue_main), for: .normal)
            newValue.setImage(#imageLiteral(resourceName: "icon-communicate").changeColor(color: UIColor.blue_main.withAlphaComponent(0.5)), for: .highlighted)
        }
    }
    
    @IBOutlet weak var btnWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    var performer: OrderPerformer?
    var communicateHandler: ((OrderPerformer) -> ())?
    
    func setup(performer: OrderPerformer, state: MyOrdersState) {
        if state != .active && btnWidth.constant != 0.0 {
            btnWidth.constant = 0.0
            communicateBtn.isHidden = true
        }
        self.performer = performer
        var name = performer.performer?.fullName.name ?? ""
        if let rating = performer.performer?.rating {
            name += " " + rating + " ★"
        }
        performerNameLabel.text = name
        performerInfoLabel.text = performer.performer?.status.title.uppercased()
        performerTypeImageView.image = performer.type == .driver ? #imageLiteral(resourceName: "driver") : #imageLiteral(resourceName: "clerk")
        if let photo = performer.imageURL {
            performerImageView.kf.setImage(with: ImageResource(downloadURL: photo))
        } else {
            performerImageView.image = nil
        }
    }
    
    @IBAction func communicateButtonTapped() {
        guard let performer = self.performer else { return }
        communicateHandler?(performer)
    }

}
