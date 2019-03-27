//
//  OrdersHistoryViewController.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 28.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import MaterialActivityIndicator

class OrdersHistoryViewController: CommonViewController {

    @IBOutlet weak var tableView: UITableView! {
        willSet {
            newValue.register(nib: RoundedCell.self)
            newValue.tableFooterView = UIView()
            newValue.estimatedRowHeight = 150.0
            newValue.rowHeight = UITableViewAutomaticDimension
            newValue.contentInset = UIEdgeInsets.init(top: 3.0, left: 0.0, bottom: 10.0, right: 0.0)
        }
    }
    
    @IBOutlet weak var topView: UIView! {
        willSet {
            newValue.isHidden = true
        }
    }
    
    @IBOutlet weak var separatorView: UIView! {
        willSet {
            newValue.backgroundColor = UIColor.border_color_main
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
            newValue.color = .blue_main
            newValue.backgroundColor = .clear
        }
    }
    
    @IBOutlet var optionButtons: [UIButton]! {
        willSet {
            newValue.forEach({
                $0.layer.masksToBounds = true
                $0.layer.cornerRadius = TariffColectionCell.defaultHeight / 2.0
                $0.layer.borderWidth = 1.0
                $0.layer.borderColor = UIColor.blue_main.cgColor
                $0.setTitleColor(UIColor.blue_main, for: .normal)
                $0.setTitleColor(UIColor.white, for: .selected)
                $0.setTitleColor(UIColor.white, for: .highlighted)
                $0.setBackgroundColor(UIColor.white, forState: .normal)
                $0.setBackgroundColor(UIColor.blue_main, forState: .selected)
                $0.setBackgroundColor(UIColor.blue_main, forState: .highlighted)
                $0.titleLabel?.font = TariffColectionCell.TariffFont
            })
        }
    }
    
    fileprivate lazy var presentationModel: MyOrdersPresentationModel = { [unowned self] in
        let model = MyOrdersPresentationModel() { [weak self] in
            self?.handleError($0)
        }
        model.loadingHandler = { [weak self] in
            $0 ? self?.showHUD() : self?.hideHUD()
        }
        return model
    }()
    
    fileprivate lazy var datasource: MyOrdersDatasource = { [unowned self] in
        let datasource = MyOrdersDatasource(tableView: self.tableView)
        datasource.orderSelected = { [weak self] in
            self?.orderSelected(order: $0)
        }
        return datasource
    }()
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.default_bgColor
        navigationItem.removeBackButtonTitle()
        navigationItem.title = "История заказов"
        presentationModel.updateHandler = { [weak self] in
            self?.topView.isHidden = false
            self?.datasource.update(orders: $0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presentationModel.getOrders()
        guard !loadingView.isHidden else { return }
        loadingView.isHidden = true
        loadingView.stopAnimating()
        loadingView.isHidden = false
        loadingView.startAnimating()
    }

    func reload() {
        presentationModel.getOrders()
    }
    
    override func handleError(_ error: RCError) {
        guard topView.isHidden else { return }
        errorView.isHidden = false
    }
    
    override func showHUD() {
        guard topView.isHidden else { return }
        errorView.isHidden = true
        loadingView.isHidden = false
        loadingView.startAnimating()
    }
    
    override func hideHUD() {
        loadingView.stopAnimating()
        loadingView.isHidden = true
    }

    func orderSelected(order: ShortOrder) {
        OrdersRouter(presenter: self).showOrder(shortOrder: order, state: datasource.state)
    }
    
    @IBAction func buttonTapped(button: UIButton) {
        guard !button.isSelected else { return }
        optionButtons.forEach({ $0.isSelected = false })
        button.isSelected = true
        guard let state = MyOrdersState.init(rawValue: button.tag) else { return }
        datasource.changeState(state: state)
        guard state == .completed && (datasource.completedOrders?.count ?? 0) > 0
            || state == .canceled && (datasource.canceledOrders?.count ?? 0) > 0 else { return }
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
    }
    
}
