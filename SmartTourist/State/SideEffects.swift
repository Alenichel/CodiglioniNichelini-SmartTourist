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
        if let lastUpdate = context.getState().locationState.lastUpdate {
            let diff = Date().distance(to: lastUpdate)
            if abs(diff) > 15 {
                context.dependencies.placesAPI.getNearbyAttractions().then { attractions in
                    if let place = attractions.first {
                        context.dispatch(SetCurrentPlace(place: place))
                    } else {
                        context.dispatch(SetCurrentPlace(place: nil))
                    }
                    context.dispatch(SetLastUpdate(lastUpdate: Date()))
                }.catch { error in
                    context.dispatch(SetCurrentPlace(place: nil))
                }
            }
        }
    }
}
