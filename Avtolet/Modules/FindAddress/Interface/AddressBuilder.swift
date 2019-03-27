//
//  AddressBuilder.swift
//  AzbukaVkusaExpress
//
//  Created by Vladislav Chugunkin on 24.08.17.
//  Copyright © 2017 TRINITY Digital. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire
import CoreLocation

struct AddressModel {
    var city: String?
    var street: String?
    var house: String?
    var address: String?
    
    init() {
        city = ""
        street = ""
        house = ""
        address = ""
    }
}

class AddressBuilder: NSObject {
    
    var street = ""
    var house = ""
    var airport = ""
    var premise = ""
    var park = ""
    var city = ""
    
    func clean() {
        street = ""
        house = ""
        airport = ""
        premise = ""
        park = ""
        city = ""
    }
    
    @discardableResult func parseAdressWith(json: Any?) -> Promise<AddressModel> {
        return Promise<AddressModel> { [unowned self] resolver in
            self.clean()
            DispatchQueue.global().async {
                var result = ""
                var addressModel = AddressModel()
                if let json = json as? [String: Any] {
                    if let results = json["results"] as? [[String:Any]] {
                        if let address_components = results.first?["address_components"] as? [[String: Any]] {
                            for i in 0...address_components.count - 1 {
                                if let types = address_components[i]["types"] as? [String] {
                                    self.getAddressComponentsWith(types: types, andAddressComponents: address_components, andNumber: i)
                                }
                            }
                        }
                        if self.street != "" {
                            result += self.street
                            if self.house != "" {
                                result += ", д. " + self.house
                            }
                        } else if self.premise != "" {
                            result += self.premise
                        } else if self.airport != "" {
                            result += self.airport
                        } else if self.park != "" {
                            result += self.park
                        }
                    }
                }
                addressModel.address = result == "Unnamed Road" ? "" : result
                addressModel.city = self.city
                addressModel.house = self.house
                addressModel.street = self.street
                DispatchQueue.main.async {
                    resolver.fulfill(addressModel)
                }
            }
        }
    }
    
    
    //MARK: catch address components like street, house, etc.
    func getAddressComponentsWith(types: [String], andAddressComponents address_components: [[String: Any]], andNumber number: Int) {
        for type in types {
            if type == "premise" {
                if let premiseString = address_components[number]["short_name"] as? String {
                    premise = premiseString
                }
            } else if type == "airport" {
                if let airportString = address_components[number]["short_name"] as? String {
                    airport = airportString
                }
            } else if type == "park" {
                if let parkString = address_components[number]["short_name"] as? String {
                    park = parkString
                }
            } else if type == "route" {
                if let streetString = address_components[number]["short_name"] as? String {
                    street = streetString
                }
            } else if type == "street_number" {
                if let houseString = address_components[number]["short_name"] as? String {
                    house = houseString
                }
            } else if type == "locality" {
                if let cityString = address_components[number]["long_name"] as? String {
                    city = cityString
                }
            }
        }
    }
}
