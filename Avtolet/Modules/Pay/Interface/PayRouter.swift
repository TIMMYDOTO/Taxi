//
//  PayRouter.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 11/4/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit


struct PayRouter: Router{
    let storyboard: UIStoryboard = UIStoryboard(name: "Pay", bundle: nil)
    weak var presenter: UIViewController?
    
    
    
    func showPay() {
        let vc = storyboard.instantiateViewController(withClass: PaymentMethodsVC.self)
        show(vc)
    }
}
