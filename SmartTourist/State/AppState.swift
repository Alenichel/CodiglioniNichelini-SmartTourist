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
struct AppState: State {
    var firstLaunch: Bool = true
    var locationState = LocationState()
}


struct LocationState {
    var lastUpdate: Date = Date().advanced(by: TimeInterval(-60))
    var currentLocation: CLLocationCoordinate2D?
    var currentPlaces: GMSPlace?
    var currentCity: String?
}
