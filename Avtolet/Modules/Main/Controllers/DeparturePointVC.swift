//
//  DeparturePointVC.swift
//  Avtolet
//
//  Created by Artyom Schiopu on 12/18/18.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
class DeparturePointVC: CommonViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    var dataSource = [Adresses]()
    var count = Int()
    var text = ""
    var searchAddressUpdateHandler: (([SearchAddress]) -> ())?
    @IBOutlet var fromTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    lazy var locationService: LocationService = {
        let service = LocationService()
        service.delegate = self
        
        return service
    }()
    let client = GMSPlacesClient.shared()
    var addresses1 = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        fromTextField.becomeFirstResponder()
        fromTextField.addTarget(self, action: #selector(textDidChange(textField:)), for: .editingChanged)
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
            //            self?.toTextField.text = addresses.first?.address
            //            self?.autoCompleteText(in : (self?.toTextField)!, using: text, suggestions: (self?.addresses1)!)
        }
        if let userlocation = locationService.currentUserLocation {
            client.autocompleteQuery(text, bounds: GMSCoordinateBounds(coordinate: userlocation.coordinate, coordinate: userlocation.coordinate), boundsMode: GMSAutocompleteBoundsMode.bias, filter: filter, callback: callback)
        } else {
            client.autocompleteQuery(text, bounds: nil, filter: filter, callback: callback)
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        fromTextField.text = cell?.textLabel?.text
        performSegue(withIdentifier: "unWindToMain", sender: self)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row].query
        
//        cell.imageView?.image = UIImage(imageLiteralResourceName: "clock")
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! MainVC
        destVC.departurePoint = fromTextField.text!
        
    }
    
    @IBAction func didTapBack(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}



extension DeparturePointVC: LocationServiceProtocol{
    func didFailAuthorization() {
        
    }
    
    
    func didUpdateUserLocation(location: CLLocation) {}
}
