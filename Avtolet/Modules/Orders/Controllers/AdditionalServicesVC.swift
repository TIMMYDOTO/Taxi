//
//  AdditionalServicesVC.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 10/30/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class AdditionalServicesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var dataSource = [Service]()
    
    var transportation_tariffs_id: Int!
    var checkedExtraSevice = [Service]()
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        NetworkRequests.shared.getRequest(url: host + getExtraServicesPath + "?" + AvtoletService.shared.getToken(), parameters: ["transportation_tariffs_id":transportation_tariffs_id]) { (resp) in
            switch resp.result {
                
            case .success(_):
                do {
                    let extraServicesResponse = try JSONDecoder().decode([Service].self, from: resp.data!)
                    print("extraService ", extraServicesResponse)
                    for extraService in extraServicesResponse {
                        
                        self.dataSource.append(extraService)
                    }
                    self.tableView.reloadData()
                }
                catch let error {print(error)}
                break
                
            case .failure(_):
                
                break
                
            }
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AdditionalServicesCell
        if !cell.selectedBullet{
            cell.bulletImgView.image = UIImage(imageLiteralResourceName: "selected")
            checkedExtraSevice.append(dataSource[indexPath.row])
            cell.selectedBullet = true
        }else{
            cell.bulletImgView.image = UIImage(imageLiteralResourceName: "unselected")
            checkedExtraSevice = checkedExtraSevice.filter{ $0.name != cell.additionalServiceLabel.text}
            
            cell.selectedBullet = false
        }
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AdditionalServicesCell
        cell.bulletImgView.image = UIImage(imageLiteralResourceName: "unselected")
        cell.additionalServiceLabel.text = dataSource[indexPath.row].name
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! MainVC
        if checkedExtraSevice.count > 0{
        destVC.checkedExtraSevice = checkedExtraSevice
        destVC.bulletPoint.image = UIImage(imageLiteralResourceName: "selected")
        }else{
             destVC.checkedExtraSevice = nil
            destVC.bulletPoint.image = UIImage(imageLiteralResourceName: "unselected")
        }
    }

    @IBAction func backClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        //        MainRouter(presenter: self).showMainVC()
    }
}


struct Service: Codable {
    
    let id: Int
    let name: String
    let price: Int
    let available: Int
    let created_at: String
    let updated_at: String
    let transportation_tariff_id: Int
}
