//
//  Model.swift
//  SmartTourist
//
//  Created on 19/12/2019
//

import Foundation
import GooglePlaces


struct GPResponse: Decodable {
    let results: [GPPlace]
    
    enum CodingKeys: CodingKey {
        case results
    }
}


struct GPPlace: Decodable {
    let geometry: GPGeometry
    let name: String?
    let photos: [GPPhoto]?
    let placeID: String?
    let rating: Double
    let userRatingsTotal: Int
    
    enum CodingKeys: CodingKey {
        case geometry
        case name
        case photos
        case placeID
        case rating
        case userRatingsTotal
    }
    
    init(place: GMSPlace) {
        let location = GPLocation(lat: place.coordinate.latitude, lng: place.coordinate.longitude)
        self.geometry = GPGeometry(location: location)
        self.name = place.name
        self.photos = []
        self.placeID = place.placeID
        self.rating = Double(place.rating)
        self.userRatingsTotal = Int(place.userRatingsTotal)
    }
}


struct GPGeometry: Decodable {
    let location: GPLocation
    
    enum CodingKeys: CodingKey {
        case location
    }
}


struct GPLocation: Decodable {
    let lat: Double
    let lng: Double
    
    var cllocation: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.lat, longitude: self.lng)
    }
}


struct GPPhoto: Decodable {
    let photoReference: String
    let height: Int
    let width: Int
    
    enum CodingKeys: CodingKey {
        case photoReference
        case height
        case width
    }
}
