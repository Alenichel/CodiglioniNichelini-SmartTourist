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
        let location = place.coordinate
        self.geometry = GPGeometry(location: location)
        self.name = place.name
        self.photos = []
        self.placeID = place.placeID
        self.rating = Double(place.rating)
        self.userRatingsTotal = Int(place.userRatingsTotal)
    }
}


struct GPGeometry: Decodable {
    let location: CLLocationCoordinate2D
    
    enum CodingKeys: CodingKey {
        case location
    }
}


extension CLLocationCoordinate2D: Decodable {
    enum CodingKeys: CodingKey {
        case lat
        case lng
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .lat)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .lng)
        self.init(latitude: latitude, longitude: longitude)
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
