//
//  FindAddressFindAddressPresentationModel.swift
//  avtolet
//
//  Created by Igor Tyukavkin on 29/03/2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import UIKit
import PromiseKit
import GooglePlaces

class FindAddressPresentationModel: PresentationModel {

    let client = GMSPlacesClient.shared()
    let manager = AddressManager()
    let addressBuilder = AddressBuilder()
    var searchAddressUpdateHandler: (([SearchAddress]) -> ())?
    var addressChangedHandler: ((SearchAddress?) -> ())?
    var userLocationUpdatedHandler: ((CLLocation) -> ())?
    lazy var locationService: LocationService = {
        let service = LocationService()
        service.delegate = self
        return service
    }()
    var locationDidObtained = false
    
    var address: SearchAddress? {
        didSet {
            addressChangedHandler?(address)
        }
    }
    var text = "" {
        didSet {
            updateUserAdress()
        }
    }
    
    deinit {
        locationService.stopTracking()
    }
    
    required init(errorHandler: ErrorHandler?) {
        super.init(errorHandler: errorHandler)
        locationService.startTracking()
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
        }
        if let userlocation = locationService.currentUserLocation {
            client.autocompleteQuery(text, bounds: GMSCoordinateBounds(coordinate: userlocation.coordinate, coordinate: userlocation.coordinate), boundsMode: GMSAutocompleteBoundsMode.bias, filter: filter, callback: callback)
        } else {
            client.autocompleteQuery(text, bounds: nil, filter: filter, callback: callback)
        }
    }
    
    func updateUserAdress() {
        guard let userCoordinate = locationService.currentUserLocation, text.isEmpty else { return }
        manager.getAddress(withCoordinate: userCoordinate.coordinate).done { [weak self] (json) in
            self?.addressBuilder.parseAdressWith(json: json).done({ [weak self] (address) in
                if let street = address.address {
                    self?.searchAddressUpdateHandler?([SearchAddress(address: street, city: address.city)])
                } else {
                    self?.searchAddressUpdateHandler?([])
                }
            }).catch({ (_) in })
        }.catch({ (_) in })
    }
    
    func obtainAddress(coordinate: CLLocationCoordinate2D) {
        address = nil
        manager.getAddress(withCoordinate: coordinate).done { [weak self] (json) in
            self?.addressBuilder.parseAdressWith(json: json).done({ [weak self] (address) in
                if let street = address.address {
                    self?.address = !street.trim().isEmpty ? SearchAddress(address: street, city: address.city) : nil
                } else {
                    self?.address = nil
                }
            }).catch({ (_) in })
        }.catch({ (_) in })
    }

}

extension FindAddressPresentationModel: LocationServiceProtocol {
    func didUpdateUserLocation(location: CLLocation) {
        if !locationDidObtained {
            userLocationUpdatedHandler?(location)
            locationDidObtained = true
        }
        updateUserAdress()
    }
    
    func didFailAuthorization() { }
}
