//
//  FavoritePerformersVC.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 11/25/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit


class FavoritePerformersVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, FavoritePerformerCellDelegate {
    
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var tableView: UITableView!
    var tariff: String?
    var collectionDataSource = [CarType]()
    var tableDataSource = [Favorite_performers]()
    var cells = [CarTypeCell]()
    override func viewDidLoad() {
        super.viewDidLoad()
        getFavorites()
        fillInCollectionDataSource()
        
    }
    
    func fillInCollectionDataSource(){
        let econom = CarType(name: "Эконом", image: UIImage(imageLiteralResourceName: "Эконом"))
        let comfort = CarType(name: "Комфорт", image: UIImage(imageLiteralResourceName: "Комфорт"))
        let universal = CarType(name: "Универсал", image: UIImage(imageLiteralResourceName: "Универсал"))
        let minivan = CarType(name: "Минивэн", image: UIImage(imageLiteralResourceName: "Минивэн"))
        let business = CarType(name: "Бизнес", image: UIImage(imageLiteralResourceName: "Бизнес"))
        let vip = CarType(name: "VIP", image: UIImage(imageLiteralResourceName: "VIP"))
        let driver = CarType(name: "Трезвый водитель", image: UIImage(imageLiteralResourceName: "Трезвый водитель"))
        collectionDataSource.append(econom)
        collectionDataSource.append(comfort)
        collectionDataSource.append(universal)
        collectionDataSource.append(minivan)
        collectionDataSource.append(business)
        collectionDataSource.append(vip)
        collectionDataSource.append(driver)
    }
    
    func getFavorites(){
        NetworkRequests.shared.getRequest(url: host + getFavoritePerformersPath + "?" + AvtoletService.shared.getToken(), parameters: [:]) { (response) in
            switch (response.result){
            case .success(_):
                do {
                    let favoritesResponse = try JSONDecoder().decode(FavoritesResponse.self, from: response.data!)
                    for favorite in favoritesResponse.favorite_performers {
                    
                        self.tableDataSource.append(favorite)
                    }
                    self.tableView.reloadData()
                }
                catch let error {print(error)}
            case .failure(_):
                break
            }
        }
    }
    

    //#MARK:- COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
  
        
        let cell = collectionView.cellForItem(at: indexPath) as! CarTypeCell
        tariff = cell.carNameLabel.text
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
        return cell.fillWithCar(carType: collectionDataSource[indexPath.row])
    }
    
    //#MARK:- TABLE VIEW
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 172
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tariff != nil{
        var index = 0
        for favorite in tableDataSource {
            if favorite.tariff_name == tariff{
                index = index + 1
            }
            
        }
        return index
        }else{
            return tableDataSource.count
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! FavoritePerformerCell
        cell.delegate = self
        if tariff != nil{
        var filtered = tableDataSource.filter{ $0.tariff_name == tariff}
        return cell.fillWithDataSource(favorite: filtered[indexPath.row])
        }else{
            return cell.fillWithDataSource(favorite: tableDataSource[indexPath.row])
        }
    }
    func didTapReMoveFavorite(performer_id: Int) {
        NetworkRequests.shared.postRequest(url: host + deleteFavoritePerformerPath + "?" + AvtoletService.shared.getToken(), parameters: ["performer_id": performer_id]) { (dic) in
            self.tableDataSource = self.tableDataSource.filter{$0.performer_id != performer_id}
            self.tableView.reloadData()
        }
    }
    
    @IBAction func didTapBack(_ sender: UIButton) {
        MainRouter(presenter: self).showMainVC()
    }
    
    
}

struct CarType {
    let name: String
    let image: UIImage
}

struct FavoritesResponse: Decodable{
    let status: String
    let favorite_performers: [Favorite_performers]
}

struct Favorite_performers: Decodable {
    let performer_id:Int
    let full_name: String
    let status: String
    let mark: String
    let model: String
    let color_car: String
    let state_number: String
    let rating: String
    let tariff_name: String
    let transportation_tariff_id: Int
//    let distance: String
}
