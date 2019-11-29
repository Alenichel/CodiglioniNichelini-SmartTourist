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
    var loading: Bool = false
}


struct LocationState {
    var lastUpdate: Date = Date()
    var currentLocation: CLLocationCoordinate2D?
    var currentPlace: GMSPlace?
    var currentCity: String?
}
