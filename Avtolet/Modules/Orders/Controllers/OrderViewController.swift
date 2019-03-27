//
//  OrdersOrdersViewController.swift
//  avtolet
//
//  Created by Igor Tyukavkin on 30/03/2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import MaterialActivityIndicator
import SVProgressHUD

class OrderViewController: CommonViewController {

    @IBOutlet weak var tableView: UITableView! {
        willSet {
            newValue.register(nib: AuthTitleCell.self)
            newValue.register(nib: MainTitleCell.self)
            newValue.register(nib: MainRouteCell.self)
            newValue.register(nib: RoundedCell.self)
            newValue.register(nib: RegistrationButtonCell.self)
            newValue.tableFooterView = UIView()
            newValue.estimatedRowHeight = 100.0
            newValue.rowHeight = UITableViewAutomaticDimension
            newValue.contentInset = UIEdgeInsets.init(top: 6.0, left: 0.0, bottom: 10.0, right: 0.0)
        }
    }
    
    @IBOutlet weak var errorView: ErrorView! {
        willSet {
            newValue.isHidden = true
            newValue.buttonTappedHandler = { [weak self] in
                self?.reload()
            }
        }
    }
    
    @IBOutlet weak var loadingView: MaterialActivityIndicatorView! {
        willSet {
            newValue.isHidden = true
            newValue.color = UIColor.blue_main
            newValue.backgroundColor = .clear
        }
    }
    
    fileprivate lazy var presentationModel: OrdersPresentationModel = { [unowned self] in
        let model = OrdersPresentationModel() { [weak self] in
            self?.handleError($0)
        }
        model.loadingHandler = { [weak self] in
            $0 ? self?.showHUD() : self?.hideHUD()
        }
        return model
    }()
    
    fileprivate lazy var datasource: OrderDataSource = { [unowned self] in
        let datasource = OrderDataSource(tableView: self.tableView)
        datasource.buttonTapped = { [weak self] in
            self?.buttonTapped()
        }
        datasource.communicateHandler = { [weak self] in
            self?.communicate(performer: $0)
        }
        datasource.canCancelOrder = self.canCancelOrder
        return datasource
    }()
    
    var order: ShortOrder?
    var cancelHandler: ((String) -> ())?
    var activeOrder: Order?
    var performer: OrderPerformer?
    var state: MyOrdersState!
    var orderId: Int?
    var workAccepted: ((Bool) -> ())?
    var canCancelOrder = true

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.default_bgColor
        navigationItem.title = order?.title ?? (state == .active ? "Информация о заказе" : "Расчёт с исполнителем")
        if navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "close-icon"), style: .plain, target: self, action: #selector(close))
        }
        presentationModel.workAccepted = { [weak self] in
            self?.workAccepted(completed: $0)
        }
        presentationModel.showHUDHandler = {
            $0 ? SVProgressHUD.show() : SVProgressHUD.dismiss()
        }
        presentationModel.updateHandler = { [weak self] in
            self?.datasource.state = self?.state ?? .completed
            self?.datasource.update(order: $0)
        }
        presentationModel.showErrorHandler = { [weak self] in
            self?.showAlert(message: kDefaultErrorMessage)
        }
        if let order = order {
            presentationModel.loadOrder(id: order.id)
        } else if let activeOrder = activeOrder {
            presentationModel.updateHandler?(activeOrder)
        } else if let performer = performer {
            datasource.update(performer: performer)
        }
    }
    
    @objc func close() {
        if let performer = performer {
            AvtoletService.shared.performerReviewed(performer: performer)
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func handleError(_ error: RCError) {
        errorView.isHidden = false
    }
    
    override func showHUD() {
        errorView.isHidden = true
        loadingView.isHidden = false
        loadingView.startAnimating()
    }
    
    override func hideHUD() {
        loadingView.stopAnimating()
        loadingView.isHidden = true
    }
    
    func reload() {
        if let order = order {
            presentationModel.loadOrder(id: order.id)
        } else if let activeOrder = activeOrder {
            presentationModel.updateHandler?(activeOrder)
        }
    }
    
    func buttonTapped() {
        if state == .active {
            let reasons = ["Уже сделан заказ в другой компании",
                           "Указаны неверные параметры заказа",
                           "Передумали делать заказ",
                           "Заказ создан по ошибке",
                           "Не назначились исполнители"]
            let actionVC = UIAlertController(title: "Причина отмены заказа", message: nil, preferredStyle: .actionSheet)
            actionVC.view.tintColor = UIColor.blue_main
            reasons.forEach({ [weak self] title in
                let action = UIAlertAction(title: title, style: UIAlertActionStyle.default, handler: { [weak self] (_) in
                    self?.dismiss(animated: true, completion: { [weak self] in
                        self?.cancelHandler?(title)
                    })
                })
                actionVC.addAction(action)
            })
            actionVC.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            present(actionVC, animated: true, completion: nil)
        } else if state == .review {
            guard let performerId = performer?.performer?.id, let orderId = orderId else { return }
            presentationModel.acceptWork(performerId: performerId, orderId: orderId, rating: datasource.rating)
        }
    }
    
    func communicate(performer: OrderPerformer) {
        ChatRouter(presenter: self).presentChat(performer: performer)
    }
    
    func workAccepted(completed: Bool) {
        if let performer = performer {
            AvtoletService.shared.performerReviewed(performer: performer)
        }
        dismiss(animated: true) { [weak self] in
            self?.workAccepted(completed: completed)
        }
    }
    
}
