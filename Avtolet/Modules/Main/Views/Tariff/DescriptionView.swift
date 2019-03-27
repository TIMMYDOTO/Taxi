//
//  TarifDescriptionView.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 27.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class DescriptionView: UIView {

    @IBOutlet weak var leftLabel: UILabel! {
        willSet {
            newValue.font = UIFont.cuprumFont(ofSize: 18.0)
            newValue.textColor = UIColor.init(white: 118.0/255.0, alpha: 1.0)
        }
    }
    
    @IBOutlet weak var rightLabel: UILabel! {
        willSet {
            newValue.font = UIFont.cuprumFont(ofSize: 18.0)
            newValue.textColor = UIColor.black
        }
    }
    
    func setup(model: (String, String)) {
        leftLabel.text = model.0
        rightLabel.text = model.1
    }
    
    static func view(model: (String, String)) -> DescriptionView {
        let view = Bundle.main.loadNibNamed("DescriptionView", owner: nil, options: nil)?.filter({ $0 is DescriptionView }).first as! DescriptionView
        view.setup(model: model)
        return view
    }

}
