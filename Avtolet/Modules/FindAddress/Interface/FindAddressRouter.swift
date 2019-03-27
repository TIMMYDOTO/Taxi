//
//  FindAddressFindAddressRouter.swift
//  avtolet
//
//  Created by Igor Tyukavkin on 29/03/2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

struct FindAddressRouter: Router {

    let storyboard: UIStoryboard = UIStoryboard(name: "FindAddress", bundle: nil)
    weak var presenter: UIViewController?


//    func presentFindAddress(addressSelected: ((SearchAddress) -> ())?) {
//        let vc = storyboard.instantiateInitialViewController() as! CommonNavigationController
//        let fvc = vc.topViewController as! FindAddressViewController
//        fvc.addressSelected = addressSelected
//        presentModal(vc)
//    }
//
//    func showFindAddress(addressSelected: ((SearchAddress) -> ())?) {
//        let vc = storyboard.instantiateInitialViewController() as! CommonNavigationController
//        let fvc = vc.topViewController as! FindAddressViewController
//        fvc.addressSelected = addressSelected
//        show(vc)
//    }
//    
//    func showMap(addressSelected: ((SearchAddress) -> ())?) {
//        let vc = storyboard.instantiateViewController(withClass: MapAddressViewController.self)
//        vc.addressSelected = addressSelected
//        show(vc)
//    }

}
