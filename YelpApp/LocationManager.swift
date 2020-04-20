//
//  LocationManager.swift
//  YelpApp
//
//  Created by Joffrey Mann on 4/19/20.
//  Copyright © 2020 Joffrey Mann. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    var delegate:LocationManagerDelegate?
    var locationManager:CLLocationManager?
    var currentLocation: CLLocation? {
        didSet {
            guard currentLocation != oldValue else {
                return
            }
            self.delegate?.getUpdatedCurrentLocation(location: currentLocation!)
        }
    }
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager?.distanceFilter = kCLLocationAccuracyHundredMeters
        locationManager?.requestAlwaysAuthorization()
        locationManager?.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.delegate = self
        }
    }
    
    @objc func fetchCurrentLocation(){
        locationManager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.fetchCurrentLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
            currentLocation = locations[0]
            locationManager?.stopUpdatingLocation()
        }
    }
}

protocol LocationManagerDelegate {
    func getUpdatedCurrentLocation(location: CLLocation)
}
