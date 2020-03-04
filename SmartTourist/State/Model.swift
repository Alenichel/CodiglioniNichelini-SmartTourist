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


struct GPPlace: Codable, Equatable {
    let location: CLLocationCoordinate2D
    let name: String
    let photos: [GPPhoto]?
    let placeID: String
    let rating: Double?
    let userRatingsTotal: Int?
    
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
        self.photos = try container.decodeIfPresent([GPPhoto].self, forKey: .photos)
        self.placeID = try container.decode(String.self, forKey: .placeId)
        self.rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        self.userRatingsTotal = try container.decodeIfPresent(Int.self, forKey: .userRatingsTotal)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var geometryContainer = container.nestedContainer(keyedBy: CodingKeys.LocationKeys.self, forKey: .geometry)
        try geometryContainer.encode(location, forKey: .location)
        try container.encode(name, forKey: .name)
        try container.encode(photos, forKey: .photos)
        try container.encode(placeID, forKey: .placeId)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encodeIfPresent(userRatingsTotal, forKey: .userRatingsTotal)
    }
    
    static func == (lhs: GPPlace, rhs: GPPlace) -> Bool {
        return lhs.placeID == rhs.placeID
    }
}


extension CLLocationCoordinate2D: Codable {
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
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .lat)
        try container.encode(longitude, forKey: .lng)
    }
}


class GPPhoto: Codable {
    let photoReference: String
    let height: Int
    let width: Int
    
    enum CodingKeys: CodingKey {
        case photoReference
        case height
        case width
    }
}
