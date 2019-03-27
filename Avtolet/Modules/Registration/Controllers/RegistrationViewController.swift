//
//  RegistrationRegistrationViewController.swift
//  avtolet
//
//  Created by Igor Tyukavkin on 28/03/2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class RegistrationViewController: CommonViewController {

    @IBOutlet weak var tableView: UITableView! {
        willSet {
            newValue.register(nib: RegistrationButtonCell.self)
            newValue.tableFooterView = UIView()
            newValue.estimatedRowHeight = 100.0
            newValue.rowHeight = UITableViewAutomaticDimension
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    fileprivate lazy var presentationModel: RegistrationPresentationModel = { [unowned self] in
        let model = RegistrationPresentationModel() { [weak self] in
            self?.handleError($0)
        }
        model.loadingHandler = { [weak self] in
            $0 ? self?.showHUD() : self?.hideHUD()
        }
        model.registrationCompleted = { [weak self] in
            self?.registrationCompleted()
        }
        return model
    }()
    
    fileprivate lazy var datasource: RegistrationDataSource = { [unowned self] in
        let datasource = RegistrationDataSource(tableView: self.tableView)
        return datasource
    }()
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindScrollViewToKeyboard(tableView)
        datasource.buttonTappedHandler = { [weak self] in
            self?.buttonTapped()
        }
        datasource.update()
    }
    
    func registrationCompleted() {
        LoadingRouter(presenter: self).setLoading()
    }
    
    func buttonTapped() {
        tableView.endEditing(true)
        if datasource.nameValid && datasource.emailValid {
            presentationModel.registerClient(name: datasource.name, email: datasource.email, city: "Новосибирск")
        } else {
            datasource.validationMode()
        }
    }
}
