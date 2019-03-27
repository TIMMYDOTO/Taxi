//
//  ProfileVC.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 10/24/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftPhoneNumberFormatter
import SDWebImage
class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    

    
    
    @IBOutlet var nameLabel: UILabel!{
        willSet{
           newValue.text = nameString
        }
    }
    @IBOutlet var phoneLabel: UILabel!{
        willSet{
            newValue.text = phoneString
        }
    }
    
    @IBOutlet var phoneField: PhoneFormattedTextField!{
        willSet{
            newValue.config.defaultConfiguration = PhoneFormat(defaultPhoneFormat: "+7 (###) ###-##-##")
        }
    }
    @IBOutlet var profileImgView: UIImageView!
    var nameString = String()
    var phoneString = String()
    var profilePicture = UIImage()
    var secondPhoneNumber: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
    }
    
    
    
    func setupViews(){
       
        profileImgView.image = profilePicture
        self.hideKeyboard()
        if secondPhoneNumber != nil{
            phoneField.text = secondPhoneNumber
        }
        
        
    }
    
    @IBAction func editProfilePicture(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
       
        self.present(picker, animated: true, completion: {
            picker.navigationBar.topItem?.rightBarButtonItem?.tintColor = UIColor(red: 254, green: 146, blue: 1)
        })
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //selected image
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        profileImgView.image = image
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func addPhoneNumberClicked(_ sender: UIButton) {
        var numberWOSeven = phoneField.text?.digits
        numberWOSeven = "8" + String((numberWOSeven?.dropFirst())!)
        let parameters: Parameters = [
            "second_phone_number": numberWOSeven!,
            "token": AvtoletService.shared.getToken()]
        
        Alamofire.request(URL(string: host + editInfoPath)!, method: .post, parameters: parameters).responseString { (responce) in
            print(responce)
            print(responce.response?.statusCode)
            if responce.response?.statusCode == 200{
                let responceDict = responce.result.value as! NSDictionary
                
            }
        }
        
        
    }
    
    
    @IBAction func closeClicked(_ sender: UIButton) {
        MainRouter(presenter: self).showMainVC()
        
    }
    
    @IBAction func goToSupportScreen(_ sender: UIButton) {
        ChatRouter(presenter: self).showSupportHistory()
    }
    
    
    @IBAction func saveChangesClicked(_ sender: UIButton) {
        
        if profileImgView.image != nil {
            
      LoadingIndicator.shared.showActivity(viewController: self)
        let imageData = UIImagePNGRepresentation(profileImgView.image!)!
        Alamofire.upload(
            
            multipartFormData: { multipartFormData in
                
                
                multipartFormData.append(imageData, withName: "image", fileName:"image.png", mimeType:"image/png")
              
        },
            
            to: host + setPhotoPath + "?" + AvtoletService.shared.getToken(),
            encodingCompletion: { encodingResult in
              
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress(closure: { (Progress) in
                        print("Upload Progress: \(Progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON { response in
                          LoadingIndicator.shared.hideActivity()
                        print(response.request)  // original URL request
                        print(response.response) // URL response
                        print(response.data)     // server data
                        print(response.result)   // result of response serialization
                        
                        
                        if let JSON = response.result.value as? NSDictionary {
                            print("JSON: \(JSON)")
                            
                            if JSON.object(forKey: "status") as! String == "success"{
                                MainRouter(presenter: self).showMainVC()
                                SDImageCache.shared().clearMemory()
                                SDImageCache.shared().clearDisk()
                            }
                            
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                    
                }
        }
        )
        
    }
      }
    
    
}
