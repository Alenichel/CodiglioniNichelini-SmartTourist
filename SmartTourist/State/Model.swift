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


class GPPlace: Codable, Equatable {
    let placeID: String
    let location: CLLocationCoordinate2D
    let name: String
    var city: String?
    let photos: [GPPhoto]?
    let rating: Double?
    let userRatingsTotal: Int?
    
    enum CodingKeys: CodingKey {
        case geometry
        case name
        case photos
        case placeId
        case rating
        case userRatingsTotal
        case city
        
        enum LocationKeys: CodingKey {
            case location
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let geometryContainer = try container.nestedContainer(keyedBy: CodingKeys.LocationKeys.self, forKey: .geometry)
        self.location = try geometryContainer.decode(CLLocationCoordinate2D.self, forKey: .location)
        self.name = try container.decode(String.self, forKey: .name)
        self.photos = try container.decodeIfPresent([GPPhoto].self, forKey: .photos)
        self.placeID = try container.decode(String.self, forKey: .placeId)
        self.rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        self.userRatingsTotal = try container.decodeIfPresent(Int.self, forKey: .userRatingsTotal)
        self.city = try container.decodeIfPresent(String.self, forKey: .city)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var geometryContainer = container.nestedContainer(keyedBy: CodingKeys.LocationKeys.self, forKey: .geometry)
        try geometryContainer.encode(self.location, forKey: .location)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.photos, forKey: .photos)
        try container.encode(self.placeID, forKey: .placeId)
        try container.encodeIfPresent(self.rating, forKey: .rating)
        try container.encodeIfPresent(self.userRatingsTotal, forKey: .userRatingsTotal)
        try container.encodeIfPresent(self.city, forKey: .city)
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


struct GMDLeg: Decodable {
    let durationText: String
    let durationValue: Double
    
    enum CodingKeys: CodingKey {
        case duration
        enum DurationKeys: CodingKey {
            case text
            case value
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let durationContainer = try container.nestedContainer(keyedBy: CodingKeys.DurationKeys.self, forKey: .duration)
        self.durationText = try durationContainer.decode(String.self, forKey: .text)
        self.durationValue = try durationContainer.decode(Double.self, forKey: .value)
    }
}

struct GMDRoute: Decodable {
    let legs: [GMDLeg]
    
    enum CodingKeys: CodingKey {
        case legs
    }
}

struct GMDResponse: Decodable {
    let routes: [GMDRoute]
    let status: String
    
    enum CodingKeys: CodingKey {
        case routes
        case status
    }
}
