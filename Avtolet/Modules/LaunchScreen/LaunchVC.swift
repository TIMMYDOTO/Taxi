//
//  LaunchVC.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 10/20/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class LaunchVC: UIViewController {
    @IBAction func registrationClicked(sender: UIButton){
        RegistrationRouter(presenter: self).setRegistration()
    }
}
