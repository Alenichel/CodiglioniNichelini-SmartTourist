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

// IDEA: To throttle down requests to the Google API, we can add a `Date` property
// to store the time when the last API request was made: if the request was made
// less than X seconds ago, we can avoid to make a new request.
struct AppState: State {
    var firstLaunch: Bool = true
    var locationState = LocationState()
    var loading: Bool = false
}


struct LocationState {
    var lastUpdate: Date = Date().advanced(by: TimeInterval(-30))
    var currentLocation: CLLocationCoordinate2D?
    var currentPlace: GMSPlace?
}
