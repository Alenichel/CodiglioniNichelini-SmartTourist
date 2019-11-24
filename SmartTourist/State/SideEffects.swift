//
//  SideEffects.swift
//  SmartTourist
//
//  Created by Fabio Codiglioni on 24/11/2019.
//  Copyright © 2019 Fabio Codiglioni. All rights reserved.
//

import Foundation
import Katana
import GooglePlaces


struct GetCurrentPlace: SideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, DependenciesContainer>) throws {
        context.dispatch(SetLoading())
        context.dependencies.placesAPI.getNearbyAttractions().then { attractions in
            if let place = attractions.first, let placeName = place.name {
                context.dispatch(SetCurrentPlace(place: placeName))
            } else {
                context.dispatch(SetCurrentPlace(place: nil))
            }
        }.catch { error in
            context.dispatch(SetCurrentPlace(place: nil))
        }
    }
}
