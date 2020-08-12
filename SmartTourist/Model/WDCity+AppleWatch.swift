//
//  WDCity+AppleWatch.swift
//  SmartTouristAppleWatch Extension
//
//  Created on 12/08/2020
//

import Foundation


// Required because WikipediaAPI has some methods that handle WDCity, but they are not required on Apple Watch
class WDCity: Codable {
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
    let cityLabel: String?
    let countryLabel: String?
    var photos: [URL] = [URL]()
    let wikipediaLink: String?
}
