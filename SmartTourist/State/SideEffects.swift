//
//  SideEffects.swift
//  SmartTourist
//
//  Created on 24/11/2019.
//

import Foundation
import Katana
import CoreLocation
import Hydra

struct LoadState: SideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, DependenciesContainer>) throws {
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: AppState.persistURL)
            let state = try decoder.decode(AppState.self, from: data)
            context.dispatch(SetState(state: state))
            print("Loaded state from \(AppState.persistURL)")
        } catch {
            print("Error while decoding JSON: \(error.localizedDescription)")
        }
    }
}


struct GetCurrentCity: SideEffect {
    let throttle: Bool
    
    func sideEffect(_ context: SideEffectContext<AppState, DependenciesContainer>) throws {
        guard let coordinates = context.getState().locationState.currentLocation else { return }
        if !self.throttle || context.getState().locationState.currentCityLastUpdate.distance(to: Date()) > GoogleAPI.apiThrottleTime {
            context.dispatch(SetCurrentCityLastUpdate(lastUpdate: Date()))
            context.dependencies.googleAPI.getCityName(coordinates: coordinates).then { city in
                context.dispatch(SetCurrentCity(city: city))
                context.dispatch(GetPopularPlaces(city: city, throttle: self.throttle))
            }.catch { error in
                context.dispatch(SetCurrentCity(city: nil))
            }
        }
    }
}

struct GetNearestPlaces: SideEffect {
    let throttle: Bool
    
    func sideEffect(_ context: SideEffectContext<AppState, DependenciesContainer>) throws {
        guard let currentLocation = context.getState().locationState.currentLocation else { return }
        guard let actualLocation = context.getState().locationState.actualLocation else { return }
        if !self.throttle || context.getState().locationState.nearestPlacesLastUpdate.distance(to: Date()) > GoogleAPI.apiThrottleTime {
            context.dispatch(SetNearestPlacesLastUpdate(lastUpdate: Date()))
            let currentPlaces = try await(context.dependencies.googleAPI.getNearbyPlaces(location: currentLocation))
            let actualPlaces = try await(context.dependencies.googleAPI.getNearbyPlaces(location: actualLocation))
            let places = Set(currentPlaces + actualPlaces)
            context.dispatch(SetNearestPlaces(places: blacklist(Array(places))))
        }
    }
}


struct GetPopularPlaces: SideEffect {
    let city: String?
    let throttle: Bool
    
    func sideEffect(_ context: SideEffectContext<AppState, DependenciesContainer>) throws {
        guard let currentCity = self.city else { return }
        if !self.throttle || context.getState().locationState.popularPlacesLastUpdate.distance(to: Date()) > GoogleAPI.apiThrottleTime {
            context.dispatch(SetPopularPlacesLastUpdate(lastUpdate: Date()))
            context.dependencies.googleAPI.getPopularPlaces(city: currentCity).then { places in
                context.dispatch(SetPopularPlaces(places: blacklist(places)))
            }.catch { error in
                context.dispatch(SetPopularPlaces(places: []))
            }
        }
    }
}


struct AddFavorite: SideEffect {
    let place: GPPlace
    
    func sideEffect(_ context: SideEffectContext<AppState, DependenciesContainer>) throws {
        context.dependencies.googleAPI.getCityNameMK(coordinates: self.place.location).then { city in
            self.place.city = city
        }.catch { error in
            print(error.localizedDescription)
            if let currentCity = context.getState().locationState.currentCity {
                self.place.city = currentCity
            }
        }.always {
            context.dispatch(AddFavoriteStateUpdater(place: self.place))
        }
    }
}
