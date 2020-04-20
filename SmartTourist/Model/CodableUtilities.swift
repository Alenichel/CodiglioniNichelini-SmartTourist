//
//  CodableUtilities.swift
//  SmartTourist
//
//  Created on 20/04/2020
//

import Foundation


struct WDBinding: Codable {
    let value: String
    
    enum CodingKeys: CodingKey {
        case value
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
