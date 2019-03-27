//
//  OrderFareView.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 02.04.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class OrderFareView: UIView {

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
    
    @IBOutlet weak var separator: DashedLineView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    
    func setup(model: (String, String)) {
        leftLabel.text = model.0
        rightLabel.text = model.1
    }
    
    static func view(model: (String, String)) -> OrderFareView {
        let view = Bundle.main.loadNibNamed("OrderFareView", owner: nil, options: nil)?.filter({ $0 is OrderFareView }).first as! OrderFareView
        view.setup(model: model)
        return view
    }

}
