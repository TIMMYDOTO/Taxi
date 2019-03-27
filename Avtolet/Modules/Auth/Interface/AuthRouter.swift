//
//  AuthAuthRouter.swift
//  avtolet
//
//  Created by Igor Tyukavkin on 26/03/2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

struct AuthRouter: Router {

    let storyboard: UIStoryboard = UIStoryboard(name: "Auth", bundle: nil)
    weak var presenter: UIViewController?


    func presentAuth() {
        let vc = storyboard.instantiateInitialViewController()!
        presentModal(vc)
    }

    func showLaunchVC() {
        let vc = storyboard.instantiateViewController(withClass: LaunchVC.self)
        show(vc)
    }
    
//    func showAuth() {
//        let vc = storyboard.instantiateViewController(withClass: AuthViewController.self)
//        show(vc)
//    }
//    
//    func showConfirmCode(phone: String) {
//        let vc = storyboard.instantiateViewController(withClass: AuthViewController.self)
//        vc.state = .confirmCode
//        vc.phone = phone
//        show(vc)
//    }
//    
//    func setAuth() {
//        let vc = storyboard.instantiateViewController(withClass: AuthViewController.self)
//        show(vc)
//    }
    
    func showOfferta() {
        guard let url = URL(string: kDogovorOfertaLink) else { return }
        let vc = OfertaViewController(url: url)
        show(vc)
    }

}
