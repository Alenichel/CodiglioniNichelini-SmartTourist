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
        state.settings = self.state.settings
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
        state.locationState.currentCity = city
    }
}


struct SetCurrentCityLastUpdate: StateUpdater {
    let lastUpdate: Date
    
    func updateState(_ state: inout AppState) {
        state.locationState.currentCityLastUpdate = lastUpdate
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


struct AddFavoriteStateUpdater: StateUpdater, Persistable {
    let place: GPPlace
    
    func updateState(_ state: inout AppState) {
        state.favorites.sortedInsert(place)
    }
}


struct RemoveFavorite: StateUpdater, Persistable {
    let place: GPPlace
    
    func updateState(_ state: inout AppState) {
        place.city = nil
        state.favorites.removeAll(where: {$0 == place})
    }
}


struct SetNeedToMoveMap: StateUpdater {
    let value: Bool
    
    func updateState(_ state: inout AppState) {
        state.needToMoveMap = value
    }
}


struct SetNotificationsEnabled: StateUpdater, Persistable {
    let value: Bool
    
    func updateState(_ state: inout AppState) {
        state.settings.notificationsEnabled = value
    }
}


struct SetPedometerAverageWalkingSpeed: StateUpdater {
    let newSpeed: Double
    
    func updateState(_ state: inout AppState) {
        state.pedometerState.averageWalkingSpeed = self.newSpeed
        print("New average walking speed is \(state.pedometerState.averageWalkingSpeed)")
        print("New littleCircleRadius is \(state.pedometerState.littleCircleRadius)")
        print("New bigCircleRadius is \(state.pedometerState.littleCircleRadius)")
    }
}
