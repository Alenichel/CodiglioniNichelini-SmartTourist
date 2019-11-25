//
//  AppState.swift
//  SmartTourist
//
//  Created on 23/11/2019.
//

import Foundation
import Katana

// MARK: - State
struct AppState: State {
    var firstLaunch: Bool = true
    var currentPlace: String?
    var loading: Bool = false
    var welcomeState = WelcomeState()
}


struct WelcomeState {
    var screenIndex: Int = 0
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
