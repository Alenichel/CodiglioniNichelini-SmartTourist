//
//  MarkerPool.swift
//  SmartTourist
//
//  Created on 28/02/2020
//

import Foundation
import MapKit
import Contacts


class MarkerPool {
    private var cache = [CLLocationCoordinate2D: MKPlacemark]()
    private var mapView: MKMapView
    
    init(mapView: MKMapView) {
        self.mapView = mapView
    }
    
    func setMarkers(places: [GPPlace]) {
        let coordinates = places.map { $0.location }
        self.cache = self.cache.filter { entry in
            let toBeKept = coordinates.contains(entry.key)
            if !toBeKept { self.mapView.removeAnnotation(entry.value) }
            return toBeKept
        }
        places.forEach { place in
            if self.cache[place.location] == nil {
                let address = [CNPostalAddressCountryKey: place.name]
                let placemark = MKPlacemark(coordinate: place.location, addressDictionary: address)
                self.mapView.addAnnotation(placemark)
                //marker.userData = place
                self.cache[place.location] = placemark
            }
        }
    }
}


extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}


extension CLLocationCoordinate2D: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.latitude)
        hasher.combine(self.longitude)
    }
}
