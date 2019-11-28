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
    private init(){}
    
    var lm = CLLocationManager()

    func requestAuth() {
        lm.requestAlwaysAuthorization()
        lm.desiredAccuracy = kCLLocationAccuracyBest
        print("Starting updating location")
        lm.distanceFilter = 50
    }
    
    func startUpdatingLocation(){
        lm.startUpdatingLocation()
    }
    
    func setDelegate (_ delegate: CLLocationManagerDelegate){
        self.lm.delegate = delegate
    }
}
