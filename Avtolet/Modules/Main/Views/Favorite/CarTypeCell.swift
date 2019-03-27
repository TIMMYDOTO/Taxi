//
//  CarTypeCell.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 11/25/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class CarTypeCell: UICollectionViewCell {
    
    @IBOutlet var carImageView: UIImageView!
    @IBOutlet var carNameLabel: UILabel!
    
    func fillWithCar(tariff: Tarif) -> CarTypeCell {
        if let img = UIImage(named: tariff.name){
            carImageView.image = img
        }
        carNameLabel.text = tariff.name
        
        return self
    }
    
    func fillWithCar(carType: CarType) -> CarTypeCell {
        if let img = UIImage(named: carType.name){
            carImageView.image = img
        }
        carNameLabel.text = carType.name
        self.alpha = 0.3
        return self
    }
}

