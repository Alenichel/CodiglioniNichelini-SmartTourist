//
//  AppState.swift
//  SmartTourist
//
//  Created on 23/11/2019.
//

import Foundation
import Katana
import CoreLocation


/// Main state of the app
struct AppState: State, Codable {
    var locationState = LocationState()
    var favorites = [WDPlace]()
    var settings = Settings()
    var pedometerState = PedometerState()
    var cache = Cache()
    var needToMoveMap = false
    
    /// Used to filter what properties of the state must be persisted
    enum CodingKeys: CodingKey {
        case favorites
        case settings
        case cache
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
    
    /// Current city details from WikiData
    var wdCity: WDCity?
    
    /// The nearest places to `currentLocation`
    var nearestPlaces: [WDPlace] = [WDPlace]()
    
    /// The last update of `nearestPlaces`
    var nearestPlacesLastUpdate: Date = initDate
    
    /// The most popular places in `currentCity`
    var popularPlaces: [WDPlace] = [WDPlace]()
    
    /// The last update of `popularPlaces`
    var popularPlacesLastUpdate: Date = initDate
    
    /// `Date` used to initialize all the `lastUpdate` variables
    private static var initDate: Date {
        Date().advanced(by: TimeInterval(-60))
    }
}


/// The part of the state concering settings
struct Settings: Codable {
    /// Whether or not the app should send notifications when the user is near a top attraction
    var notificationsEnabled: Bool = true
    var maxRadius: Double = 1
    var maxNAttractions: Int = 150
    var poorEntitiesEnabled: Bool = true
}


/// The part of the state cencerning pedometer results
struct PedometerState: Codable {
    var averageWalkingSpeed: Double {   // m/s
        didSet {
            self.littleCircleRadius = self.averageWalkingSpeed * PedometerHandler.littleCircleTimeRadius
            self.bigCircleRadius = self.averageWalkingSpeed * PedometerHandler.bigCircleTimeRadius
        }
    }
    
    var littleCircleRadius: Double  // meters
    var bigCircleRadius: Double     // meters
    
    init() {
        self.averageWalkingSpeed = PedometerHandler.defaultAverageWalkingSpeed
        self.littleCircleRadius = self.averageWalkingSpeed * PedometerHandler.littleCircleTimeRadius
        self.bigCircleRadius = self.averageWalkingSpeed * PedometerHandler.bigCircleTimeRadius
    }
}


/// The part of the state where items are cached (popular places for now)
struct Cache: Codable {
    var popularPlaces: [String: [WDPlace]] = [String: [WDPlace]]()
}
