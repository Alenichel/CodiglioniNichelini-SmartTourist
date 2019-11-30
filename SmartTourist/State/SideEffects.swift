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
        let lastUpdate = context.getState().locationState.lastUpdate
        if lastUpdate.distance(to: Date()) > 30 {       // If last update occurred more than X seconds ago
            context.dispatch(SetLastUpdate(lastUpdate: Date()))
            context.dependencies.googleAPI.getNearbyAttractions().then { attractions in
                if let place = attractions.first {
                    context.dispatch(SetCurrentPlace(place: place))
                } else {
                    context.dispatch(SetCurrentPlace(place: nil))
                }
            }.catch { error in
                context.dispatch(SetCurrentPlace(place: nil))
            }
        } else {
            context.dispatch(SetCurrentPlace(place: context.getState().locationState.currentPlace))
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
