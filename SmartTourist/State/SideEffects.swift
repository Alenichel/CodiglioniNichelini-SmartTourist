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
        context.dispatch(SetLoading())
        let lastUpdate = context.getState().locationState.lastUpdate
        if lastUpdate.distance(to: Date()) > 30 {       // If last update occurred more than X seconds ago
            context.dependencies.placesAPI.getNearbyAttractions().then { attractions in
                if let place = attractions.first {
                    context.dispatch(SetCurrentPlace(place: place))
                } else {
                    context.dispatch(SetCurrentPlace(place: nil))
                }
            }.catch { error in
                context.dispatch(SetCurrentPlace(place: nil))
            }.always {
                context.dispatch(SetLastUpdate(lastUpdate: Date()))
            }
        } else {
            context.dispatch(SetCurrentPlace(place: context.getState().locationState.currentPlace))
        }
    }
}
