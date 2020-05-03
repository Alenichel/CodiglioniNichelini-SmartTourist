//
//  WDPlace.swift
//  SmartTourist
//
//  Created on 20/04/2020
//

import Foundation
import CoreLocation
import Hydra


class WDPlace: Codable, Hashable, Comparable {
    var placeID: String
    var instance: String
    var name: String
    var wikipediaName: String?
    var city: String?
    var location: CLLocationCoordinate2D
    var wikipediaLink: String?
    var photos: [URL]? = []
    var website: String?
    var phoneNumber: String?
    var rating: Double? = 0
    var userRatingsTotal: Int? = 0
    
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
        case phoneNumber = "phoneNumber"
        
        enum ValueCodingKeys: CodingKey {
            case value
        }
    }
        
    init(gpPlace: GPPlace) {
        let base = "Q01234567890"
        self.placeID = base + "\(abs(gpPlace.placeID.hash))"
        self.instance = base
        self.name = gpPlace.name
        self.city = gpPlace.city
        self.location = gpPlace.location
        self.wikipediaName = "to retrieve"
        self.wikipediaLink = "to retrieve"
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
        self.wikipediaLink = wikipediaLink?.value
        if let wlink = self.wikipediaLink {
            self.wikipediaName = wlink.components(separatedBy: "/").last ?? "No valid name found"
        }
        if let web = try container.decodeIfPresent(WDBinding.self, forKey: .website){
            self.website = web.value
        }
        if let phoneNumber = try container.decodeIfPresent(WDBinding.self, forKey: .phoneNumber){
            self.phoneNumber = phoneNumber.value
        }
        if let rating = try container.decodeIfPresent(WDBinding.self, forKey: .rating),
            let urt = try container.decodeIfPresent(WDBinding.self, forKey: .userRatingsTotal) {
            self.rating = Double(rating.value)
            self.userRatingsTotal = Int(urt.value)
        }
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
            let wikipediaLinkBinding = WDBinding(value: wikipediaLink)
            try container.encode(wikipediaLinkBinding, forKey: .wikipediaLink)
        }
        try container.encode(self.photos, forKey: .photos)
        if let rating = self.rating, let urt = self.userRatingsTotal {
            let ratingBinding = WDBinding(value: String(rating))
            try container.encode(ratingBinding, forKey: .rating)
            let urtBinding = WDBinding(value: String(urt))
            try container.encode(urtBinding, forKey: .userRatingsTotal)
        }
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
    
    @discardableResult func getPhotosURLs() -> Promise<Void> {
        let photosCountThreshold = 2
        return Promise<Void>(in: .utility) { resolve, reject, status in
            if let photos = self.photos, photos.count < photosCountThreshold {
                WikipediaAPI.shared.getImageUrls(from: self.name).then(in: .utility) { urls in
                    if let photos = self.photos {
                        self.photos = Array(Set(photos).union(Set(urls)))
                    } else {
                        self.photos = Array(Set(urls))
                    }
                    self.photos?.removeAll(where: { $0.pathExtension == "svg" })
                    resolve(())
                }.catch(in: .utility) { error in
                    print(error.localizedDescription)
                    reject(error)
                }
            } else {
                resolve(())
            }
        }
    }
    
    @discardableResult func getMissingDetails() -> Promise<Void> {
        return Promise<Void>(in: .utility) { resolve, reject, status in
            WikipediaAPI.shared.findExactArticleName(searchTerms: self.name, coordinates: self.location).then(in: .utility) { name in
                self.wikipediaName = name
                if let wname = self.wikipediaName {
                    self.wikipediaLink = "https://en.wikipedia.org/wiki/" + wname.replacingOccurrences(of: " ", with: "_")
                    WikipediaAPI.shared.getWikidataId(title: wname).then(in: .utility) { id in
                        self.placeID = id
                        WikipediaAPI.shared.getMissingDetail(place: self).then(in: .utility) {
                            resolve(())
                        }.catch(in: .utility) { error in
                            print(error.localizedDescription)
                            //reject(error)
                            resolve(())
                        }
                    }.catch(in: .utility) { error in
                        print(error.localizedDescription)
                        //reject(error)
                        resolve(())
                    }
                } else {
                    return
                }
            }.catch(in: .utility) { error in
                print(self.name)
                print(error.localizedDescription)
                //reject(error)
                resolve(())
            }
        }
    }
}
