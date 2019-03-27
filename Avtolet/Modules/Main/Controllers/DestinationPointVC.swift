//
//  DestinationPointVC.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 12/10/18.
//  Copyright © 2018 Artyom Schiopu. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
class DestinationPointVC: CommonViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate{
    
    @IBOutlet var toTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    var dataSource = [Adresses]()
    var count = Int()
    var text = ""
    var searchAddressUpdateHandler: (([SearchAddress]) -> ())?
    var addresses1 = [String]()
    
    lazy var locationService: LocationService = {
        let service = LocationService()
        service.delegate = self
        
        return service
    }()
    let client = GMSPlacesClient.shared()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toTextField.becomeFirstResponder()
        toTextField.addTarget(self, action: #selector(textDidChange(textField:)), for: .editingChanged)
    }
    
    @objc func textDidChange (textField: UITextField){
        
        
        if count < (textField.text?.count)! {
            obtainAddresses(withText: textField.text!.capitalized)
            
        }
        count = (textField.text?.count)!
    }
    
    func obtainAddresses(withText text: String) {
        
        self.text = text.trim()
        guard text.trim().count > 0 else { searchAddressUpdateHandler?([]) ; return }
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.address
        filter.country = "RU"
        let callback: GMSAutocompletePredictionsCallback = { [weak self] (results, _) in
            let addresses = results?.map({ SearchAddress(address: $0.attributedPrimaryText.string,
                                                         city: $0.attributedSecondaryText?.string) }) ?? []
            
            
            
            self?.searchAddressUpdateHandler?(addresses)
            self!.dataSource.removeAll()
            for address in addresses {
                self!.dataSource.append(Adresses.init(address: address.address, city: address.city ?? ""))
               
            }
            self!.tableView.reloadData()
            self?.addresses1 = self!.dataSource.map { $0.query }
        }
        if let userlocation = locationService.currentUserLocation {
            client.autocompleteQuery(text, bounds: GMSCoordinateBounds(coordinate: userlocation.coordinate, coordinate: userlocation.coordinate), boundsMode: GMSAutocompleteBoundsMode.bias, filter: filter, callback: callback)
        } else {
            client.autocompleteQuery(text, bounds: nil, filter: filter, callback: callback)
        }
        
    }
 
    //MARK:- TABLE VIEW

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        toTextField.text = cell?.textLabel?.text
        
        performSegue(withIdentifier: "unWindToMain", sender: self)

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row].query
        cell.detailTextLabel?.text = dataSource[indexPath.row].address
        cell.detailTextLabel?.isHidden = true

        return cell
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! MainVC

        destVC.destPoint = toTextField.text ?? ""
      
    }
    @IBAction func didTapBack(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension DestinationPointVC: LocationServiceProtocol{
    func didFailAuthorization() {
        
    }
    
    
    func didUpdateUserLocation(location: CLLocation) {}
}


struct Adresses {
    let address: String
    let city: String?
    
    var query: String {
        return address + (city != nil ? (", " + city!.components(separatedBy: ",").first!) : "")
    }
    init(address: String, city: String) {
    
        self.address = address.replacingOccurrences(of: "улица", with: "ул")
        self.city = city.components(separatedBy: ",").first
    }
}
