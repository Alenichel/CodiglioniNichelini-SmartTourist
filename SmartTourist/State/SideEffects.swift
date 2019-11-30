//
//  SideEffects.swift
//  SmartTourist
//
//  Created on 24/11/2019.
//

import Foundation
import Katana
import GooglePlaces


struct GetCurrentPlace: SideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, DependenciesContainer>) throws {
        if context.getState().locationState.lastUpdate.distance(to: Date()) > 30 {       // If last update occurred more than X seconds ago
            context.dispatch(SetLastUpdate(lastUpdate: Date()))
            context.dependencies.googleAPI.getNearbyAttractions().then { attractions in
                context.dispatch(SetCurrentPlace(places: attractions))
            }.catch { error in
                context.dispatch(SetCurrentPlace(places: []))
            }
        } else {
            context.dispatch(SetCurrentPlace(places: context.getState().locationState.nearestPlaces))
        }
    }
}


struct GetCurrentCity: SideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, DependenciesContainer>) throws {
        if let coordinates = context.getState().locationState.currentLocation {
            context.dependencies.googleAPI.getCityName(coordinates: coordinates).then { city in
                context.dispatch(SetCurrentCity(city: city))
            }.catch { error in
                context.dispatch(SetCurrentCity(city: nil))
            }
        }
    }
}
