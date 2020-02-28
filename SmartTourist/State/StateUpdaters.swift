//
//  StateUpdaters.swift
//  SmartTourist
//
//  Created on 24/11/2019.
//

import Foundation
import Katana
import CoreLocation


struct SetState: StateUpdater {
    let state: AppState
    
    func updateState(_ state: inout AppState) {
        state.locationState = self.state.locationState
        state.favorites = self.state.favorites
    }
}


struct SetActualLocation: StateUpdater {
    let location: CLLocationCoordinate2D?
    
    func updateState(_ state: inout AppState) {
        state.locationState.actualLocation = location
    }
}


struct SetMapLocation: StateUpdater {
    let location: CLLocationCoordinate2D?
    
    func updateState(_ state: inout AppState) {
        state.locationState.mapLocation = location
    }
}


struct SetMapCentered: StateUpdater {
    let value: Bool
    
    func updateState(_ state: inout AppState) {
        state.locationState.mapCentered = value
    }
}


struct SetCurrentCity: StateUpdater {
    let city: String?
    
    func updateState(_ state: inout AppState) {
        state.locationState.actualCity = city
    }
}


struct SetCurrentCityLastUpdate: StateUpdater {
    let lastUpdate: Date
    
    func updateState(_ state: inout AppState) {
        state.locationState.actualCityLastUpdate = lastUpdate
    }
}


struct SetNearestPlaces: StateUpdater {
    let places: [GPPlace]
    
    func updateState(_ state: inout AppState) {
        state.locationState.nearestPlaces = places
    }
}


struct SetNearestPlacesLastUpdate: StateUpdater {
    let lastUpdate: Date
    
    func updateState(_ state: inout AppState) {
        state.locationState.nearestPlacesLastUpdate = lastUpdate
    }
}


struct SetPopularPlaces: StateUpdater {
    let places: [GPPlace]
    
    func updateState(_ state: inout AppState) {
        state.locationState.popularPlaces = places
    }
}


struct SetPopularPlacesLastUpdate: StateUpdater {
    let lastUpdate: Date
    
    func updateState(_ state: inout AppState) {
        state.locationState.popularPlacesLastUpdate = lastUpdate
    }
}


struct AddFavorite: StateUpdater, Persistable {
    let place: GPPlace
    
    func updateState(_ state: inout AppState) {
        state.favorites.append(place)
    }
}


struct RemoveFavorite: StateUpdater, Persistable {
    let place: GPPlace
    
    func updateState(_ state: inout AppState) {
        state.favorites.removeAll(where: {$0 == place})
    }
}
