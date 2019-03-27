//
//  AdditionalServicesCell.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 10/30/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class AdditionalServicesCell: UITableViewCell {

    @IBOutlet var additionalServiceLabel: UILabel!
    @IBOutlet var bulletImgView: UIImageView!
    
    var selectedBullet = Bool()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
