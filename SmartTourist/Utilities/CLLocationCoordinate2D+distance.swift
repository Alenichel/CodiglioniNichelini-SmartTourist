//
//  CLLocationCoordinate2D+distance.swift
//  SmartTourist
//
//  Created on 23/03/2020
//

import CoreLocation


extension CLLocationCoordinate2D {
    func distance(from: CLLocationCoordinate2D) -> Int {
        let current = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let remote = CLLocation(latitude: from.latitude, longitude: from.longitude)
        return Int(current.distance(from: remote).rounded())
    }
    
    func distance(from: GPPlace) -> Int {
        return self.distance(from: from.location)
    }
}
