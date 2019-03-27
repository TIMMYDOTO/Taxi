//
//  TariffVC.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 12/4/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit

class TariffVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    var collectionDataSource = [Tarif]()
    var tariff = "Эконом"
    
    @IBOutlet var footerLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var tableView: UITableView!
    var dataSouce = [TariffPresentModel]()
    var filtered = [TariffPresentModel]()
    var firstTariffAlpa = true
    
    var cells = [CarTypeCell]()
    override func viewDidLoad() {
        super.viewDidLoad()
        fillWithTariff()
    }
    
    
    func fillWithTariff() {
        NetworkRequests.shared.getRequest(url: host + getTariffsPath + "?" + AvtoletService.shared.getToken(), parameters: [:]) { (resp) in
            switch resp.result{
                
            case .success(_):
                do {
                    let tariffsResponce = try JSONDecoder().decode(TarrifsResponce.self, from: resp.data!)
                    for tarrif in tariffsResponce.tariffs{
                        if (UIImage(named: tarrif.name) != nil) {
                        self.collectionDataSource.append(tarrif)
                        
                        let tariffPresentModal = TariffPresentModel(tariff: tarrif)
                        self.dataSouce.append(tariffPresentModal)
                        }
                        
                    }
                    
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                }
                catch let error {print(error)}
            case .failure(_):
                break
            }
            
        }
        
    }
    //MARK:- UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let cell = collectionView.cellForItem(at: indexPath) as! CarTypeCell
        tariff = cell.carNameLabel.text!
        
        tableView.reloadData()
        for aCell in cells {
            if aCell == cell {
                aCell.alpha = 1.0
            }
            else {
                aCell.alpha = 0.3
            }
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CarTypeCell
        
        cells.append(cell)
        if firstTariffAlpa {
            cell.alpha = 1.0
            firstTariffAlpa = false
        }else{
            cell.alpha = 0.3
        }
        
        return cell.fillWithCar(tariff: collectionDataSource[indexPath.row])
    }
    
    //MARK:- UITableView
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 265
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if dataSouce.count > 0{
            return 1
        }else {
            return 0
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TariffCell
        
        filtered = dataSouce.filter{ $0.tariff_name == tariff}
        footerLabel.text = footerLabel.text?.replacingOccurrences(of: footerLabel.text?.digits ?? "0", with: String(filtered.first!.freeWaitingTime))
        
        return cell.fillInWithTariff(tariff: filtered.first!)
        
    }
    
    
    @IBAction func didTapBack(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
   
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let choosedTariff = filtered.first {
            let vc = segue.destination as! MainVC
            vc.tariff = choosedTariff
         
        }
    }
   
}
