//
//  RegistrationVC.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 10/19/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftPhoneNumberFormatter
class RegistrationVC: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
   
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var userNameData: UITextField!
    
    @IBOutlet var userNameLineImgView: UIImageView!
    @IBOutlet var email: UITextField!
    
    @IBOutlet var emailLineImgView: UIImageView!
    @IBOutlet weak var phone: PhoneFormattedTextField!{
        willSet{
            newValue.config.defaultConfiguration = PhoneFormat(defaultPhoneFormat: "+7 (###) ###-##-##")
        }
    }
    
    @IBOutlet var phoneLineImgView: UIImageView!
    @IBOutlet var password: UITextField!
    
    @IBOutlet var passwordLineImgView: UIImageView!
    
    
    @IBOutlet var sex: UITextField!
    
    @IBOutlet var photo: UIButton!
    @IBOutlet var dateField: UITextField!
    
    @IBOutlet var chossedPasswordIsWeakView: UIView!
    var imagePicker = UIImagePickerController()
    var sexDataSource:[String]!
    override func viewDidLoad() {
        super.viewDidLoad()
        sexDataSource = ["M", "F"]
     
        
        settingViews()
     
    }

    
    func settingViews(){

        
//        scrollView.updateContentView()
        
      self.hideKeyboard()
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.addTarget(self, action: #selector(RegistrationVC.datePickerValueChanged(sender:)), for: .valueChanged)
        
        dateField.inputView = datePicker
        
        
        let sexPicker = UIPickerView()
        sexPicker.dataSource = self
        sexPicker.delegate = self
        sex.inputView = sexPicker
        
    }
    
    

    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email.text ??  "")
    }
    
    func isValidPassword() -> Bool {
        let passwordRegex = "(?:(?:(?=.*?[0-9])(?=.*?[-!@#$%&*ˆ+=_])|(?:(?=.*?[0-9])|(?=.*?[A-Z])|(?=.*?[-!@#$%&*ˆ+=_])))|(?=.*?[a-z])(?=.*?[0-9])(?=.*?[-!@#$%&*ˆ+=_]))[A-Za-z0-9-!@#$%&*ˆ+=_]{6,15}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return emailTest.evaluate(with: password.text ?? "")
    }
  @objc  func datePickerValueChanged(sender: UIDatePicker) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
     dateFormatter.dateFormat = "yyyy-MM-dd"
    dateField.text = dateFormatter.string(from: sender.date)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sexDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sexDataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        sex.text = sexDataSource[row]
    }
    
    @IBAction func takePhotoClicked(_ sender: Any) {
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
   
       photo.setBackgroundImage(image, for: .normal)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backClicked(_ sender: UIButton) {
        AuthRouter(presenter: self).showLaunchVC()
    }
    
    @IBAction func buttonTakePhotoClicked(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: {
            picker.navigationBar.topItem?.rightBarButtonItem?.tintColor = UIColor(red: 254, green: 146, blue: 1)
        })
    }
    @IBAction func continueClicked(_ sender: UIButton) {
        let decimalCharacters = CharacterSet.decimalDigits
        let decimalRange = userNameData.text?.rangeOfCharacter(from: decimalCharacters)
        
        if isValidEmail() && isValidPassword() && phone.text?.count == 18 && decimalRange == nil{
            print("both valid")
            
            var numberWOSeven = phone.text?.digits
            numberWOSeven = "8" + String((numberWOSeven?.dropFirst())!)
            let parameters: Parameters = [
                "name": userNameData.text ?? "",
                "email": email.text ?? "" ,
                "phone_number": numberWOSeven ?? "",
                "sex": sex.text ?? "",
                "birth_day": dateField.text ?? "",
                "password": password.text ?? ""
                
            ]
            let image = photo.backgroundImage(for: .normal)
            let imageData = UIImagePNGRepresentation(image!)


            Alamofire.upload(
                multipartFormData: { multipartFormData in

                    for (key, value) in parameters{
                        print("data", value)
                 
                        if let v = value as? String, let valueAsData = v.data(using: .utf8) {
                            multipartFormData.append(valueAsData, withName: key )
                        }

                    }
                    multipartFormData.append(imageData!, withName: "image", fileName:"image.png", mimeType:"image/png")
          
            },
             
                to: host + registrationPath,
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.uploadProgress(closure: { (Progress) in
                            print("Upload Progress: \(Progress.fractionCompleted)")
                        })

                        upload.responseJSON { response in
                            //self.delegate?.showSuccessAlert()
                            print(response.request)  // original URL request
                            print(response.response) // URL response
                            print(response.data)     // server data
                            print(response.result)   // result of response serialization
                            //                        self.showSuccesAlert()
                            //self.removeImage("frame", fileExtension: "txt")
                            
                            if let JSON = response.result.value as? NSDictionary {
                                print("JSON: \(JSON)")
                              
                                if JSON.object(forKey: "status") as! String == "success"{
                                     MainRouter(presenter: self).showMainVC()
                                }
                        
                            }
                        }
                    case .failure(let encodingError):
                        print(encodingError)

                    }
            }
    )


        }
        if decimalRange != nil{
            userNameLineImgView.image = #imageLiteral(resourceName: "redLine")
        }else {userNameLineImgView.image = #imageLiteral(resourceName: "Line")}
        if !isValidEmail(){
            emailLineImgView.image = #imageLiteral(resourceName: "redLine")
            print("email invalid")
        }else {emailLineImgView.image = #imageLiteral(resourceName: "Line")}
        if !isValidPassword(){
            passwordLineImgView.image = #imageLiteral(resourceName: "redLine")
          
        }else{passwordLineImgView.image = #imageLiteral(resourceName: "Line")}
        if (phone.text?.count)! < 17{
            phoneLineImgView.image = #imageLiteral(resourceName: "redLine")
        }else{phoneLineImgView.image = #imageLiteral(resourceName: "Line")}
    }
    
}
extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}
extension UIScrollView {
    func updateContentView() {
        contentSize.width = UIScreen.main.bounds.size.width
        contentSize.height = subviews.sorted(by: { $0.frame.maxY < $1.frame.maxY }).last?.frame.maxY ?? contentSize.height + 30
    }
}
