//
//  LocationService.swift
//  AzbukaVkusaExpress
//
//  Created by Igor Tyukavkin on 23.08.17.
//  Copyright © 2017 Trinity Digital. All rights reserved.
//

import UIKit
import CoreLocation
import PromiseKit

protocol LocationServiceProtocol:NSObjectProtocol {
    func didUpdateUserLocation(location: CLLocation)
    func didFailAuthorization()
}

class LocationService: NSObject {
    fileprivate let locationManager: CLLocationManager
    fileprivate(set) var currentUserLocation: CLLocation?
    weak var delegate: LocationServiceProtocol?
    
    override init() {
        let locationManager = CLLocationManager()
        if CLLocationManager.locationServicesEnabled()
        {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
            
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
        self.locationManager = locationManager
        super.init()
        locationManager.delegate = self
    }
    
    func startTracking() {
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func stopTracking() {
        self.locationManager.stopUpdatingLocation()
    }
}

extension LocationService:CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.first {
            self.currentUserLocation = userLocation
            self.delegate?.didUpdateUserLocation(location: userLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted {
            self.delegate?.didFailAuthorization()
        }
    }
}
