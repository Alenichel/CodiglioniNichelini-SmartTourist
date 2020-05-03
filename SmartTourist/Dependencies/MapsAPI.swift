//
//  MapsAPI.swift
//  SmartTourist
//
//  Created on 20/04/2020
//

import Foundation
import MapKit
import Hydra


class MapsAPI {
    static let shared = MapsAPI()
    private init() {}
    
    static let throttleTime: Double = 60        // seconds
    static let throttleDistance: Int = 1000   // meters
    
    private let geocoder = CLGeocoder()
    private let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.minute, .hour]
        return formatter
    }()
    
    private var lastCoordinates: CLLocationCoordinate2D?
    private var lastCity: String?
    private var lastCountryCode: String?
    private var lastUpdate: Date?
    
    func getCityName(coordinates: CLLocationCoordinate2D) -> Promise<String> {
        return Promise<String>(in: .background) { resolve, reject, status in
            if let lastCoordinates = self.lastCoordinates, let lastCity = self.lastCity, let lastUpdate = self.lastUpdate {
                if lastUpdate.distance(to: Date()) < MapsAPI.throttleTime && coordinates.distance(from: lastCoordinates) < MapsAPI.throttleDistance {
                    resolve(lastCity)
                    return
                }
            }
            let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            self.geocoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
                if let error = error {
                    reject(error)
                } else if let placemark = placemarks?[0], let locality = placemark.locality {
                    self.lastCoordinates = coordinates
                    self.lastCity = locality
                    self.lastUpdate = Date()
                    resolve(locality)
                }
            })
        }
    }
    
    func getTravelTime(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> Promise<String> {
        return Promise<String>(in: .background) { resolve, reject, status in
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
            request.transportType = .walking
            let directions = MKDirections(request: request)
            directions.calculateETA { response, error in
                if let error = error {
                    reject(error)
                } else if let response = response {
                    let etaString = self.timeFormatter.string(from: response.expectedTravelTime)!
                    resolve(etaString)
                }
            }
        }
    }
    
    func openDirectionsInMapsApp(to destination: WDPlace) {
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        let placemark = MKPlacemark(coordinate: destination.location)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = destination.name
        mapItem.openInMaps(launchOptions: options)
    }
}
