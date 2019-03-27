//
//  RegistrationRegistrationRouter.swift
//  avtolet
//
//  Created by Igor Tyukavkin on 28/03/2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

struct RegistrationRouter: Router {

    let storyboard: UIStoryboard = UIStoryboard(name: "Registration", bundle: nil)
    weak var presenter: UIViewController?


    func presentRegistration() {
        let vc = storyboard.instantiateInitialViewController()!
        presentModal(vc)
    }

    func showRegistration() {
        let vc = storyboard.instantiateViewController(withClass: RegistrationViewController.self)
        show(vc)
    }
    
    func setRegistration() {
        let vc = storyboard.instantiateViewController(withClass: RegistrationVC.self)
        set(vc)
    }
  

}
