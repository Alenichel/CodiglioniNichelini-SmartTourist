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


struct GetCurrentCity: SideEffect {
    func sideEffect(_ context: SideEffectContext<AppState, DependenciesContainer>) throws {
        guard let coordinates = context.getState().locationState.currentLocation else { return }
        context.dependencies.mapsAPI.getCityName(coordinates: coordinates).then(in: .utility) { city in
            context.dispatch(SetCurrentCity(city: city))
            context.dispatch(GetPopularPlaces(city: city))
        }.catch(in: .utility) { error in
            context.dispatch(SetCurrentCity(city: nil))
        }
    }
}


struct GetNearestPlaces: SideEffect {
    let throttle: Bool
    
    func sideEffect(_ context: SideEffectContext<AppState, DependenciesContainer>) throws {
        guard let currentLocation = context.getState().locationState.currentLocation else { return }
        if !self.throttle || context.getState().locationState.nearestPlacesLastUpdate.distance(to: Date()) > WikipediaAPI.apiThrottleTime {
            context.dispatch(SetNearestPlacesLastUpdate(lastUpdate: Date()))
            var nPlaces = 0
            var distance : Double = 1
            var roundPlaces : [WDPlace] = []
            while nPlaces < 50 && distance <= context.getState().settings.maxRadius {
                roundPlaces = try await(context.dependencies.wikiAPI.getNearbyPlaces(location: currentLocation, radius: Int(distance), isArticleMandatory: true))
                nPlaces = roundPlaces.count
                distance = distance * 2
            }
            if nPlaces < 50 {
                roundPlaces = try await(context.dependencies.wikiAPI.getNearbyPlaces(location: currentLocation, radius: Int(distance), isArticleMandatory: false))
            }
            var sortedPlaces = Set(roundPlaces).sorted(by: { $0.distance(from: currentLocation) < $1.distance(from: currentLocation) })
            if !context.getState().settings.poorEntitiesEnabled {
                sortedPlaces = sortedPlaces.filter({ $0.wikipediaLink != nil})
            }
            let nearestPlaces = Array(sortedPlaces.prefix(context.getState().settings.maxNAttractions))
            let augmentPromises = nearestPlaces.map { place in
                return Promise<Void>(in: .utility) { resolve, reject, status in
                    let popularPlace = context.getState().locationState.popularPlaces.first(where: { $0 == place })
                    if let popularPlace = popularPlace {
                        place.augment(with: popularPlace)
                    }
                    resolve(())
                }
            }
            all(augmentPromises).then(in: .utility) { _ in
                context.dispatch(SetNearestPlaces(places: nearestPlaces))
            }
        }
    }
}


struct GetPopularPlaces: SideEffect {
    let city: String?
    
    func sideEffect(_ context: SideEffectContext<AppState, DependenciesContainer>) throws {
        guard let currentCity = self.city else { return }
        let cachedPlaces = context.getState().cache.popularPlaces[currentCity]
        let cachedPlacesUpdate = context.getState().cache.popularPlacesUpdate[currentCity]
        if let cachedPlaces = cachedPlaces, let cachedPlacesUpdate = cachedPlacesUpdate, cachedPlacesUpdate.distance(to: Date()) < context.getState().cache.ttl {
            context.dispatch(SetPopularPlaces(places: cachedPlaces))
            print("POPULAR_PLACES: retrieved from cache")
        } else {
            print("POPULAR PLACES: attempting to download")
            context.dependencies.googleAPI.getPopularPlaces(city: currentCity).then(in: .background) { places in
                let converted = places.map { WDPlace(gpPlace: $0) }
                let promises = converted.map { $0.getMissingDetails() }
                all(promises).then(in: .utility) { _ in
                    let popularPlaces = converted.filter { place in
                        guard let photos = place.photos else { return false }
                        return !photos.isEmpty
                    }
                    let augmentPromises = popularPlaces.map { place in
                        return Promise<Void>(in: .utility) { resolve, reject, status in
                            let nearestPlace = context.getState().locationState.nearestPlaces.first(where: { $0 == place })
                            if let nearestPlace = nearestPlace {
                                place.augment(with: nearestPlace)
                            }
                            resolve(())
                        }
                    }
                    all(augmentPromises).then(in: .utility) { _ in
                        context.dispatch(SetPopularPlaces(places: popularPlaces))
                        context.dispatch(UpdatePopularPlacesCache(city: currentCity, places: popularPlaces))
                    }
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
            let popularPlace = context.getState().locationState.popularPlaces.first(where: { $0 == self.place })
            let nearestPlace = context.getState().locationState.nearestPlaces.first(where: { $0 == self.place })
            if let popularPlace = popularPlace {
                self.place.augment(with: popularPlace)
            }
            if let nearestPlace = nearestPlace {
                self.place.augment(with: nearestPlace)
            }
            context.dispatch(AddFavoriteStateUpdater(place: self.place))
        }
    }
}


struct GetCityDetails: SideEffect {
    let rerun: Bool
    
    init(rerun: Bool = false) {
        self.rerun = rerun
    }
    
    func sideEffect(_ context: SideEffectContext<AppState, DependenciesContainer>) throws {
        guard var cityName = context.getState().locationState.currentCity else { return }
        if self.rerun {
            cityName += " City"
        }
        context.dependencies.wikiAPI.getWikidataId(title: cityName).then(context.dependencies.wikiAPI.getCityDetail).then(in: .utility) { city in
            context.dispatch(SetWDCity(city: city))
        }.catch(in: .utility) { error in
            if let _ = error as? DisambiguationPageError {
                context.dispatch(GetCityDetails(rerun: true))
            }
            print(error.localizedDescription)
        }
    }
}
