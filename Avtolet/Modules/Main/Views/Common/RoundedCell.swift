//
//  RoundedCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 27.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class RoundedCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 20.0
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = UIColor.border_color_main.cgColor
        }
    }
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var topInset: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        bgView.alpha = highlighted ? 0.5 : 1.0
    }
    
//    func setup(plan: TariffPlan) {
//        if stackView.arrangedSubviews.count > 0 {
//            (stackView.arrangedSubviews.first as? UILabel)?.text = plan.name
//            for (index, model) in plan.description.enumerated() {
//                (stackView.arrangedSubviews[index + 1] as? DescriptionView)?.setup(model: model)
//            }
//        } else {
//            let titleLabel = UILabel()
//            titleLabel.text = plan.name
//            titleLabel.font = UIFont.cuprumFont(ofSize: 20.0)
//            titleLabel.textColor = .black
//            stackView.addArrangedSubview(titleLabel)
//            plan.description.forEach({ [weak self] in
//                self?.stackView.addArrangedSubview(DescriptionView.view(model: $0))
//            })
//        }
//    }
//    
    func setup(shortOrder: ShortOrder, isCanceled: Bool) {
        if topInset.constant != 6.0 {
            topInset.constant = 6.0
            layoutIfNeeded()
        }
        let dateString = isCanceled || shortOrder.startTime == 0 ? "-" : DateFormatter.orderDateFormatter.string(from: Date(timeIntervalSince1970: shortOrder.startTime))
        let totalPrice = isCanceled ? "-" : PriceFormatter.stringFromPrice(price: ceil(shortOrder.totalPrice))
        let distance = shortOrder.startTime > 0 ? NumberFormatter.distanceString(shortOrder.distanceRoute) : "-"
        let duration = shortOrder.startTime > 0 ? String.durationString(shortOrder.durationRoute) : "-"
        if stackView.arrangedSubviews.count > 0 {
            (stackView.arrangedSubviews.first as? DescriptionView)?.leftLabel.text = shortOrder.title
            (stackView.arrangedSubviews.first as? DescriptionView)?.rightLabel.text = dateString
            (stackView.arrangedSubviews[1] as? DescriptionView)?.rightLabel.text = distance
            (stackView.arrangedSubviews[2] as? DescriptionView)?.rightLabel.text = duration
            if totalPrice != "-" {
                if stackView.arrangedSubviews.count == 4 {
                    (stackView.arrangedSubviews[3] as? DescriptionView)?.rightLabel.text = totalPrice
                } else {
                    stackView.addArrangedSubview(DescriptionView.view(model: ("Итоговая стоимость", totalPrice)))
                }
            } else if stackView.arrangedSubviews.count == 4 {
                let subview = stackView.arrangedSubviews.last
                stackView.removeArrangedSubview(subview!)
                subview?.removeFromSuperview()
            }
        } else {
            let titleLabel = DescriptionView.view(model: (shortOrder.title, dateString))
            titleLabel.leftLabel.font = UIFont.cuprumFont(ofSize: 20.0)
            titleLabel.leftLabel.textColor = .black
            titleLabel.rightLabel.textColor = .black
            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(DescriptionView.view(model: ("Протяженность маршрута", distance)))
            stackView.addArrangedSubview(DescriptionView.view(model: ("Длительность заказа", duration)))
            if totalPrice != "-" {
                stackView.addArrangedSubview(DescriptionView.view(model: ("Итоговая стоимость", totalPrice)))
            }
        }
    }
    
    func setup(fare: [OrderPerformerFare]) {
        guard stackView.arrangedSubviews.count == 0 else { return }
        let topInfoLabelSpace: CGFloat = 2.0
        let rightInfoLabelSpace: CGFloat = 1.0
        topInset.constant = 17.0
        let titleLabel = UILabel()
        titleLabel.text = "Подробная информация"
        titleLabel.font = UIFont.cuprumFont(ofSize: 17.0)
        titleLabel.textColor = .black
        stackView.addArrangedSubview(titleLabel)
        for fareInfo in fare {
            let titleView = OrderFareView.view(model: (fareInfo.name, PriceFormatter.stringFromPrice(price: ceil(fareInfo.minPrice))))
            titleView.leftLabel.font = UIFont.cuprumFont(ofSize: 22.0)
            titleView.leftLabel.textColor = .black
            titleView.rightLabel.font = UIFont.cuprumFont(ofSize: 20.0)
            titleView.topConstraint.constant += 4.0
            stackView.addArrangedSubview(titleView)
            if fareInfo.overTimePrice > 0 {
                let infoView = OrderFareView.view(model: ("+ " + String.durationString(fareInfo.overTime), PriceFormatter.stringFromPrice(price: ceil(fareInfo.overTimePrice))))
                infoView.topConstraint.constant = topInfoLabelSpace
                infoView.rightConstraint.constant = rightInfoLabelSpace
                stackView.addArrangedSubview(infoView)
            }
            if fareInfo.intercityPrice > 0 {
                let distance = floor(fareInfo.intercityDistance / 1000.0)
                let infoView = OrderFareView.view(model: ("+ \(NumberFormatter.distanceString(distance)) (межгород)", PriceFormatter.stringFromPrice(price: ceil(fareInfo.intercityPrice))))
                infoView.topConstraint.constant = topInfoLabelSpace
                infoView.rightConstraint.constant = rightInfoLabelSpace
                stackView.addArrangedSubview(infoView)
            }
            if fareInfo.highDemandAreaPrice > 0 {
                let infoView = OrderFareView.view(model: ("+ " + "Районный коэффициент", PriceFormatter.stringFromPrice(price: ceil(fareInfo.highDemandAreaPrice))))
                infoView.topConstraint.constant = topInfoLabelSpace
                infoView.rightConstraint.constant = rightInfoLabelSpace
                stackView.addArrangedSubview(infoView)
            }
            if fareInfo.highDemandTimePrice > 0 {
                let infoView = OrderFareView.view(model: ("+ " + "Повышающий коэффициент", PriceFormatter.stringFromPrice(price: ceil(fareInfo.highDemandTimePrice))))
                infoView.topConstraint.constant = topInfoLabelSpace
                infoView.rightConstraint.constant = rightInfoLabelSpace
                stackView.addArrangedSubview(infoView)
            }
        }
    }
    
}
