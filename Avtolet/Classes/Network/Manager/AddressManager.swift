//
//  AddressManager.swift
//  Avtolet
//
//  Created by Igor Tyukavkin on 29.03.2018.
//  Copyright © 2018 Igor Tyukavkin. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import CoreLocation

//MARK - Сервис не придерживается общей архитектуры, так как делает запросы на сторонний ресурс

class AddressManager: NetworkManager {
    @discardableResult func getAddress(withCoordinate coordinate: CLLocationCoordinate2D) -> Promise<Any?> {
        return Promise<Any?> { resolver in
            let url = "https://maps.googleapis.com/maps/api/geocode/json?language=ru&latlng=\(coordinate.latitude),\(coordinate.longitude)&key=\(kGoogleApiKey)"
            request(url).responseJSON { (response) in
                if let error = response.error {
                    resolver.reject(error)
                } else {
                    resolver.fulfill(response.result.value)
                }
            }
        }
    }
}
