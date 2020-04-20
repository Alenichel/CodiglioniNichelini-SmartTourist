//
//  GPPlace.swift
//  SmartTourist
//
//  Created on 20/04/2020
//

import Foundation
import CoreLocation


class GPPlace: Codable, Equatable, Hashable, Comparable {
    let placeID: String
    let location: CLLocationCoordinate2D
    let name: String
    var city: String?
    let rating: Double?
    let userRatingsTotal: Int?
    var website: String?

    enum CodingKeys: CodingKey {
        case geometry
        case name
        case placeId
        case rating
        case userRatingsTotal
        case city
        case website
        
        enum LocationKeys: CodingKey {
            case location
        }
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let geometryContainer = try container.nestedContainer(keyedBy: CodingKeys.LocationKeys.self, forKey: .geometry)
        self.location = try geometryContainer.decode(CLLocationCoordinate2D.self, forKey: .location)
        self.name = try container.decode(String.self, forKey: .name)
        self.placeID = try container.decode(String.self, forKey: .placeId)
        self.rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        self.userRatingsTotal = try container.decodeIfPresent(Int.self, forKey: .userRatingsTotal)
        self.city = try container.decodeIfPresent(String.self, forKey: .city)
        self.website = try container.decodeIfPresent(String.self, forKey: .website)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var geometryContainer = container.nestedContainer(keyedBy: CodingKeys.LocationKeys.self, forKey: .geometry)
        try geometryContainer.encode(self.location, forKey: .location)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.placeID, forKey: .placeId)
        try container.encodeIfPresent(self.rating, forKey: .rating)
        try container.encodeIfPresent(self.userRatingsTotal, forKey: .userRatingsTotal)
        try container.encodeIfPresent(self.city, forKey: .city)
        try container.encodeIfPresent(self.website, forKey: .website)
    }

    func distance(from: GPPlace) -> Int {
        return self.location.distance(from: from.location)
    }

    func distance(from: CLLocationCoordinate2D) -> Int {
        return self.location.distance(from: from)
    }

    static func == (lhs: GPPlace, rhs: GPPlace) -> Bool {
        return lhs.placeID == rhs.placeID
    }

    static func < (lhs: GPPlace, rhs: GPPlace) -> Bool {
        if let lc = lhs.city, let rc = rhs.city, lc != rc {
            return lc < rc
        } else {
            return lhs.name < rhs.name
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.placeID)
    }
}
