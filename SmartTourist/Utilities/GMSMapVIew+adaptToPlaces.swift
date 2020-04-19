//
//  GMSMapVIew+adaptToPlaces.swift
//  SmartTourist
//
//  Created on 23/03/2020
//

import Foundation
import GoogleMaps


extension GMSMapView {
    func adaptToPlaces(_ places: [WDPlace]) {
        let bounds = places.reduce(GMSCoordinateBounds(), { $0.includingCoordinate($1.location) })
        print(bounds.northEast)
        print(bounds.southWest)
        let update = GMSCameraUpdate.fit(bounds)
        self.animate(with: update)
    }
}
