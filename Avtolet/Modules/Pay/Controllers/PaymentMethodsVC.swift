//
//  PaymentMethodsVC.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 11/2/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import Alamofire
import WebKit



class PaymentMethodsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, WKUIDelegate, WKNavigationDelegate, PayCellDelegate {
    
    
    var dataSource = [Card]()
    var parameters = Parameters()
    var webView: WKWebView!
    @IBOutlet var virtualBalanceLabel: UILabel!
    @IBOutlet var cardImageView: UIImageView!
    @IBOutlet var cashImageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var cashlessView: UIView!
    let activityIndicator = UIActivityIndicatorView()
    var paymentMethod: PaymentMethod?
    var paymentId = String()
    
    var cardId: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        showActivityIndicator()
        getVirtualBalance()
        cardId = UserDefaults.standard.object(forKey: "id") as? Int
        if cardId == -1{
            cashlessView.isHidden = false
            view.bringSubview(toFront: cashlessView)
            cardImageView.alpha = 0.3
            cashImageView.alpha = 1.0
        }
    }
    
    func showActivityIndicator() {
        tableView.isHidden = true
        activityIndicator.center = tableView.center
        activityIndicator.startAnimating()
        activityIndicator.activityIndicatorViewStyle = .gray
        tableView.addSubview(activityIndicator)
        
    }
    
    func getVirtualBalance() {
        NetworkRequests.shared.getRequest(url: host + getPaymentsMethodPath + "?" + AvtoletService.shared.getToken(), parameters: [:]) { (response) in
            switch (response.result){
            case .success(_):
                do{
                    let paymentResponse = try JSONDecoder().decode(PaymentsResponce.self, from: response.data!)
              
                    let balance = paymentResponse.client_current_balance / 100
                    self.virtualBalanceLabel.text = String(balance) + " руб"
                    
                    for card in paymentResponse.client_payment_methods{
                        self.dataSource.append(card)
                        
                    }
                    self.tableView.dataSource = self
                  
                    self.tableView.isHidden = false
                    self.activityIndicator.removeFromSuperview()
                    
                }
                catch let error { print (error) }
            case .failure(_):
                break
            }
        }
        
        
    }
    
    func didTapRemoveCard(card_Id: String) {
        
        NetworkRequests.shared.postRequest(url: host + removeCardPath + "?" + AvtoletService.shared.getToken(), parameters: ["card_id" : card_Id]) { (resp) in
        
            self.removeCard(card_Id: card_Id)
            self.tableView.reloadData()
            print(resp)
          
        }
    }
    
    func removeCard(card_Id: String) {
        dataSource = dataSource.filter { $0.card_id != card_Id }
    }
    
    func showWebView(url: URL) {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: view.frame, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        let request = URLRequest(url: url)
        let closeButton = UIButton(frame: CGRect(x: 12, y: 40, width: 35, height: 30))
        closeButton.addTarget(self, action: #selector(closeWebView), for: .touchUpInside)
        closeButton.tintColor = .black
        closeButton.setImage(UIImage(imageLiteralResourceName: "close-icon"), for: .normal)
        webView.load(request)
        
        webView.addSubview(closeButton)
        view.addSubview(webView)
        
    }
    
    @objc func closeWebView(){
        webView.removeFromSuperview()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if (webView.url?.absoluteString.contains("https://securepay.tinkoff.ru/html/payForm/success.html?Success=true"))! {
            
            parameters = ["payment_id": paymentId]
            print(parameters)
            NetworkRequests.shared.getRequest(url: host + paymentCheckConfirmationPath + "?" + AvtoletService.shared.getToken(), parameters: parameters) { (resp) in
              
                self.getVirtualBalance()
            }
            
            webView.removeFromSuperview()
            
            
        }
    }
    
    //#MARK: - TABLE VIEW
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PayCell
        
        if let paymentType = paymentType(rawValue: cell.paymentType) {
            switch paymentType{
            case .cash:
                
                break
            case .cashless:
                paymentMethod = PaymentMethod(id: cell.paymentType, cardId:Int(cell.card_id!), pan: String((cell.cardNumberLabel.text?.suffix(8))!))
                break
            case .virtual:
                paymentMethod = PaymentMethod(id: cell.paymentType, cardId:-2, pan: "")
                break
            }
        }
        
       
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PayCell
   
        if !dataSource.indices.contains(indexPath.row) {
            
            cell.cardImageView.image = UIImage(imageLiteralResourceName: "coins")
            cell.cardNumberLabel.text = "Оплата с виртуального счёта"
            cell.cardNumberLabel.sizeToFit()
            cell.removeCard.removeFromSuperview()
            cell.paymentType = 3
            
            
            if let data = UserDefaults.standard.value(forKey:"paymentMethod") as? Data {
                paymentMethod = try? PropertyListDecoder().decode(PaymentMethod.self, from: data)
                guard let cardId = cardId else {return UITableViewCell()}
                if  cardId == -2  {
                    let grayView = UIView(frame: CGRect(x:0, y:14.5, width: view.frame.width, height: 71))
                    grayView.backgroundColor = UIColor(red: 246, green: 248, blue: 248)
                    cell.contentView.addSubview(grayView)
                    cell.contentView.sendSubview(toBack: grayView)
                }
                
            }
            
            
            
            return cell
        }
        cell.delegate = self
        
        if let data = UserDefaults.standard.value(forKey:"paymentMethod") as? Data {
            paymentMethod = try? PropertyListDecoder().decode(PaymentMethod.self, from: data)
            guard let cardId = cardId else {return UITableViewCell()}
            if dataSource[indexPath.row].card_id == String(cardId)  {
                let grayView = UIView(frame: CGRect(x:0, y:14.5, width: view.frame.width, height: 71))
                grayView.backgroundColor = UIColor(red: 246, green: 248, blue: 248)
                cell.contentView.addSubview(grayView)
                cell.contentView.sendSubview(toBack: grayView)
            }
        }
      
      
        return cell.fillIn(with: dataSource[indexPath.row])
        
    }
    
    //MARK: - REST
    @IBAction func didTapOk() {
        if !cashlessView.isHidden{
            paymentMethod = PaymentMethod(id: 1, cardId: -1, pan: "")
            
        }
        if let paymentMeth = paymentMethod {
            
        UserDefaults.standard.set(try? PropertyListEncoder().encode(paymentMeth), forKey:"paymentMethod")

        }
        UserDefaults.standard.set(paymentMethod?.cardId, forKey: "id")
//         MainRouter(presenter: self).showMainVC()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        
    }
    
    @objc func didTapPay( ){
        print(#function)
    }
    
    @IBAction func addCardAction(_ sender: UIButton) {
        LoadingIndicator.shared.showActivity(viewController: self)
        parameters = ["amount": 100, "description": "Добавление новой карты", "recurrent" : "Y"]
        NetworkRequests.shared.postRequest(url: host + initPaymentPath + "?" + AvtoletService.shared.getToken(), parameters: parameters) { (resp) in
            LoadingIndicator.shared.hideActivity()
            let response = resp["response"] as? NSDictionary
            self.paymentId = response!["PaymentId"] as! String
            let url = URL(string: response?.value(forKey: "PaymentURL") as! String)
            
            if UIApplication.shared.canOpenURL(url!) {
                self.showWebView(url: url!)
                
            }
        }
    }
    
    func showDialog(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Пополнить", style: .default) { (_) in
            
            
            var money = Int(alertController.textFields?[0].text ?? "0") ?? 0
            money = money * 100
            
            LoadingIndicator.shared.showActivity(viewController: self)
            self.parameters = ["amount": money, "description" : "Пополнение виртуального баланса"]
            
            NetworkRequests.shared.postRequest(url: host + initPaymentPath + "?" + AvtoletService.shared.getToken(), parameters: self.parameters, onSuccess: { (resp) in
                
                let response = resp["response"] as? NSDictionary
                
                self.paymentId = response!["PaymentId"] as! String
                let url = URL(string: response?.value(forKey: "PaymentURL") as! String)
                LoadingIndicator.shared.hideActivity()
                if UIApplication.shared.canOpenURL(url!) {
                    self.showWebView(url: url!)
                }
            })
            
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "Сумма в рублях"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func addVirtualMoneyClicked(_ sender: RotatedButton) {
        showDialog(title: "Ввод суммы", message: "Пожалуйста, введите пополняемую сумму:")
    }
    
    @IBAction func cashlessPaymentAction(_ sender: UIButton) {
        cashlessView.isHidden = true
        cardImageView.alpha = 1.0
        cashImageView.alpha = 0.3
    }
    
    @IBAction func cashPaymentsAction(_ sender: UIButton) {
        cashlessView.isHidden = false
        view.bringSubview(toFront: cashlessView)
        cardImageView.alpha = 0.3
        cashImageView.alpha = 1.0
    }
    
    @IBAction func backClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    
    }
}


struct PaymentsResponce:Decodable {
    let status: String
    let client_current_balance: Int
    let client_payment_methods: [Card]
}


struct PaymentMethod: Codable{
    let id: Int
    let cardId: Int?
    let pan: String?
    
}


