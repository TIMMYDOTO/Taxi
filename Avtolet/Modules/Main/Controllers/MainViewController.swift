//
//  MainMainViewController.swift
//  avtolet
//
//  Created by Artyom Schiopu on 26/03/2018.
//  Copyright © 2018 Artyom Schiopu. All rights reserved.
//

import UIKit
import MaterialActivityIndicator
import RxSwift
import RxCocoa

class MainViewController: CommonViewController {

    @IBOutlet weak var tableView: UITableView! {
        willSet {
            newValue.register(nib: AuthTitleCell.self)
            newValue.register(nib: RegistrationButtonCell.self)
            newValue.register(nib: MainTitleCell.self)
            newValue.register(nib: MainRouteCell.self)
            newValue.tableFooterView = UIView()
            newValue.backgroundColor = UIColor.default_bgColor
            newValue.estimatedRowHeight = 100.0
            newValue.rowHeight = UITableViewAutomaticDimension
            newValue.contentInset = UIEdgeInsets.init(top: 6.0, left: 0.0, bottom: 10.0, right: 0.0)
        }
    }
    
    fileprivate lazy var presentationModel: MainPresentationModel = { [unowned self] in
        let model = MainPresentationModel() { [weak self] in self?.handleError($0) }
        model.loadingHandler = { [weak self] in $0 ? self?.showHUD() : self?.hideHUD() }
        model.carsLoadingHandler = { [weak self] in self?.showCarsLoading($0) }
        model.carsErrorHandler = { [weak self] in self?.handleCarsError($0) }
        return model
    }()

    fileprivate lazy var datasource: MainDataSource = { [unowned self] in
        let datasource = MainDataSource(tableView: self.tableView)
        datasource.fromRouteSelected = { [weak self] in self?.fromRouteSelected() }
        datasource.toRouteSelected = { [weak self] in self?.toRouteSelected() }
        datasource.buttonTapped = { [weak self] in self?.order() }
        datasource.recalculateHandler = { [weak self] in self?.recalculate() }
        datasource.applyPromocodeHandler = { [weak self] in
            if $0.isEmptyOrWhitespace {
                if self?.datasource.promocode == nil {
                    self?.showAlert(message: "Введите промокод")
                } else {
                    self?.datasource.promocode = nil
                    self?.datasource.promocodeId = nil
                }
            } else {
                self?.presentationModel.checkPromocode(promocode: $0)
            }
        }
        return datasource
    }()
    
    @IBOutlet weak var errorView: ErrorView! {
        willSet {
            newValue.isHidden = true
            newValue.buttonTappedHandler = { [weak self] in
                self?.reloadCars()
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
    var showAlertError: String?
    
    let disposeBag = DisposeBag()
    var needOrder = false
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        AvtoletService.shared.setup()
        view.backgroundColor = UIColor.default_bgColor
        navigationItem.title = "Заказ грузового такси"
        configure(granted: PushNotificationsService.shared.granted.value == true)
    }
    
    func configure(granted: Bool) {
        guard User.current.activeOrder == nil else {
            if !granted {
                errorView.label.text = "Включите функцию push-уведомлений, чтобы отслеживать заказ"
                errorView.button.setTitle("Настройки", for: .normal)
                errorView.buttonTappedHandler = openSettings
                errorView.isHidden = false
            }
            return
        }
        ChatService.shared.reset()
        AvtoletService.shared.reset()
        bindScrollViewToKeyboard(tableView)
        presentationModel.carsObtained = { [weak self] in
            self?.datasource.update(cars: $0)
        }
        presentationModel.fareObtained = { [weak self] in
            self?.datasource.updatePrice(price: $0.totalPrice)
        }
        presentationModel.routeObtained = { [weak self] in
            self?.datasource.route = $0
            self?.recalculate()
            if self?.needOrder == true {
                self?.needOrder = false
                self?.order()
            }
        }
        presentationModel.showAlertMessage = { [weak self] in
            self?.showAlertMessage(alert: $0)
        }
        presentationModel.orderCreated = { [weak self] in
            self?.orderCreated()
        }
        presentationModel.promocodeApplyedHandler = { [weak self] in
            self?.datasource.promocode = $0
            self?.datasource.promocodeId = $1
        }
        presentationModel.getCars()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !loadingView.isHidden else { return }
        loadingView.isHidden = true
        loadingView.stopAnimating()
        loadingView.isHidden = false
        loadingView.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard User.current.activeOrder == nil else {
            guard PushNotificationsService.shared.granted.value == true else { return }
            OrdersRouter(presenter: self).setActiveOrder(animated: false)
            return
        }
        if let showAlertError = showAlertError {
            showAlertMessage(alert: showAlertError)
        }
    }
    
    func showAlertMessage(alert: String) {
        guard presentedViewController == nil else { showAlertError = alert ; return }
        showAlertError = nil
        showAlert(message: alert)
    }
    
}

// MARK: - Actions
extension MainViewController {
    func fromRouteSelected() {
        DispatchQueue.main.async { [unowned self] in
//            FindAddressRouter(presenter: self).presentFindAddress() { [weak self] address in
//                self?.datasource.updateFromAddress(address: address)
//            }
        }
    }
    func toRouteSelected() {
        DispatchQueue.main.async { [unowned self] in
//            FindAddressRouter(presenter: self).presentFindAddress() { [weak self] address in
//                self?.datasource.updateToAddress(address: address)
//            }
        }
    }
    func order() {
        if PushNotificationsService.shared.granted.value != true {
            showAlert(message: "Включите функцию\npush-уведомлений, чтобы оформить заказ",
                      buttons: ["Отмена", "Настройки"],
                      cancelButtonIndex: 0) { index in
                        if index == 1 {
                            openSettings()
                        }
            }
        } else if datasource.fromRoute == nil || datasource.toRoute == nil {
            showAlert(message: "Не указан маршрут поездки")
        } else if datasource.descr.trim().isEmpty {
            showAlert(message: "Заполните описание груза")
        } else if let error = presentationModel.error {
            showAlert(message: error)
        } else if datasource.route == nil {
            needOrder = true
            showHUD()
            recalculate()
        } else {
            let newOrder = NewOrder(token: User.current.accessToken!, truckCategoryId: datasource.selectedCar!, truckFrameId: datasource.selectedCarFrame!, cargoDescription: datasource.descr, countLoaders: datasource.loaders, servicesId: datasource.selectedOptions.count > 0 ? datasource.selectedOptions.map({ "\($0)" }).joined(separator: ",") : nil, routeData: datasource.route!, promoCodeId: datasource.promocodeId)
            try? presentationModel.createOrder(newOrder: newOrder)
        }
    }
    
    func recalculate() {
        guard let route = datasource.route,
            let truckCategoryId =  datasource.selectedCar,
            let truckFrameId = datasource.querySelectedCarFrame
                else {
                    if  let from = datasource.fromRoute,
                        let to = datasource.toRoute {
                        presentationModel.getRoute(origin: from.query, destination: to.query)
                    }
                    return
        }
        let durationRoute = route.time
        let distanceRoute = route.distance
        let overviewPolyline = route.overviewPolyline
        let countLoaders = datasource.loaders
        let servicesId = datasource.selectedOptions
        let promoCodeId = datasource.promocodeId
        presentationModel.getFare(truckCategoryId: truckCategoryId, truckFrameId: truckFrameId, durationRoute: durationRoute, distanceRoute: distanceRoute, overviewPolyline: overviewPolyline, countLoaders: countLoaders, servicesId: servicesId, promoCodeId: promoCodeId)
    }
    
    func orderCreated() {
        OrdersRouter(presenter: self).setActiveOrder(animated: true)
    }
    
}

// MARK: - Cars
extension MainViewController {
    func handleCarsError(_ error: RCError) {
        errorView.isHidden = false
    }
    func showCarsLoading(_ isLoading: Bool) {
        if isLoading {
            errorView.isHidden = true
            loadingView.isHidden = false
            loadingView.startAnimating()
        } else {
            loadingView.stopAnimating()
            loadingView.isHidden = true
        }
    }
    func reloadCars() {
        presentationModel.getCars()
    }
}
