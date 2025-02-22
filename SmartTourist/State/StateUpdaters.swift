//
//  StateUpdaters.swift
//  SmartTourist
//
//  Created on 24/11/2019.
//

import Foundation
import Katana
import CoreLocation


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


struct SetNearestPlaces: StateUpdater {
    let places: [WDPlace]
    
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
    let places: [WDPlace]
    
    func updateState(_ state: inout AppState) {
        state.locationState.popularPlaces = places
    }
}


struct AddFavoriteStateUpdater: StateUpdater, Persistable {
    let place: WDPlace
    
    func updateState(_ state: inout AppState) {
        state.favorites.sortedInsert(place)
    }
}


struct RemoveFavorite: StateUpdater, Persistable {
    let place: WDPlace
    
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

struct SetPoorEntitiesEnabled: StateUpdater, Persistable {
    let value: Bool
    
    func updateState(_ state: inout AppState) {
        state.settings.poorEntitiesEnabled = value
    }
}

struct SetMaxRadius: StateUpdater, Persistable {
    let value: Double
    
    func updateState(_ state: inout AppState) {
        state.settings.maxRadius = value
    }
}

struct SetMaxNAttractions: StateUpdater, Persistable {
    let value: Int
    
    func updateState(_ state: inout AppState) {
        state.settings.maxNAttractions = value
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


struct SetWDCity: StateUpdater {
    let city: WDCity?
    
    func updateState(_ state: inout AppState) {
        state.locationState.wdCity = self.city
    }
}


struct UpdatePopularPlacesCache: StateUpdater, Persistable {
    let city: String
    let places: [WDPlace]
    
    func updateState(_ state: inout AppState) {
        state.cache.popularPlaces[city] = places
        state.cache.popularPlacesUpdate[city] = Date()
    }
}


struct ClearPopularPlacesCache: StateUpdater, Persistable {
    func updateState(_ state: inout AppState) {
        state.cache.popularPlaces = [String: [WDPlace]]()
        state.cache.popularPlacesUpdate = [String: Date]()
    }
}
