//
//  OrdersOrdersRouter.swift
//  avtolet
//
//  Created by Igor Tyukavkin on 30/03/2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

struct OrdersRouter: Router {

    let storyboard: UIStoryboard = UIStoryboard(name: "Orders", bundle: nil)
    weak var presenter: UIViewController?


    func setActiveOrder(animated: Bool) {
        let vc = storyboard.instantiateViewController(withClass: ActiveOrderViewController.self)
        set(vc, animated: animated)
    }

    func showAdditionalServices(){
        let vc = storyboard.instantiateViewController(withClass: AdditionalServicesVC.self)
        show(vc)
    }
    
    func showOrder(shortOrder: ShortOrder, state: MyOrdersState) {
        let vc = storyboard.instantiateViewController(withClass: OrderViewController.self)
        vc.order = shortOrder
        vc.state = state
        show(vc)
    }
    
    func presentActiveOrder(order: Order, canCancelOrder: Bool, cancelHandler: ((String) ->())?) {
        let vc = storyboard.instantiateViewController(withClass: OrderViewController.self)
        vc.activeOrder = order
        vc.state = .active
        vc.cancelHandler = cancelHandler
        vc.canCancelOrder = canCancelOrder
        let navVC = CommonNavigationController(rootViewController: vc)
        presentModal(navVC)
    }
    
    func presentReview(performer: OrderPerformer, orderId: Int, orderCompletedHandler: ((Bool) -> ())?) {
        let vc = storyboard.instantiateViewController(withClass: OrderViewController.self)
        vc.performer = performer
        vc.orderId = orderId
        vc.state = .review
        vc.workAccepted = orderCompletedHandler
        let navVC = CommonNavigationController(rootViewController: vc)
        presentModal(navVC)
    }
}
