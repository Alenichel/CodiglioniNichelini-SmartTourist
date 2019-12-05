//
//  StateUpdaters.swift
//  SmartTourist
//
//  Created on 24/11/2019.
//

import Foundation
import Katana
import GooglePlaces


struct SetState: StateUpdater {
    let state: AppState
    
    func updateState(_ state: inout AppState) {
        state.locationState = self.state.locationState
    }
}


struct SetLastUpdate: StateUpdater {
    let lastUpdate: Date
    
    func updateState(_ state: inout AppState) {
        state.locationState.lastUpdate = lastUpdate
    }
}


struct SetCurrentLocation: StateUpdater {
    let location: CLLocationCoordinate2D?
    
    func updateState(_ state: inout AppState) {
        state.locationState.currentLocation = location
    }
}


struct SetCurrentPlace: StateUpdater {
    let places: [GMSPlace]
    
    func updateState(_ state: inout AppState) {
        state.locationState.nearestPlaces = places
    }
}


struct SetCurrentCity: StateUpdater {
    let city: String?
    
    func updateState(_ state: inout AppState) {
        state.locationState.currentCity = city
    }
}
