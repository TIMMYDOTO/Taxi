//
//  SupportHistoryVC.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 10/25/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import Alamofire
class SupportHistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var supportTableView: UITableView!{
        willSet{
            newValue.separatorStyle = .none
            
        }
    }
    var dataSource = [Report]()
    override func viewDidLoad() {
        super.viewDidLoad()
        getReportsRequest()
 
    }
    
    func getReportsRequest(){
        let url = URL(string: host + getReportsPath + "?" + AvtoletService.shared.getToken())
        Alamofire.request(url!)
            .responseJSON { (response:DataResponse<Any>) in
                switch(response.result) {
                case .success(_):
                    do{
                        let webResponse = try JSONDecoder().decode(Responce.self, from: response.data!)
                        
                        self.dataSource = webResponse.reports
                        
                        if self.dataSource.count > 0 {
                        self.supportTableView.isHidden = false
                        self.supportTableView.reloadData()
                        }
                        
                    }
                    catch{ print("err") }
                    break
                    
                case .failure(_):
                    
                    break
                }
        }
    }
    
    
    //MARK: - Work with table
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 
        let selectedCell = tableView.cellForRow(at: indexPath) as! SupportHistoryCell
        
        
        ChatRouter(presenter: self).showSupportChat(identifier: selectedCell.identifier)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 117
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SupportHistoryCell
        return cell.fillWithReport(report: dataSource[indexPath.row])
    }

    @IBAction func closeClicked(_ sender: UIButton) {
        MainRouter(presenter: self).showMainVC()
    }
}

struct Responce:Decodable {
    let reports: [Report]
    let status: String
}
struct Report: Decodable {
    
    let checked: Int
    let report_id: Int
    let timestamp: String
    let topic: String

    
}

