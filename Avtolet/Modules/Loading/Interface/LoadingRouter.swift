//
//  LoadingLoadingRouter.swift
//  avtolet
//
//  Created by Igor Tyukavkin on 28/03/2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

struct LoadingRouter: Router {

    let storyboard: UIStoryboard = UIStoryboard(name: "Loading", bundle: nil)
    weak var presenter: UIViewController?


    func presentLoading() {
        let vc = storyboard.instantiateInitialViewController()!
        presentModal(vc)
    }

    func showLoading() {
        let vc = storyboard.instantiateInitialViewController()!
        show(vc)
    }
    
    func setLoading() {
        let vc = storyboard.instantiateInitialViewController()!
        set(vc)
    }

}
