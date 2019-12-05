//
//  AppState.swift
//  SmartTourist
//
//  Created on 23/11/2019.
//

import Foundation
import Katana
import GooglePlaces


// MARK: - State
struct AppState: State, Codable {
    var firstLaunch: Bool = true
    var locationState = LocationState()
    
    enum CodingKeys: CodingKey {    // Filter what properties to persist. I don't think it's necessary to persist locationState
        case firstLaunch
    }
    
    static var persistURL: URL {
        let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent("AppState.json")
    }
}


struct LocationState {
    var lastUpdate: Date = Date().advanced(by: TimeInterval(-60))
    var currentLocation: CLLocationCoordinate2D?
    var nearestPlaces: [GMSPlace] = [GMSPlace]()
    var currentCity: String?
}
