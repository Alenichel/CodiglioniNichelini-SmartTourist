//
//  LocationManager.swift
//  SmartTourist
//
//  Created on 28/11/2019
//

import Foundation
import CoreLocation


class LocationManager: NSObject {
    static let shared = LocationManager()
    static let sharedForegound = LocationManager(allowsBacgroundLocationUpdates: false)
    private var lm: CLLocationManager
    
    init(allowsBacgroundLocationUpdates: Bool = true) {
        self.lm = CLLocationManager()
        self.lm.allowsBackgroundLocationUpdates = allowsBacgroundLocationUpdates
        super.init()
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
    
    func setDelegate(_ delegate: CLLocationManagerDelegate) {
        self.lm.delegate = delegate
    }
}
