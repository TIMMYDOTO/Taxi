//
//  GradientView.swift
//  AzbukaVkusaExpress
//
//  Created by Igor Tyukavkin on 17.07.17.
//  Copyright © 2017 Igor Tyukavkin. All rights reserved.
//

import UIKit

class GradientView: UIView {

    @IBInspectable var startColor: UIColor = UIColor.white.withAlphaComponent(0.0)
    @IBInspectable var endColor: UIColor = .white
    @IBInspectable var isHorizontal: Bool = false
    
    override var frame: CGRect {
        didSet {
            updateGradient()
        }
    }
    
    func setGradientColors(startColor: UIColor, endColor: UIColor, isHorizontal: Bool = false) {
        setGradient([startColor, endColor], horizontal: isHorizontal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setGradientColors(startColor: startColor, endColor: endColor, isHorizontal: isHorizontal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradient()
    }
}
