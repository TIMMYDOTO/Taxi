//
//  ReportVC.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 10/26/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import Alamofire


class ReportVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    @IBOutlet var topicTextField: UITextField!
    
    var pickedImage: UIImage?

    
    @IBOutlet var slotButton: UIButton!
    
    @IBOutlet var attachImageButton: UIButton!
    
    @IBOutlet var todayLabel: UILabel!{
        willSet{
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy год"
            newValue.text = formatter.string(from: date)
        }
    }
    
    @IBOutlet var topicView: UIView!
    
    @IBOutlet var messageTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()

    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Введите сообщение..." {
            textView.text = nil
         
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Введите сообщение..."
          
        }
    }
    
    @IBAction func attachImageClicked(_ sender: UIButton) {
        attachImage()
      
    }
    
    func attachImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: {
            picker.navigationBar.topItem?.rightBarButtonItem?.tintColor = UIColor(red: 254, green: 146, blue: 1)
        })
    }
      //MARK: - Collection view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        slotButton.setBackgroundImage(pickedImage, for: .normal)
        self.dismiss(animated: true, completion: nil)
    }
 
    
    //MARK: - Send a report
    @IBAction func sendReportClicked(_ sender: UIButton) {
        if !(topicTextField.text?.isEmpty)! && !(messageTextView.text?.isEmpty)!{
            LoadingIndicator.shared.showActivity(viewController: self)
            let parameters: Parameters = [
                "topic": topicTextField.text!,
                "text": messageTextView.text!
            ]
   
            
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    
                    for (key, value) in parameters{
                        print("data", value)
                        
                        if let v = value as? String, let valueAsData = v.data(using: .utf8) {
                            multipartFormData.append(valueAsData, withName: key )
                        }
                        
                    }
                    if self.pickedImage != nil{
                        multipartFormData.append(UIImagePNGRepresentation(self.pickedImage!)!, withName: "image", fileName:"image.png", mimeType:"image/png")
                      
                    }
                    
            },
                
                to: host + registerReport + "?" + AvtoletService.shared.getToken(),
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.uploadProgress(closure: { (Progress) in
                            print("Upload Progress: \(Progress.fractionCompleted)")
                        })
                        
                        upload.responseJSON { response in
                          
                            print(response.result)   // result of response serialization
                            
                            if let JSON = response.result.value as? NSDictionary {
                                print("JSON: \(JSON)")
                                
                                if JSON.object(forKey: "status") as? String == "success"{
                                    LoadingIndicator.shared.hideActivity()
                                    ChatRouter(presenter: self).showSupportHistory()
                                    
                                }
                                
                            }
                        }
                    case .failure(let encodingError):
                        print(encodingError)
                        
                    }
            }
            )
            
        }
        if (topicTextField!.text?.isEmpty)! {
           topicView.layer.borderColor = UIColor.red.cgColor
            topicView.layer.borderWidth = 1.3
        }else{
             topicView.layer.borderWidth = 0.0
        }
        if messageTextView!.text.isEmpty || messageTextView.text == "Введите сообщение..."{
            messageTextView.layer.borderColor = UIColor.red.cgColor
            messageTextView.layer.borderWidth = 1.3
        }else{
            messageTextView.layer.borderWidth = 0.0
        }
        
    }
    
}
