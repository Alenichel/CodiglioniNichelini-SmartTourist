//
//  MapsAPI.swift
//  SmartTourist
//
//  Created on 20/04/2020
//

import Foundation
import CoreLocation
import Hydra


class MapsAPI {
    static let shared = MapsAPI()
    private init() {}
    
    private let geocoder = CLGeocoder()
    
    func getCityName(coordinates: CLLocationCoordinate2D) -> Promise<String> {
        return Promise<String>(in: .background) { resolve, reject, status in
            let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            self.geocoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
                if let error = error {
                    reject(error)
                }
                else if let placemark = placemarks?[0], let locality = placemark.locality {
                    resolve(locality)
                }
            })
        }
    }
}
