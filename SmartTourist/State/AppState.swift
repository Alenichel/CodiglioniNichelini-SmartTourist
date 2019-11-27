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
    var currentPlace: GMSPlace?
    var loading: Bool = false
    var welcomeState = WelcomeState()
}


struct WelcomeState {
    var labels: [String] = [
        "Welcome to Smart Tourist!",
        "In order to work properly, Smart Tourist needs your location.",
        "In order to offer timely information, Smart Tourist needs to send you notifications."
    ]
    var buttons: [String] = [
        "Next",
        "Location",
        "Notifications"
    ]
}
