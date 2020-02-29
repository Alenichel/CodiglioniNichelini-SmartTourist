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
/// Main state of the app
struct AppState: State, Codable {
    var locationState = LocationState()
    var favorites = [GPPlace]()
    var needToMoveMap = false
    
    /// Used to filter what properties of the state must be persisted
    enum CodingKeys: CodingKey {
        case favorites
    }
    
    /// The path where to persist the state
    static var persistURL: URL {
        let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent("AppState.json")
    }
}


/// The part of the state concerning location
struct LocationState {
    /// The actual location of the user
    var actualLocation: CLLocationCoordinate2D?
    
    /// The current location of the map
    var mapLocation: CLLocationCoordinate2D?
    
    /// The used location, selected based on whether the map is centered or not
    var currentLocation: CLLocationCoordinate2D? {
        self.mapCentered ? self.actualLocation : self.mapLocation
    }
    
    /// Whether the map is centered on the actual user location or not
    var mapCentered: Bool = true
    
    /// The current city displayed on the map, based on `currentLocation`
    var currentCity: String?
    
    /// Last update of `currentCity`
    var currentCityLastUpdate: Date = initDate
    
    /// The nearest places to `currentLocation`
    var nearestPlaces: [GPPlace] = [GPPlace]()
    
    /// The last update of `nearestPlaces`
    var nearestPlacesLastUpdate: Date = initDate
    
    /// The most popular places in `currentCity`
    var popularPlaces: [GPPlace] = [GPPlace]()
    
    /// The last update of `popularPlaces`
    var popularPlacesLastUpdate: Date = initDate
    
    /// `Date` used to initialize all the `lastUpdate` variables
    private static var initDate: Date {
        Date().advanced(by: TimeInterval(-60))
    }
}
