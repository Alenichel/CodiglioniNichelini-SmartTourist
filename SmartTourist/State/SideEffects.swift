//
//  SideEffects.swift
//  SmartTourist
//
//  Created on 24/11/2019.
//

import Foundation
import Katana
import CoreLocation


struct LoadState: SideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, DependenciesContainer>) throws {
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: AppState.persistURL)
            let state = try decoder.decode(AppState.self, from: data)
            context.dispatch(SetState(state: state))
            print("Loaded state from JSON")
        } catch {
            print("Error while decoding JSON")
            print(error.localizedDescription)
        }
    }
}


struct GetCurrentCity: SideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, DependenciesContainer>) throws {
        guard let coordinates = context.getState().locationState.currentLocation else { return }
        if context.getState().locationState.currentCityLastUpdate.distance(to: Date()) > timeBeforeNewApiCall {
            context.dispatch(SetCurrentCityLastUpdate(lastUpdate: Date()))
            context.dependencies.googleAPI.getCityName(coordinates: coordinates).then { city in
                context.dispatch(SetCurrentCity(city: city))
                context.dispatch(GetPopularPlaces(city: city))
            }.catch { error in
                context.dispatch(SetCurrentCity(city: nil))
            }
        }
    }
}


struct GetNearestPlaces: SideEffect {
    let location: CLLocationCoordinate2D?
    
    func sideEffect(_ context: SideEffectContext<AppState, DependenciesContainer>) throws {
        guard let currentLocation = self.location else { return }
        if context.getState().locationState.nearestPlacesLastUpdate.distance(to: Date()) > timeBeforeNewApiCall {
            context.dispatch(SetNearestPlacesLastUpdate(lastUpdate: Date()))
            context.dependencies.googleAPI.getNearbyPlaces(location: currentLocation).then { places in
                context.dispatch(SetNearestPlaces(places: places))
            }.catch { error in
                context.dispatch(SetNearestPlaces(places: []))
            }
        }
    }
}


struct GetPopularPlaces: SideEffect {
    let city: String?
    
    func sideEffect(_ context: SideEffectContext<AppState, DependenciesContainer>) throws {
        //guard let currentCity = context.getState().locationState.currentCity else { return }
        guard let currentCity = self.city else { return }
        if context.getState().locationState.popularPlacesLastUpdate.distance(to: Date()) > timeBeforeNewApiCall {
            context.dispatch(SetPopularPlacesLastUpdate(lastUpdate: Date()))
            context.dependencies.googleAPI.getPopularPlaces(city: currentCity).then { places in
                context.dispatch(SetPopularPlaces(places: places))
            }.catch { error in
                context.dispatch(SetPopularPlaces(places: []))
            }
        }
    }
}
