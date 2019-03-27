//
//  SupportChatVC.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 10/28/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import Alamofire
import XLMediaZoom
class SupportChatVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChatToViewCellProtocol, ChatFromViewCellProtocol{
  
    
    
    @IBOutlet var answerTextField: UITextField!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var topicLabel: UILabel!
    @IBOutlet var checkedLabel: UILabel!
    var identifier: String!
    
    var dataSource = [Answer]()
    @IBOutlet var attachImageButton: UIButton!
    var count = Int()
    
    var pickedImage: UIImage?
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        
        getChatReport()
        Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(getChatReport), userInfo: nil, repeats: true)
        
        
    }
    
    func didTapAttachment(attachment: UIImageView){
        let mediaZoom = XLMediaZoom(animationTime: 0.5, image: attachment, blurEffect: false)
        
        view.addSubview(mediaZoom!)
        mediaZoom!.show()
    }
    func didTapAttachment(attachement: UIImageView) {
        let mediaZoom = XLMediaZoom(animationTime: 0.5, image: attachement, blurEffect: false)
        
        view.addSubview(mediaZoom!)
        mediaZoom!.show()
    }
    
    @objc func getChatReport() {
        NetworkRequests.shared.getRequest(url: host + getInfoReportPath + "?" + AvtoletService.shared.getToken() + "&report_id=" + identifier, parameters: [:]) { (resp) in
            switch resp.result{
                
            case .success(_):
                do {
                    let reportInfo = try JSONDecoder().decode(ReportInfo.self, from: resp.data!)
                    self.topicLabel.text = reportInfo.report.report.topic
                    if reportInfo.report.report.checked == 1{
                        self.checkedLabel.text = "Обращение закрыто"
                        self.checkedLabel.textColor = UIColor(red: 254, green: 146, blue: 1)
                        self.tableView.frame = CGRect(x: 0,
                                                      y: self.tableView.frame.origin.y,
                                                      width: self.view.frame.width,
                                                      height: self.view.frame.height-self.tableView.frame.origin.y-12)
                        self.view.bringSubview(toFront: self.tableView)
                    }
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    
                    guard let date = dateFormatter.date(from: reportInfo.report.report.date) else {
                        return
                    }
                    
                    dateFormatter.dateFormat = "dd.MM.yyyy год"
                    let stringFromDate = dateFormatter.string(from: date)
                    self.dateLabel.text = stringFromDate
                    self.dataSource.removeAll()
                    for answer in reportInfo.report.report.answers{
                        self.dataSource.append(answer)
                    }
                    if self.count < self.dataSource.count{
                        self.tableView.reloadData()
                         self.tableView.scrollToBottom()
                       
                    }
                    self.count = self.dataSource.count
                    
                    
                    
                }
                catch let error {print(error)}
            case .failure(_):
                break
            }
            
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        attachImageButton.setBackgroundImage(pickedImage, for: .normal)
        attachImageButton.setTitle("", for: .normal)
        self.dismiss(animated: true, completion: nil)
    }
    
    //#MARK:- TABLE VIEW
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataSource[indexPath.row].account_type == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "chatFromViewCell", for: indexPath) as! ChatFromViewCell
            cell.delegate = self
            return cell.fillWithAnswer(answer: dataSource[indexPath.row])
            
        }
        if dataSource[indexPath.row].account_type == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "chatToViewCell", for: indexPath) as! ChatToViewCell
            cell.delegate = self
            return cell.fillWithAnswer(answer: dataSource[indexPath.row])
        }
        return UITableViewCell()
        
    }
    
    //#MARK:- BUTTON ACTIONS
    @IBAction func sendChatMessage(_ sender: UIButton) {
        
        let parameters:Parameters!
        parameters = ["reports_id": Int(identifier)!,
                      "answer": answerTextField.text ?? ""]

        Alamofire.upload(
            multipartFormData: { multipartFormData in
                
                for (key, value) in parameters{
                    print("data", value)
                    
                    if value is String || value is Int{
                         multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                    }
                    
                }
                if self.pickedImage != nil{
                    multipartFormData.append(UIImagePNGRepresentation(self.pickedImage!)!, withName: "file", fileName:"image.png", mimeType:"image/png")
                    LoadingIndicator.shared.showActivity(viewController: self)
                    
                }
                
        },
            
            to: host + sendAnswerReportPath + "?" + AvtoletService.shared.getToken(),
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
                                 self.answerTextField.text = ""
                                self.attachImageButton.setBackgroundImage(nil, for: .normal)
                                self.attachImageButton.setTitle("paperclip", for: .normal)
                                self.getChatReport()
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


struct ReportInfo: Codable{
    let status: String
    let report: ReportChat
    
}
struct ReportChat: Codable {
    let report: Chat
}

struct Chat: Codable {
    let report_id: Int
    let account_type: Int
    let checked: Int
    let topic: String
    let date: String
    let text: String
    let patch_file: String
    let answers: [Answer]
    
}
struct Answer: Codable{
    let id: Int
    let report_id: Int
    let who_is_responsible: Int
    let answer: String
    let path_file: String
    let created_at: String
    let updated_at: String
    let account_type: Int
    let user_info: UserInfo
    
    
    
    
}
struct UserInfo: Codable{
    let id: Int
    let name: String?
    let full_name: String?
    
    let email: String?
    let position: String?
}
extension UITableView {
    func scrollToBottom(animated: Bool = false) {
        let section = self.numberOfSections
        if section > 0 {
            let row = self.numberOfRows(inSection: section - 1)
            if row > 0 {
                self.scrollToRow(at: NSIndexPath(row: row - 1, section: section - 1) as IndexPath, at: .bottom, animated: animated)
            }
        }
    }
}
