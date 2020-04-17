//
//  Model.swift
//  SmartTourist
//
//  Created on 19/12/2019
//

import UIKit
import CoreLocation
import Hydra


struct GPPlaceSearchResponse: Decodable {
    let results: [GPPlace]
    
    enum CodingKeys: CodingKey {
        case results
    }
}

struct GPPlaceDetailResponse: Decodable {
    let result: GPPlaceDetailResultsResponse
    
    enum CodingKeys: CodingKey {
        case result
    }
}


struct GPPlaceDetailResultsResponse: Decodable {
    let photos: [GPPhoto]?
    let website: String?
    
    enum CodingKeys: CodingKey {
        case photos
        case website
    }
}


class GPPlace: Codable, Equatable, Hashable, Comparable {
    let placeID: String
    let location: CLLocationCoordinate2D
    let name: String
    var city: String?
    var photos: [GPPhoto]?
    let rating: Double?
    let userRatingsTotal: Int?
    var website: String?
    
    enum CodingKeys: CodingKey {
        case geometry
        case name
        case photos
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
        self.photos = try container.decodeIfPresent([GPPhoto].self, forKey: .photos)
        self.placeID = try container.decode(String.self, forKey: .placeId)
        self.rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        self.userRatingsTotal = try container.decodeIfPresent(Int.self, forKey: .userRatingsTotal)
        self.city = try container.decodeIfPresent(String.self, forKey: .city)
        self.website = try container.decodeIfPresent(String.self, forKey: .website)
        if self.photos == nil || (self.photos != nil && self.photos!.count < 2) || self.website == nil {
            GoogleAPI.shared.getPlaceDetails(placeID: self.placeID).then(in: .utility) { result in
                if let photos = result.photos {
                    self.photos = Array<GPPhoto>(Set<GPPhoto>(self.photos!).union(Set<GPPhoto>(photos)))
                }
                if let website = result.website {
                    self.website = website
                }
            }
        }
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


class GPPhoto: Codable, Hashable {
    let photoReference: String
    let height: Int
    let width: Int
    
    enum CodingKeys: CodingKey {
        case photoReference
        case height
        case width
    }
    
    static func == (lhs: GPPhoto, rhs: GPPhoto) -> Bool {
        return lhs.photoReference == rhs.photoReference
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.photoReference)
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


class WDCity: Decodable {
    let city: String
    let country: String?
    let population: Int?
    let area: Int?
    let elevation: Int?
    let link: String?
    let facebookPageId: String?
    let facebookPlacesId: String?
    let instagramUsername: String?
    let twitterUsername: String?
    let imageURL: String?
    var image: UIImage?
    let cityLabel: String?
    let countryLabel: String?
    
    enum CodingKeys: CodingKey {
        case results
        
        enum ResultsCodingKeys: CodingKey {
            case bindings
            
            enum BindingsCodingKeys: CodingKey {
                case city
                case country
                case population
                case area
                case elevation
                case link
                case facebookPageId
                case facebookPlacesId
                case instagramUsername
                case twitterUsername
                case image
                case cityLabel
                case countryLabel
                
                enum ValueCodingKeys: CodingKey {
                    case value
                }
            }
        }
    }
    
    required init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        let resultsContainer = try rootContainer.nestedContainer(keyedBy: CodingKeys.ResultsCodingKeys.self, forKey: .results)
        var bindingsArrayContainer = try resultsContainer.nestedUnkeyedContainer(forKey: .bindings)
        let bindingsContainer = try bindingsArrayContainer.nestedContainer(keyedBy: CodingKeys.ResultsCodingKeys.BindingsCodingKeys.self)
        var container = try bindingsContainer.nestedContainer(keyedBy: CodingKeys.ResultsCodingKeys.BindingsCodingKeys.ValueCodingKeys.self, forKey: .city)
        self.city = try container.decode(String.self, forKey: .value)
        container = try bindingsContainer.nestedContainer(keyedBy: CodingKeys.ResultsCodingKeys.BindingsCodingKeys.ValueCodingKeys.self, forKey: .country)
        self.country = try container.decodeIfPresent(String.self, forKey: .value)
        container = try bindingsContainer.nestedContainer(keyedBy: CodingKeys.ResultsCodingKeys.BindingsCodingKeys.ValueCodingKeys.self, forKey: .population)
        self.population = try Int(container.decodeIfPresent(String.self, forKey: .value) ?? "nil")
        container = try bindingsContainer.nestedContainer(keyedBy: CodingKeys.ResultsCodingKeys.BindingsCodingKeys.ValueCodingKeys.self, forKey: .area)
        self.area = try Int(container.decodeIfPresent(String.self, forKey: .value) ?? "nil")
        container = try bindingsContainer.nestedContainer(keyedBy: CodingKeys.ResultsCodingKeys.BindingsCodingKeys.ValueCodingKeys.self, forKey: .elevation)
        self.elevation = try Int(container.decodeIfPresent(String.self, forKey: .value) ?? "nil")
        container = try bindingsContainer.nestedContainer(keyedBy: CodingKeys.ResultsCodingKeys.BindingsCodingKeys.ValueCodingKeys.self, forKey: .link)
        self.link = try container.decodeIfPresent(String.self, forKey: .value)
        container = try bindingsContainer.nestedContainer(keyedBy: CodingKeys.ResultsCodingKeys.BindingsCodingKeys.ValueCodingKeys.self, forKey: .facebookPageId)
        self.facebookPageId = try container.decodeIfPresent(String.self, forKey: .value)
        container = try bindingsContainer.nestedContainer(keyedBy: CodingKeys.ResultsCodingKeys.BindingsCodingKeys.ValueCodingKeys.self, forKey: .facebookPlacesId)
        self.facebookPlacesId = try container.decodeIfPresent(String.self, forKey: .value)
        container = try bindingsContainer.nestedContainer(keyedBy: CodingKeys.ResultsCodingKeys.BindingsCodingKeys.ValueCodingKeys.self, forKey: .instagramUsername)
        self.instagramUsername = try container.decodeIfPresent(String.self, forKey: .value)
        container = try bindingsContainer.nestedContainer(keyedBy: CodingKeys.ResultsCodingKeys.BindingsCodingKeys.ValueCodingKeys.self, forKey: .twitterUsername)
        self.twitterUsername = try container.decodeIfPresent(String.self, forKey: .value)
        container = try bindingsContainer.nestedContainer(keyedBy: CodingKeys.ResultsCodingKeys.BindingsCodingKeys.ValueCodingKeys.self, forKey: .image)
        self.imageURL = try container.decodeIfPresent(String.self, forKey: .value)
        container = try bindingsContainer.nestedContainer(keyedBy: CodingKeys.ResultsCodingKeys.BindingsCodingKeys.ValueCodingKeys.self, forKey: .cityLabel)
        self.cityLabel = try container.decodeIfPresent(String.self, forKey: .value)
        container = try bindingsContainer.nestedContainer(keyedBy: CodingKeys.ResultsCodingKeys.BindingsCodingKeys.ValueCodingKeys.self, forKey: .countryLabel)
        self.countryLabel = try container.decodeIfPresent(String.self, forKey: .value)
        async(in: .utility) {
            guard
                let imageURL = self.imageURL,
                let url = URL(string: imageURL),
                let data = try? Data(contentsOf: url)
            else { return }
            self.image = UIImage(data: data)
        }
    }
}
