//
//  LoadingLoadingViewController.swift
//  avtolet
//
//  Created by Igor Tyukavkin on 28/03/2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import MaterialActivityIndicator

class LoadingViewController: CommonViewController {

    @IBOutlet weak var indicatorView: MaterialActivityIndicatorView! {
        willSet {
            newValue.isHidden = true
            newValue.color = UIColor.blue_main
            newValue.backgroundColor = .clear
        }
    }
    
    fileprivate lazy var presentationModel: LoadingPresentationModel = { [unowned self] in
        let model = LoadingPresentationModel() { [weak self] in
            self?.handleError($0)
        }
        model.loadingHandler = { [weak self] in
            $0 ? self?.showHUD() : self?.hideHUD()
        }
        return model
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presentationModel.getClientInfo()
    }
    
    override func handleError(_ error: RCError) {
        showAlert(message: kDefaultErrorMessage, buttons: ["Повторить"]) { [weak self] _ in
            if self?.presentationModel.clientInfoLoaded == true {
                self?.presentationModel.getActiveOrder()
            } else {
                self?.presentationModel.getClientInfo()
            }
        }
    }
    
    override func showHUD() {
        indicatorView.isHidden = false
        indicatorView.startAnimating()
    }
    
    override func hideHUD() {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
    }
}
