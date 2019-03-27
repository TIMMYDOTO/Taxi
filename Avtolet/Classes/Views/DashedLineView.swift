//
//  DashedLineView.swift
//  AzbukaVkusaExpress
//
//  Created by Igor Tyukavkin on 18.12.2017.
//  Copyright © 2017 Igor Tyukavkin. All rights reserved.
//

import UIKit

class DashedLineView: UIView {

    @IBInspectable var lineColor: UIColor = UIColor.init(white: 118.0/255.0, alpha: 1.0)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addDashedLine(color: lineColor)
    }

    fileprivate func addDashedLine(color: UIColor) {
        layer.sublayers?.filter({ $0.name == "DashedTopLine" }).forEach({ $0.removeFromSuperlayer() })
        self.backgroundColor = UIColor.clear
        let cgColor = color.cgColor
        
        let shapeLayer: CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.name = "DashedTopLine"
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width / 2, y: frameSize.height / 2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineDashPattern = [2, 4]
        
        let path: CGMutablePath = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: self.frame.width, y: 0.0))
        shapeLayer.path = path
        
        self.layer.addSublayer(shapeLayer)
    }
    
}
