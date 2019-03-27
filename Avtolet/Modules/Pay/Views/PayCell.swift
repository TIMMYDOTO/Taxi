//
//  PayCell.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 11/2/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
protocol PayCellDelegate {
    func didTapRemoveCard(card_Id: String)
}
class PayCell: UITableViewCell {
    var delegate: PayCellDelegate?
    @IBOutlet var cardImageView: UIImageView!
    
    @IBOutlet var cardNumberLabel: UILabel!
    
    @IBOutlet var removeCard: UIButton!
    var card_id: String!
    var paymentType: Int!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func fillIn(with card: Card) -> PayCell {
        cardImageView.image = UIImage(imageLiteralResourceName: "mastercard")
        card_id = card.card_id
        cardNumberLabel.text = card.pan
        cardNumberLabel.sizeToFit()
        paymentType = 2
        
        
        
        
        
        return self
    }
    
    
    @IBAction func removeCardClicked(_ sender: UIButton) {
        delegate?.didTapRemoveCard(card_Id: card_id)
    }
    
}
