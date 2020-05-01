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
            context.dependencies.wikiAPI.getNearbyPlaces(location: currentLocation).then(in: .utility) { places in
                let placesSet = Array(Set(places))
                let sortedPlaces = placesSet.sorted(by: { $0.distance(from: currentLocation) < $1.distance(from: currentLocation) })
                context.dispatch(SetNearestPlaces(places: sortedPlaces))
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
            context.dependencies.googleAPI.getPopularPlaces(city: currentCity).then(in: .background) { places in
                let converted = places.map { WDPlace(gpPlace: $0) }
                let promises = converted.map { $0.getMissingDetails() }
                all(promises).then(in: .utility) { _ in
                    let places = converted.filter { place in
                        guard let photos = place.photos else { return false }
                        return !photos.isEmpty
                    }
                    context.dispatch(SetPopularPlaces(places: places))
                    context.dispatch(UpdatePopularPlacesCache(city: currentCity, places: places))
                }.catch(in: .utility) { error in
                    print(error.localizedDescription)
                }
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
        guard let cityName = context.getState().locationState.currentCity else { return }
        
        WikipediaAPI.shared.getWikidataId(title: cityName).then(
            WikipediaAPI.shared.getCityDetail
        ).then(in: .utility){city in
            context.dispatch(SetWDCity(city: city))
        }
    }
}
