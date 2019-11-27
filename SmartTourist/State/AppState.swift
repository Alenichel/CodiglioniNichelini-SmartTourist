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
}
