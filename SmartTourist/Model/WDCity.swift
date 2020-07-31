//
//  WDCity.swift
//  SmartTourist
//
//  Created on 20/04/2020
//

import UIKit
import Hydra
import FlagKit


class WDCity: Decodable {
    let city: String
    let country: String?
    let population: Double?
    let area: Double?
    let elevation: Double?
    let link: String?
    let facebookPageId: String?
    let facebookPlacesId: String?
    let instagramUsername: String?
    let twitterUsername: String?
    let countryCode: String?
    let countryFlagImage: UIImage?
    let cityLabel: String?
    let countryLabel: String?
    var photos: [URL] = [URL]()
    let wikipediaLink: String?
    
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
                case wikipediaLink
                
                case cityLabel
                case countryLabel
                case countryCode
                
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
        self.population = Double(population?.value ?? "nil")
        let area = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .area)
        self.area = Double(area?.value ?? "nil")
        let elevation = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .elevation)
        self.elevation = Double(elevation?.value ?? "nil")
        let link = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .link)
        self.link = link?.value
        let wikipediaLink = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .wikipediaLink)
        self.wikipediaLink = wikipediaLink?.value
        let facebookPageId = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .facebookPageId)
        self.facebookPageId = facebookPageId?.value
        let facebookPlacesId = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .facebookPlacesId)
        self.facebookPlacesId = facebookPlacesId?.value
        let instagramUsername = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .instagramUsername)
        self.instagramUsername = instagramUsername?.value
        let twitterUsername = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .twitterUsername)
        self.twitterUsername = twitterUsername?.value
        let imageURL = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .image)
        if let photoURL = imageURL?.value {
            self.photos.append(URL(string: photoURL)!)
        }
        let countryCode = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .countryCode)
        self.countryCode = countryCode?.value
        self.countryFlagImage = Flag(countryCode: self.countryCode!)?.image(style: .circle)
        let cityLabel = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .cityLabel)
        self.cityLabel = cityLabel?.value
        let countryLabel = try bindingsContainer.decodeIfPresent(WDBinding.self, forKey: .countryLabel)
        self.countryLabel = countryLabel?.value
        self.getPhotosURLs().then() {}      // This should be called from the view
    }
    
    @discardableResult func getPhotosURLs() -> Promise<Void> {
        let photosCountThreshold = 2
        return Promise<Void>(in: .utility) { resolve, reject, status in
            if let cityLabel = self.cityLabel, self.photos.count < photosCountThreshold {
                WikipediaAPI.shared.getImageUrls(from: cityLabel).then(in: .utility) { urls in
                    self.photos = Array(Set(self.photos).union(Set(urls)))
                    self.photos.removeAll(where: { $0.pathExtension == "svg" })
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
}
