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
    private var mapView: GMSMapView
    
    init(mapView: GMSMapView) {
        self.mapView = mapView
    }
    
    func get(position: CLLocationCoordinate2D) -> GMSMarker {
        var marker: GMSMarker
        if self.pool.isEmpty {
            marker = GMSMarker(position: position)
        } else {
            marker = self.pool.remove(at: 0)
            marker.position = position
        }
        marker.map = mapView
        return marker
    }
    
    func put(marker: GMSMarker) {
        marker.map = nil
        pool.append(marker)
    }
}
