//
//  WDPlace.swift
//  SmartTourist
//
//  Created on 20/04/2020
//

import Foundation
import CoreLocation


class WDPlace: Codable, Hashable, Comparable {
    var placeID: String
    var instance: String
    var name: String
    var city: String?
    var location: CLLocationCoordinate2D
    var wikipediaLink: URL?
    var photos: [URL]? = []
    var website: String?
    
    //compatibility
    var rating: Double? = 3.0
    var userRatingsTotal: Int? = 1000
    
    
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
    
    init(gpPlace: GPPlace){
        self.placeID = gpPlace.placeID
        self.instance = "QPOPULARPLACE"
        self.name = gpPlace.name
        self.city = gpPlace.city
        self.location = gpPlace.location
        
        self.wikipediaLink = URL(string: "to retrieve")
        self.photos = []
        self.website = "to retrieve"
        
        self.rating = gpPlace.rating
        self.userRatingsTotal = gpPlace.userRatingsTotal
    }
    
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
        self.photos = try container.decodeIfPresent([URL].self, forKey: .photos)
        if self.photos == nil {
            self.photos = []
        }
        let imageURL = try container.decodeIfPresent(WDBinding.self, forKey: .imageURL)
        if let ciu = imageURL?.value {
            self.photos?.append(URL(string: ciu)!)
        }
        let wikipediaLink = try container.decodeIfPresent(WDBinding.self, forKey: .wikipediaLink)
        self.wikipediaLink = URL(string: wikipediaLink?.value ?? "")
        
        //let website = try container.decodeIfPresent(String.self, forKey: .website)
        //self.website = URL.init(string: website ?? "")
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
            try container.encode(cityBinding, forKey: .city)
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
