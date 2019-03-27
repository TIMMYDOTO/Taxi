//
//  TariffColectionCell.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 27.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

enum TariffColectionCellState {
    case selected, unselected
}

class TariffColectionCell: UICollectionViewCell {

    static let defaultHeight: CGFloat = 42.0
    static let TariffFont = UIFont.cuprumFont(ofSize: 14.0)
    
    @IBOutlet weak var backgroundSelectionView: UIView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = TariffColectionCell.defaultHeight / 2.0
            newValue.layer.borderWidth = 1.0
        }
    }
    @IBOutlet weak var label: UILabel! {
        willSet {
            newValue.font = TariffColectionCell.TariffFont
        }
    }
    
    fileprivate(set) var state = TariffColectionCellState.unselected {
        didSet {
            changeState()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeState()
    }
    
    func setup(title: String, isSelected: Bool) {
        label.text = title.uppercased()
        state = isSelected ? .selected : .unselected
    }
    
    static func width(title: String) -> CGFloat {
        let size = NSString(string: title.uppercased()).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: defaultHeight), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font: TariffFont], context: nil).size
        return ceil(size.width) + 20.0
    }
    
    fileprivate func changeState() {
        switch state {
            case .selected:
                backgroundSelectionView.layer.borderColor = UIColor.blue_main.cgColor
                backgroundSelectionView.backgroundColor = .blue_main
                label.textColor = .white
            case .unselected:
                backgroundSelectionView.layer.borderColor = UIColor.blue_main.cgColor
                backgroundSelectionView.backgroundColor = .white
                label.textColor = .blue_main
        }
    }

}
