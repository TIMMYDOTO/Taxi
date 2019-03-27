//
//  AVSearchBar.swift
//  AzbukaVkusaExpress
//
//  Created by Igor Tyukavkin on 16.01.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

protocol RCSearchBarDelegate: NSObjectProtocol {
    func searchBarSearchButtonClicked(_ searchBar: RCSearchBar)
    func searchBarShouldBeginEditing(_ searchBar: RCSearchBar) -> Bool
    func searchBar(_ searchBar: RCSearchBar, textDidChange searchText: String)
}

class RCSearchBar: UITextField {

    var searchIcon: UIImage = #imageLiteral(resourceName: "searchbar-icon-close")
    var clearIcon: UIImage = #imageLiteral(resourceName: "searchbar-icon-close")
    var placeholderColor: UIColor = UIColor.placeholder_grey
    var textInset: CGFloat = 8.0
    var cornerRadius: CGFloat = 4.0

    weak var searchDelegate: RCSearchBarDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        delegate = self
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        returnKeyType = .search
        leftViewMode = .always
        rightViewMode = .always
        setupViews()
    }
    
    
    func setupViews() {
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
        attributedPlaceholder = placeholder?.attributed(attributes: [NSAttributedStringKey.font: font ?? UIFont.systemFont(ofSize: 15.0), NSAttributedStringKey.foregroundColor: placeholderColor])
        let imageView = UIImageView(image: searchIcon.changeColor(color: placeholderColor))
        imageView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: searchIcon.size.width + 2*textInset, height: searchIcon.size.width))
        imageView.contentMode = .center
        leftView = imageView
        let button = UIButton(type: .system)
        button.setImage(clearIcon, for: .normal)
        button.addTarget(self, action: #selector(clear), for: .touchUpInside)
        button.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: clearIcon.size.width + 2*textInset, height: clearIcon.size.width))
        rightView = button
        (rightView as? UIButton)?.isHidden = (text?.isEmpty ?? true)
    }
    
    @objc fileprivate func clear() {
        text = nil
        textDidChange()
    }
    
}

extension RCSearchBar {
    func setImage(_ image: UIImage, for iconType: UISearchBarIcon) {
        switch iconType {
        case .search:
            searchIcon = image
        case .clear:
            clearIcon = image
        default:()
        }
        setupViews()
    }
}

extension RCSearchBar: UITextFieldDelegate {
    @objc func textDidChange() {
        let text = self.text ?? ""
        (rightView as? UIButton)?.isHidden = text.isEmpty
        searchDelegate?.searchBar(self, textDidChange: text)
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return searchDelegate?.searchBarShouldBeginEditing(self) ?? true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchDelegate?.searchBarSearchButtonClicked(self)
        return true
    }
}
