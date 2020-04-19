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
    
    func distance(from: WDPlace) -> Int {
        return self.distance(from: from.location)
    }
    
    func offset(_ offset: Double) -> CLLocationCoordinate2D {
        let distRadians = offset / (6372797.6) // earth radius in meters
        let bearing: Double = 0.0
        let lat1 = self.latitude * Double.pi / 180
        let lon1 = self.longitude * Double.pi / 180
        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing))
        let lon2 = lon1 + atan2(sin(bearing) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))
        return CLLocationCoordinate2D(latitude: lat2 * 180 / Double.pi, longitude: lon2 * 180 / Double.pi)
    }
}
