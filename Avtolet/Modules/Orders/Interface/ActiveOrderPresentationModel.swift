//
//  ActiveOrderPresentationModel.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 30.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

class ActiveOrderPresentationModel: PresentationModel {

    let manager = OrderManager()
    
    fileprivate(set) var order: Order = User.current.activeOrder! {
        didSet {
            self._performers = order.performers
        }
    }
    fileprivate var _performers: [OrderPerformer]? = User.current.activeOrder!.performers {
        didSet {
            if performers?.count == 1 && needHandleFirstPerformer {
                firstPerformerhandler?()
                needHandleFirstPerformer = false
            } else if performers?.count == 0 {
                needHandleFirstPerformer = true
            }
        }
    }
    var needHandleFirstPerformer = true
    var performers: [OrderPerformer]? {
        return _performers?.filter({ $0.performer != nil })
    }
    let orderUpdateStatuses: [NotificationAction] = [.performerCompletedOrder, .statusPerformerChanged, .locationPerformerChanged, .newPerformer]
    
    let reachability = NetworkReachabilityManager()
    
    var cancelOrderHandler: (() -> ())?
    var showAlertHandler: ((String) -> ())?
    var nearbyPerformersUpdated: (([NearbyPerformer]) -> ())?
    var orderUpdated: (() -> ())?
    var closeCurrentOrderHandler: (() -> ())?
    var firstPerformerhandler: (() -> ())?
    var needReviewPerformer: ((OrderPerformer) -> ())?
    var openDialog: ((OrderPerformer) -> ())?
    
    let disposeBag = DisposeBag()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        reachability?.stopListening()
    }
    
    required init(errorHandler: ErrorHandler?) {
        super.init(errorHandler: errorHandler)
        observeNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.getActiveOrder), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        reachability?.startListening()
        reachability?.listener = { [weak self] status in
            if self?.reachability?.isReachable ?? false {
                self?.getActiveOrder()
            }
        }
    }
    
    func cancelOrder(reason: String) {
        loadingHandler?(true)
        guard let orderId = order.orderId else { return }
        manager.cancelOrder(orderId: orderId, reason: reason).done { [weak self] (error) in
            self?.loadingHandler?(false)
            if let error = error {
                self?.showAlertHandler?(error)
            } else {
                User.updateOrderInfo(order: nil)
                self?.cancelOrderHandler?()
            }
        }.catch { [weak self] (_) in
            self?.loadingHandler?(false)
            self?.errorHandler?(RCError.incorrectData)
        }
    }
    
    func getNearbyPerformers() {
        guard let origin = order.routeData?.originLocation else { return }
        manager.getNearbyPerformers(origin: origin).done { [weak self] (performers) in
             self?.nearbyPerformersUpdated?(performers)
        }.catch { (_) in }
    }
    
    func observeNotifications() {
        PushNotificationsService.shared.notificationShowOptionsHandler.asObservable().subscribe(onNext: {[weak self] (tuple) in
            guard let `self` = self else { return }
            guard let tuple = tuple else { return }
            guard let notification = Notification.create(userInfo: tuple.userInfo) else { return }
            guard let action = notification.payload?.action else { return }
            guard self.orderUpdateStatuses.contains(action) else { return }
            self.handleNotification(notification: notification)
            tuple.handler?( action == .locationPerformerChanged ? [] : [.sound, .badge, .alert])
        }).disposed(by: disposeBag)
        PushNotificationsService.shared.notificationInteractionHandler
            .asObservable()
            .subscribe(onNext: { [weak self] (handler) in
                guard let `self` = self else { return }
                guard let result = handler?() else { return }
                if result.type == .default {
                    guard let notification = Notification.create(userInfo: result.userInfo),
                        notification.payload?.action == .newMessage else { return }
                    guard let userId = notification.payload?.userId,
                    let performer = self.performers?.filter({ $0.performer?.id == userId }).first else { return }
                    self.openDialog?(performer)
                }
            }).disposed(by: disposeBag)
    }
    
    fileprivate func handleNotification(notification: Notification) {
        guard let action = notification.payload?.action else { return }
        switch action {
        case .newPerformer, .locationPerformerChanged, .statusPerformerChanged:
            guard let performers = notification.payload?.performers else { return }
            var order = self.order
            order.update(performers: performers)
            self.order = order
            self.orderUpdated?()
        case .performerCompletedOrder:
            guard let performer = notification.payload?.performers?.filter({ $0.performer?.id == notification.payload?.performer?.id }).first else { return }
            AvtoletService.shared.addPerformerToReview(performer: performer)
            self.needReviewPerformer?(performer)
        default:()
        }
    }
    
    @objc func getActiveOrder() {
        manager.getActiveOrder().done { [weak self] (order) in
            if let order = order {
                self?.order = order
                self?.orderUpdated?()
            } else {
                self?.closeCurrentOrderHandler?()
            }
        }.catch { (_) in }
    }
    
}
