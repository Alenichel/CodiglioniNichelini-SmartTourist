//
//  MarkerPool.swift
//  SmartTourist
//
//  Created on 28/02/2020
//

import Foundation
import GoogleMaps


class GMSMarkerPool {
    private var pool = [GMSMarker]()
    private var cache = [CLLocationCoordinate2D: GMSMarker]()
    private var mapView: GMSMapView
    
    init(mapView: GMSMapView) {
        self.mapView = mapView
    }
    
    func setMarkers(places: [GPPlace]) {
        let coordinates = places.map { $0.location }
        self.cache = self.cache.filter({ entry in
            let toBeKept = coordinates.contains(entry.key)
            if !toBeKept { entry.value.map = nil }
            return toBeKept
        })
        places.forEach { place in
            if !self.cache.keys.contains(place.location) {
                let marker = GMSMarker(position: place.location)
                marker.map = self.mapView
                marker.title = place.name
                self.cache[place.location] = marker
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
