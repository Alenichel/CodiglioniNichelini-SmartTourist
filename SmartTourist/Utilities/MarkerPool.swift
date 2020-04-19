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
    private var cache = [WDPlace: MKPlacemark]()
    private var mapView: MKMapView
    
    init(mapView: MKMapView) {
        self.mapView = mapView
    }
    
    static func getMarker(location: CLLocationCoordinate2D, text: String) -> MKPlacemark {
        let address = [CNPostalAddressCountryKey: text]
        return MKPlacemark(coordinate: location, addressDictionary: address)
    }
    
    static func getMarker(place: WDPlace) -> MKPlacemark {
        let address = [CNPostalAddressCountryKey: place.name, "placeID": place.placeID]
        return MKPlacemark(coordinate: place.location, addressDictionary: address)
    }
    
    func setMarkers(places: [WDPlace]) {
        self.cache = self.cache.filter { entry in
            let toBeKept = places.contains(entry.key)
            if !toBeKept { self.mapView.removeAnnotation(entry.value) }
            return toBeKept
        }
        places.forEach { place in
            if self.cache[place] == nil {
                let placemark = MarkerPool.getMarker(place: place)
                self.mapView.addAnnotation(placemark)
                self.cache[place] = placemark
            }
        }
    }
    
    func getPlace(from marker: MKPlacemark) -> WDPlace? {
        return self.cache.keys.first(where: { place in
            self.cache[place] == marker
        })
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
