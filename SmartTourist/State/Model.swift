//
//  Model.swift
//  SmartTourist
//
//  Created on 19/12/2019
//

import Foundation
import CoreLocation


struct GPResponse: Decodable {
    let results: [GPPlace]
    
    enum CodingKeys: CodingKey {
        case results
    }
}


struct GPPlace: Decodable {
    let location: CLLocationCoordinate2D
    let name: String
    let photos: [GPPhoto]
    let placeID: String
    let rating: Double
    let userRatingsTotal: Int
    
    enum CodingKeys: CodingKey {
        case geometry
        case name
        case photos
        case placeId
        case rating
        case userRatingsTotal
        
        enum LocationKeys: CodingKey {
            case location
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let geometryContainer = try container.nestedContainer(keyedBy: CodingKeys.LocationKeys.self, forKey: .geometry)
        self.location = try geometryContainer.decode(CLLocationCoordinate2D.self, forKey: .location)
        self.name = try container.decode(String.self, forKey: .name)
        self.photos = try container.decode([GPPhoto].self, forKey: .photos)
        self.placeID = try container.decode(String.self, forKey: .placeId)
        self.rating = try container.decode(Double.self, forKey: .rating)
        self.userRatingsTotal = try container.decode(Int.self, forKey: .userRatingsTotal)
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
