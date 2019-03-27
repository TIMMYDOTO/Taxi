//
//  TariffCell.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 12/6/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class TariffCell: UITableViewCell {
    @IBOutlet var dayCostsLabel: UILabel!
    @IBOutlet var nightCostsLabel: UILabel!
    @IBOutlet var holidayCostsLabel: UILabel!
    
    

    
    @IBOutlet var dayAfter10MInutesLabel: UILabel!
    @IBOutlet var nightAfter10MInutesLabel: UILabel!
    @IBOutlet var holidayAfter10MInutesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillInWithTariff(tariff: TariffPresentModel) -> TariffCell{
  
        dayCostsLabel.text = String(tariff.dayCosts) + " руб"
        dayAfter10MInutesLabel.text = String(tariff.dayAfter10MinutesCots) + " руб/мин"
        
        nightCostsLabel.text = String(tariff.nightCosts) + " руб"
        nightAfter10MInutesLabel.text = String(tariff.nightAfter10MinutesCosts) + " руб/мин"

        holidayCostsLabel.text = String(tariff.holidayCosts) + " руб"
        holidayAfter10MInutesLabel.text = String(tariff.holidayAfter10MinutesCosts) + " руб/мин"
        return self
        
    }
}
