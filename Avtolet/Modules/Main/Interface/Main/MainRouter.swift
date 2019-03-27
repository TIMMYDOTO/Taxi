//
//  MainMainRouter.swift
//  avtolet
//
//  Created by Igor Tyukavkin on 26/03/2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

struct MainRouter: Router {
    
    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    weak var presenter: UIViewController?
    
    func showMain() {
        let vc = storyboard.instantiateInitialViewController()!
        show(vc)
    }
    
    func setMain(animated: Bool) {
        let vc = storyboard.instantiateViewController(withClass: MainViewController.self)
        set(vc, animated: animated)
    }
    
    func showMainVC() {
        let vc = storyboard.instantiateViewController(withClass: MainVC.self)
        set(vc)
    }
    func showDestPoint() {
        let vc = storyboard.instantiateViewController(withClass: DestinationPointVC.self)
        set(vc)
    }
    func showMainVC(destPoint: String) {
        let vc = storyboard.instantiateViewController(withClass: MainVC.self)
        vc.destPoint = destPoint
        set(vc)
    }
    
    func showMainVC(tariff: TariffPresentModel) {
        let vc = storyboard.instantiateViewController(withClass: MainVC.self)
        vc.tariff = tariff
        set(vc)
    }
    
}

