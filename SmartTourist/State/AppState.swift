//
//  AppState.swift
//  SmartTourist
//
//  Created on 23/11/2019.
//

import Foundation
import Katana
import CoreLocation


// MARK: - State
struct AppState: State, Codable {
    var locationState = LocationState()
    var favorites = [GPPlace]()
    
    enum CodingKeys: CodingKey {    // Filter what properties to persist
        case favorites
    }
    
    static var persistURL: URL {
        let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent("AppState.json")
    }
}


struct LocationState {
    var currentLocation: CLLocationCoordinate2D?
    
    var currentCity: String?
    var currentCityLastUpdate: Date = initDate

    var nearestPlaces: [GPPlace] = [GPPlace]()
    var nearestPlacesLastUpdate: Date = initDate

    var popularPlaces: [GPPlace] = [GPPlace]()
    var popularPlacesLastUpdate: Date = initDate
    
    private static var initDate: Date {
        Date().advanced(by: TimeInterval(-60))
    }
}
