//
//  ChatViewController.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 28.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class ChatViewController: CommonViewController {

    @IBOutlet weak var jivoView: UIWebView!
    
    var jivoSDK: JivoSdk?
    
    let langKey = "ru"
    
    deinit {
        jivoSDK?.stop()
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Служба поддержки"
        jivoSDK = JivoSdk.init(self.jivoView, self.langKey)
        jivoSDK?.delegate = self
        jivoSDK?.prepare()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        jivoSDK?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        jivoSDK?.stop()
    }
    
    @IBAction func closeAction() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func callAction() {
        guard let url = URL(string: "tel://"+kSupportPhone) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}

extension ChatViewController: JivoDelegate {
    func showLoading() {
        showHUD()
    }
    
    func hideLoading() {
        hideHUD()
    }
    
    func onEvent(_ name: String!, _ data: String!) {
        if name.lowercased() == "url.click" {
            let data = NSString(string: data)
            if data.length > 2 {
                let urlString = data.substring(with: NSMakeRange(1, data.length - 2))
                guard let url = URL(string: urlString) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else if name.lowercased() == "chat.ready" {
            let user = User.current
            guard let name = user.name, let phone = user.phone else { return }
            let contactInfo = "{\"client_name\": \"\(name)\", \"phone\": \"\(phone)\"}"
            jivoSDK?.callApiMethod("setContactInfo", contactInfo)
        }
    }
}
