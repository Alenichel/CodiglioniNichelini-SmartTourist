//
//  StateUpdaters.swift
//  SmartTourist
//
//  Created on 24/11/2019.
//

import Foundation
import Katana
import GooglePlaces


struct SetCurrentPlace: StateUpdater {
    let place: GMSPlace?
    
    func updateState(_ state: inout AppState) {
        state.currentPlace = place
        state.loading = false
    }
}


struct SetLoading: StateUpdater {
    func updateState(_ state: inout AppState) {
        state.currentPlace = nil
        state.loading = true
    }
}


struct SetFirstLaunch: StateUpdater {
    func updateState(_ state: inout AppState) {
        state.firstLaunch = false
    }
}
