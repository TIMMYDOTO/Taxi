//
//  FindAddressFindAddressViewController.swift
//  avtolet
//
//  Created by Igor Tyukavkin on 29/03/2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class FindAddressViewController: CommonViewController {

    @IBOutlet weak var findButton: UIButton! {
        willSet {
            newValue.titleLabel?.font = UIFont.cuprumFont(ofSize: 20.0)
            newValue.layer.backgroundColor = UIColor.blue_main.cgColor
            newValue.setTitleColor(.white, for: .normal)
            newValue.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)
            newValue.setTitleColor(.text_grey, for: .disabled)
            newValue.layer.cornerRadius = 24.0
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = UIColor.clear.cgColor
            newValue.addShadow()
            newValue.setTitle("Выбрать место на карте".uppercased(), for: .normal)
        }
    }
    
    @IBOutlet weak var searchBgView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 25.0
            newValue.layer.masksToBounds = true
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = UIColor.border_color_main.cgColor
            newValue.backgroundColor = .white
        }
    }
    
    @IBOutlet weak var searchBar: RCSearchBar! {
        willSet {
            newValue.placeholderColor = .border_color_main
            newValue.font = UIFont.cuprumFont(ofSize: 18.0)
            newValue.tintColor = .border_color_main
            newValue.backgroundColor = .clear
            newValue.searchDelegate = self
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        willSet {
            newValue.tableFooterView = UIView()
            newValue.estimatedRowHeight = 100.0
            newValue.rowHeight = UITableViewAutomaticDimension
            newValue.backgroundColor = .clear
            newValue.contentInset = UIEdgeInsets(top: 2.0, left: 0.0, bottom: 10.0, right: 0.0)
        }
    }
    
    @IBOutlet weak var separatorView: UIView! {
        willSet {
            newValue.backgroundColor = UIColor.border_color_main
        }
    }
    
    fileprivate lazy var presentationModel: FindAddressPresentationModel = { [unowned self] in
        let model = FindAddressPresentationModel() { [weak self] in
            self?.handleError($0)
        }
        model.loadingHandler = { [weak self] in
            $0 ? self?.showHUD() : self?.hideHUD()
        }
        return model
    }()

    fileprivate lazy var datasource: FindAddressDataSource = { [unowned self] in
        let datasource = FindAddressDataSource(tableView: self.tableView)
        return datasource
        }()
    
    var addressSelected: ((SearchAddress) -> ())?
    
  
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Поиск адреса"
        navigationItem.removeBackButtonTitle()
        view.backgroundColor = UIColor.default_bgColor
        presentationModel.searchAddressUpdateHandler = { [weak self] in
            self?.datasource.update(addresses: $0)
        }
        datasource.addressSelected = { [weak self] in
            self?.addressSelectedAction($0)
        }
    }
    
    func addressSelectedAction(_ address: SearchAddress) {
        addressSelected?(address)
        close()
    }
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openMap() {
        FindAddressRouter(presenter: self).showMap() { [weak self] in
            self?.addressSelected?($0)
        }
    }
}

extension FindAddressViewController: RCSearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: RCSearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: RCSearchBar) -> Bool {
        return true
    }
    
    func searchBar(_ searchBar: RCSearchBar, textDidChange searchText: String) {
        presentationModel.obtainAddresses(withText: searchBar.text ?? "")
    }
}
