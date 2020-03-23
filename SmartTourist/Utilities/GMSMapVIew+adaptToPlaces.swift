//
//  GMSMapVIew+adaptToPlaces.swift
//  SmartTourist
//
//  Created on 23/03/2020
//

import Foundation
import GoogleMaps


extension GMSMapView {
    func adaptToPlaces(_ places: [GPPlace]) {
        let bounds = places.reduce(GMSCoordinateBounds(), { $0.includingCoordinate($1.location) })
        print(bounds.northEast)
        print(bounds.southWest)
        self.moveCamera(GMSCameraUpdate.fit(bounds))
        self.animate(with: GMSCameraUpdate.fit(bounds))
    }
}
