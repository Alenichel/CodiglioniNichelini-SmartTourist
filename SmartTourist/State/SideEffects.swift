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
        print("Attempting to load state from \(AppState.persistURL)")
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: AppState.persistURL)
            let state = try decoder.decode(AppState.self, from: data)
            context.dispatch(SetState(state: state))
            print("State loaded") // from \(AppState.persistURL)")
        } catch {
            print("\(#function): \(error.localizedDescription)")
        }
    }
}


struct GetCurrentCity: SideEffect {
    let throttle: Bool
    
    func sideEffect(_ context: SideEffectContext<AppState, DependenciesContainer>) throws {
        guard let coordinates = context.getState().locationState.currentLocation else { return }
        context.dependencies.mapsAPI.getCityName(coordinates: coordinates).then(in: .utility) { city in
            context.dispatch(SetCurrentCity(city: city))
            context.dispatch(GetPopularPlaces(city: city, throttle: self.throttle))
        }.catch(in: .utility) { error in
            context.dispatch(SetCurrentCity(city: nil))
        }
    }
}


struct GetNearestPlaces: SideEffect {
    let throttle: Bool
    
    func sideEffect(_ context: SideEffectContext<AppState, DependenciesContainer>) throws {
        guard let currentLocation = context.getState().locationState.currentLocation else { return }
        if !self.throttle || context.getState().locationState.nearestPlacesLastUpdate.distance(to: Date()) > GoogleAPI.apiThrottleTime {
            context.dispatch(SetNearestPlacesLastUpdate(lastUpdate: Date()))
            async(in: .utility) { _ -> [WDPlace] in
                var places = try await(context.dependencies.wikiAPI.getNearbyPlaces(location: currentLocation))
                if let actualLocation = context.getState().locationState.actualLocation {
                    let actualPlaces = try await(context.dependencies.wikiAPI.getNearbyPlaces(location: actualLocation))
                    places = Array(Set(places + actualPlaces))
                } else {
                    places = Array(Set(places))
                }
                return places.sorted(by: { $0.distance(from: currentLocation) < $1.distance(from: currentLocation) })
            }.then(in: .utility) { places in
                context.dispatch(SetNearestPlaces(places: places))
                WikipediaAPI.shared.getImageUrls(from: places[0].name).then(in: .utility) { urls in
                    print(urls)
                }.catch(in: .utility) { error in
                    print(error.localizedDescription)
                }
            }.catch(in: .utility) { error in
                print("\(#function): \(error.localizedDescription)")
                context.dispatch(SetNearestPlaces(places: []))
            }
        }
    }
}


struct GetPopularPlaces: SideEffect {
    let city: String?
    let throttle: Bool
    
    func sideEffect(_ context: SideEffectContext<AppState, DependenciesContainer>) throws {
        guard let currentCity = self.city else { return }
        let cachedPlaces = context.getState().cache.popularPlaces[currentCity]
        if let cachedPlaces = cachedPlaces {
            context.dispatch(SetPopularPlaces(places: cachedPlaces))
            print("POPULAR_PLACES: retrieved from cache")
        } else if !self.throttle || context.getState().locationState.popularPlacesLastUpdate.distance(to: Date()) > GoogleAPI.apiThrottleTime {
            print("POPULAR PLACES: attempting to download")
            context.dispatch(SetPopularPlacesLastUpdate(lastUpdate: Date()))
            context.dependencies.googleAPI.getPopularPlaces(city: currentCity).then(in: .utility) { places in
                let converted = places.map { WDPlace(gpPlace: $0) }
                context.dispatch(SetPopularPlaces(places: converted))
                context.dispatch(UpdatePopularPlacesCache(city: currentCity, places: converted))
            }.catch(in: .utility) { error in
                print("\(#function): \(error.localizedDescription)")
                context.dispatch(SetPopularPlaces(places: []))
            }
            context.dispatch(SetPopularPlaces(places: []))
        }
    }
}


struct AddFavorite: SideEffect {
    let place: WDPlace
    
    func sideEffect(_ context: SideEffectContext<AppState, DependenciesContainer>) throws {
        context.dependencies.mapsAPI.getCityName(coordinates: self.place.location).then(in: .utility) { city in
            self.place.city = city
        }.catch(in: .utility) { error in
            print("\(#function): \(error.localizedDescription)")
            if let currentCity = context.getState().locationState.currentCity {
                self.place.city = currentCity
            }
        }.always(in: .utility) {
            context.dispatch(AddFavoriteStateUpdater(place: self.place))
        }
    }
}


struct GetCityDetails: SideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, DependenciesContainer>) throws {
        //context.dispatch(SetGPCity(city: nil))
        context.dispatch(SetWDCity(city: nil))
        /*guard let city = context.getState().locationState.currentCity else { return }
        context.dependencies.googleAPI.getCityPlace(city: city).then(in: .utility) { places in
            guard let place = places.first else { return }
            context.dispatch(SetGPCity(city: place))
        }*/
        // TODO: WikiData
    }
}
