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
    let results: [WDPlace]
    
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

/*
class WDPlace: Codable, Equatable, Hashable, Comparable {
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
        /*if self.photos == nil || (self.photos != nil && self.photos!.count < 2) || self.website == nil {
            GoogleAPI.shared.getPlaceDetails(placeID: self.placeID).then(in: .utility) { result in
                if let photos = result.photos {
                    self.photos = Array<GPPhoto>(Set<GPPhoto>(self.photos!).union(Set<GPPhoto>(photos)))
                }
                if let website = result.website {
                    self.website = website
                }
            }
        }*/
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
    
    func distance(from: WDPlace) -> Int {
        return self.location.distance(from: from.location)
    }
    
    func distance(from: CLLocationCoordinate2D) -> Int {
        return self.location.distance(from: from)
    }
    
    static func == (lhs: WDPlace, rhs: WDPlace) -> Bool {
        return lhs.placeID == rhs.placeID
    }
    
    static func < (lhs: WDPlace, rhs: WDPlace) -> Bool {
        if let lc = lhs.city, let rc = rhs.city, lc != rc {
            return lc < rc
        } else {
            return lhs.name < rhs.name
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.placeID)
    }
}*/


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


fileprivate struct WDBinding: Codable {
    let value: String
    
    enum CodingKeys: CodingKey {
        case value
    }
}


class WDPlace: Codable, Hashable, Comparable {
    var placeID: String
    var instance: String
    var name: String
    var city: String?
    var location: CLLocationCoordinate2D
    var wikipediaLink: URL?
    var photos: [URL]? = []
    
    //compatibility
    var rating: Double? = 3.0
    var userRatingsTotal: Int? = 1000
    var website: String? = ""
    
    
    enum CodingKeys: String, CodingKey {
        case placeId = "place"
        case instance = "instance"
        case name = "placeLabel"
        case city = "cityLabel"
        case location = "location"
        case imageURL = "image"
        case wikipediaLink = "wikipediaLink"
        
        case rating = "rating"
        case userRatingsTotal = "userRatingsTotal"
        case website = "website"
        case photos = "photos"
        
        enum ValueCodingKeys: CodingKey {
            case value
        }
    }
    
    class WrongInstanceError: Error {}
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let instanceId = try container.decode(WDBinding.self, forKey: .instance)
        let instanceIdString = instanceId.value
        let instanceIdRange = instanceIdString.range(of: #"Q[0-9]+"#, options: .regularExpression)!
        let instanceIdSub = instanceIdString[instanceIdRange]
        self.instance = String(instanceIdSub)
        let name = try container.decode(WDBinding.self, forKey: .name)
        self.name = name.value
        let id = try container.decode(WDBinding.self, forKey: .placeId)
        let placeIdString = id.value
        let placeIdRange = placeIdString.range(of: #"Q[0-9]+"#, options: .regularExpression)!
        let placeIdSub = placeIdString[placeIdRange]
        self.placeID = String(placeIdSub)
        let city = try container.decodeIfPresent(WDBinding.self, forKey: .city)
        self.city = city?.value
        let location = try container.decode(WDBinding.self, forKey: .location)
        let locationString = location.value
        let range = locationString.range(of: #"[-+]?(\d*\.)?\d+ [-+]?(\d*\.)?\d+"#, options: .regularExpression)!
        let substring = locationString[range]
        let splits = substring.split(separator: " ")
        let longitude = Double(splits[0])!
        let latitude = Double(splits[1])!
        self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let imageURL = try container.decodeIfPresent(WDBinding.self, forKey: .imageURL)
        if let ciu = imageURL?.value {
            self.photos?.append(URL(string: ciu)!)
        }
        let wikipediaLink = try container.decodeIfPresent(WDBinding.self, forKey: .wikipediaLink)
        self.wikipediaLink = URL(string: wikipediaLink?.value ?? "")
        self.photos = try container.decodeIfPresent([URL].self, forKey: .photos)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let placeIdBinding = WDBinding(value: self.placeID)
        try container.encode(placeIdBinding, forKey: .placeId)
        let nameBinding = WDBinding(value: self.name)
        try container.encode(nameBinding, forKey: .name)
        let instanceBinding = WDBinding(value: self.instance)
        try container.encode(instanceBinding, forKey: .instance)
        let locationBinding = WDBinding(value: "Point(\(self.location.longitude) \(self.location.latitude)")
        try container.encode(locationBinding, forKey: .location)
        if let city = self.city {
            let cityBinding = WDBinding(value: city)
            try container.encode(cityBinding, forKey: .location)
        }
        if let wikipediaLink = self.wikipediaLink {
            let wikipediaLinkBinding = WDBinding(value: wikipediaLink.absoluteString)
            try container.encode(wikipediaLinkBinding, forKey: .wikipediaLink)
        }
        try container.encode(self.photos, forKey: .photos)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.placeID)
    }
    
    static func == (lhs: WDPlace, rhs: WDPlace) -> Bool {
        return lhs.placeID == rhs.placeID
    }
    
    static func < (lhs: WDPlace, rhs: WDPlace) -> Bool {
        if let lc = lhs.city, let rc = rhs.city, lc != rc {
            return lc < rc
        } else {
            return lhs.name < rhs.name
        }
    }
    
    func distance(from: WDPlace) -> Int {
        return self.location.distance(from: from.location)
    }
    
    func distance(from: CLLocationCoordinate2D) -> Int {
        return self.location.distance(from: from)
    }
}


class WDPlaceResponse: Decodable {
    var places : [WDPlace]
    
    enum RootCodingKeys: CodingKey {
        case results
        
        enum ResultsCodingKeys: CodingKey {
            case bindings
        }
    }
    
    required init(from decoder: Decoder) throws {
        places = []
        let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
        let resultsContainer = try rootContainer.nestedContainer(keyedBy: RootCodingKeys.ResultsCodingKeys.self, forKey: .results)
        var bindingsContainer = try resultsContainer.nestedUnkeyedContainer(forKey: .bindings)
        while !bindingsContainer.isAtEnd {
            let place = try bindingsContainer.decode(WDPlace.self)
            self.places.append(place)
        }
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
        let city = try bindingsContainer.decode(WDBinding.self, forKey: .city)
        self.city = city.value
        let country = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .country)
        self.country = country?.value
        let population = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .population)
        self.population = Int(population?.value ?? "nil")
        let area = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .area)
        self.area = Int(area?.value ?? "nil")
        let elevation = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .elevation)
        self.elevation = Int(elevation?.value ?? "nil")
        let link = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .link)
        self.link = link?.value
        let facebookPageId = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .facebookPageId)
        self.facebookPageId = facebookPageId?.value
        let facebookPlacesId = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .facebookPlacesId)
        self.facebookPlacesId = facebookPlacesId?.value
        let instagramUsername = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .instagramUsername)
        self.instagramUsername = instagramUsername?.value
        let twitterUsername = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .twitterUsername)
        self.twitterUsername = twitterUsername?.value
        let imageURL = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .image)
        self.imageURL = imageURL?.value
        let cityLabel = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .cityLabel)
        self.cityLabel = cityLabel?.value
        let countryLabel = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .countryLabel)
        self.countryLabel = countryLabel?.value
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
