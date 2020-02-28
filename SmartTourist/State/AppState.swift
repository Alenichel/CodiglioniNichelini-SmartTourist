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
    var actualLocation: CLLocationCoordinate2D?
    var mapLocation: CLLocationCoordinate2D?
    var selectedLocation: CLLocationCoordinate2D?
    
    var mapCentered: Bool = true
    
    var currentLocation: CLLocationCoordinate2D? {
        self.mapCentered ? self.actualLocation : self.mapLocation
    }
    
    var currentCity: String?
    var currentCityLastUpdate: Date = initDate
    var selectedCity: String?

    var nearestPlaces: [GPPlace] = [GPPlace]()
    var nearestPlacesLastUpdate: Date = initDate

    var popularPlaces: [GPPlace] = [GPPlace]()
    var popularPlacesLastUpdate: Date = initDate
    
    private static var initDate: Date {
        Date().advanced(by: TimeInterval(-60))
    }
}
