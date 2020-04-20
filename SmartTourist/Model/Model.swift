//
//  Model.swift
//  SmartTourist
//
//  Created on 19/12/2019
//

import UIKit
import CoreLocation
import Hydra


/*
 * THIS IS STUFF THAT PROBABLY NEEDS TO BE REMOVED
 */


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
