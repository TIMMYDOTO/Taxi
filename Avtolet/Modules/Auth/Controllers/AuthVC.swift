//
//  AuthVC.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 10/19/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import SwiftPhoneNumberFormatter
import Alamofire

class AuthVC: UIViewController {
    
    @IBOutlet var numberTextField: PhoneFormattedTextField!{
        willSet{
            newValue.config.defaultConfiguration = PhoneFormat(defaultPhoneFormat: "+7 (###) ###-##-##")
        }
    }
    @IBOutlet var numberLineImgView: UIImageView!
    
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var passwordLineImgView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
   
    }
    
    
    
    @IBAction func continueClicked(_ sender: UIButton) {
        LoadingIndicator.shared.showActivity(viewController: self)
        var numberWOSeven = numberTextField.text?.digits
        numberWOSeven = "8" + String((numberWOSeven?.dropFirst())!)
        let parameters: Parameters = [
            "phone_number": "891339000533",//numberWOSeven ?? "891339000533",
            "password": "1111"]//passwordTextField.text ?? "1111" ]
        
        Alamofire.request(URL(string: host + authPath)!, method: .post, parameters: parameters).responseJSON { (responce) in
            print(responce)
            LoadingIndicator.shared.hideActivity()
            if responce.response?.statusCode == 200{
                let responceDict = responce.result.value as! NSDictionary
            
                let token = responceDict["token"] as! String
              
                AvtoletService.shared.setToken(token: token)
                
                MainRouter(presenter: self).showMainVC()
            }
        }
        
    }
    @IBAction func didTapBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
