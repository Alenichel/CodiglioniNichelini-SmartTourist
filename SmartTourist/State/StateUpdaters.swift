//
//  StateUpdaters.swift
//  SmartTourist
//
//  Created on 24/11/2019.
//

import Foundation
import Katana
import GooglePlaces


struct SetFirstLaunch: StateUpdater {
    func updateState(_ state: inout AppState) {
        state.firstLaunch = false
    }
}


struct SetCurrentLocation: StateUpdater {
    let location: CLLocationCoordinate2D?
    
    func updateState(_ state: inout AppState) {
        state.locationState.currentLocation = location
    }
}


struct SetCurrentPlace: StateUpdater {
    let place: GMSPlace?
    
    func updateState(_ state: inout AppState) {
        state.locationState.currentPlace = place
        state.loading = false
    }
}


struct SetLoading: StateUpdater {
    func updateState(_ state: inout AppState) {
        state.locationState.currentPlace = nil
        state.loading = true
    }
}


struct SetLastUpdate: StateUpdater {
    let lastUpdate: Date
    
    func updateState(_ state: inout AppState) {
        state.locationState.lastUpdate = lastUpdate
    }
}
