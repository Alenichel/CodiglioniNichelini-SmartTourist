//
//  LocationManager.swift
//  SmartTourist
//
//  Created on 28/11/2019
//

import Foundation
import CoreLocation


class LocationManager {
    static let shared = LocationManager()
    private var lm : CLLocationManager
    
    private init() {
        self.lm = CLLocationManager()
        self.lm.allowsBackgroundLocationUpdates = true
    }

    func requestAuth() {
        self.lm.requestAlwaysAuthorization()
        // TODO: This settings should be tweaked to avoid excessive power consumption
        self.lm.desiredAccuracy = kCLLocationAccuracyBest
        self.lm.distanceFilter = 100
    }
    
    var locationEnabled: Bool {
        let status = CLLocationManager.authorizationStatus()
        return status == .authorizedAlways || status == .authorizedWhenInUse
    }
    
    func startUpdatingLocation() {
        self.lm.startUpdatingLocation()
        print("Starting updating location")
    }
    
    func stopUpdatingLocation() {
        self.lm.stopUpdatingLocation()
        print("Stopped updating location")
    }
    
    func setDelegate (_ delegate: CLLocationManagerDelegate) {
        self.lm.delegate = delegate
    }
}
