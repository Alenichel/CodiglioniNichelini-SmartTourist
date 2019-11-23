//
//  AppState.swift
//  SmartTourist
//
//  Created by Fabio Codiglioni & Alessandro Nichelini on 23/11/2019.
//  Copyright © 2019 Fabio Codiglioni. All rights reserved.
//

import Foundation
import Katana

// MARK: - State
struct AppState: State {
    var username: String
    var currentCity: String?
    var currentLocation: Location?
    var nearPlaces: [Place]
    
    init() {
        username = ""
        currentCity = nil
        currentLocation = nil
        nearPlaces = []
    }
}

// MARK: - Actions
// Must be pure

struct SetCurrentCity: StateUpdater {
    let newName: String
    
    func updateState(_ state: inout AppState ) {
        state.currentCity = newName
    }
}

struct SetCurrentLocation: StateUpdater {
    let newLocation: Location
    
    func updateState(_ state: inout AppState) {
        state.currentLocation = newLocation
    }
}

struct AddPlace: StateUpdater {
    let place: Place
    
    func updateState(_ state: inout AppState) {
        state.nearPlaces.append(place)
    }
}

struct RemovePlace: StateUpdater {
    let place: Place
    
    func updateState(_ state: inout AppState) {
        state.nearPlaces.removeAll(where: {$0 == place})
    }
}
