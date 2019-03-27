//
//  SideMenuVC.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 10/23/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
class SideMenuVC: UIViewController {

    @IBOutlet var photoImageView: UIImageView!
    
    @IBOutlet var userNameLabel: UILabel!
    
    
    var secondPhoneNumber: String!
    
    var phoneString: String!
    var nameString: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuContent()
        
        
    }
    func setupMenuContent(){
        let activityIndicator = UIActivityIndicatorView()
       
        activityIndicator.startAnimating()
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.center = CGPoint(x:photoImageView.frame.width/2,
                                                    y: photoImageView.frame.height/2)
        let overlay = UIView()
        overlay.frame = UIScreen.main.bounds
        overlay.backgroundColor = UIColor.black
        overlay.alpha = 0.66
        self.view.addSubview(overlay)
        
        
        
        photoImageView.addSubview(activityIndicator)
        
        
        let photoURl = URL(string: host + getPhotoPath + "?" + AvtoletService.shared.getToken())
   
        photoImageView.sd_setImage(with: photoURl) { (img, error, type, url) in
            activityIndicator.removeFromSuperview()
            overlay.removeFromSuperview()
        }
        
        
        let url = URL(string: host + getInfoPath + "?" + AvtoletService.shared.getToken())
        
        Alamofire.request(url!)
            .responseJSON { (response:DataResponse<Any>) in
                switch(response.result) {
                case .success(_):
                    print(response)
                    let responseDict = response.result.value as! NSDictionary
                    self.userNameLabel.text = responseDict["name"] as? String
                    self.userNameLabel.sizeToFit()
                    self.secondPhoneNumber = responseDict["second_phone_number"] as? String
                    self.phoneString = responseDict["phoneNumber"] as? String
                    self.nameString = responseDict["name"] as? String
                    break
                    
                case .failure(_):
                    
                    break
                }
        }

        

        
    }
            
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfile" {
            let profileVC = segue.destination as! ProfileVC
            if photoImageView.image != nil { profileVC.profilePicture = photoImageView.image! }
            profileVC.secondPhoneNumber = secondPhoneNumber
            profileVC.nameString = nameString
            profileVC.phoneString = phoneString
        }
       
    }
    

    
    @IBAction func paymentsMethodClicked(_ sender: UIButton) {
//        PayRouter(presenter: self).showPay()
        let storyboard = UIStoryboard(name: "Pay", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PaymentMethodsVC") as! PaymentMethodsVC
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func favoritesClicked(_ sender: UIButton) {
    }
    
    @IBAction func supportClicked(_ sender: UIButton) {
        ChatRouter(presenter: self).showSupportHistory()
    }
    
    @IBAction func exitClicked(_ sender: UIButton) {

        AvtoletService.shared.removeToken()
        AuthRouter(presenter: self).showLaunchVC()
        
    }
    
}
