//
//  WatchModel.swift
//  SmartTouristAppleWatch Extension
//
//  Created on 27/03/2020
//

import SwiftUI
import Combine
import CoreLocation
import ImageIO
import Hydra


class UserData: NSObject, ObservableObject {
    @Published var places: [AWPlace] = []
    @Published var placeDetails: [AWPlaceDetail] = []
    
    var placesType: SelectedPlaces = .nearest
    
    var location: CLLocationCoordinate2D? {
        didSet {
            getPlaces(type: self.placesType)
        }
    }
        
    init(places: [AWPlace] = [], placeDetails: [AWPlaceDetail] = []) {
        self.places = places
        self.placeDetails = placeDetails
        super.init()
        LocationManager.sharedForegound.setDelegate(self)
        LocationManager.sharedForegound.requestAuth()
        LocationManager.sharedForegound.startUpdatingLocation()
    }
    
    func getPlaces(type: SelectedPlaces) {
        guard let location = self.location else { return }
        print(#function)
        switch type {
        case .nearest:
            WikipediaAPI.shared.getNearbyPlaces(location: location, radius: 1, isArticleMandatory: true).then(in: .main) { places in
                var sortedPlaces = Array(Set(places)).sorted(by: { $0.distance(from: location) < $1.distance(from: location) })
                sortedPlaces = sortedPlaces.filter { $0.wikipediaLink != nil }
                sortedPlaces = Array(sortedPlaces.prefix(25))
                let photoPromises = sortedPlaces.map { $0.getPhotosURLs(limit: 1) }
                all(photoPromises).then(in: .main) { _ in
                    let awPlaces = sortedPlaces.map { AWPlace(id: $0.placeID, name: $0.name, wikipediaName: $0.wikipediaName ?? $0.name, photoURL: $0.photos![0])}
                    self.places = awPlaces
                }
            }
        case .popular:
            MapsAPI.shared.getCityName(coordinates: location).then(in: .background, GoogleAPI.shared.getPopularPlaces).then(in: .utility) { places in
                let wdPlaces = places.map { WDPlace(gpPlace: $0) }
                let promises = wdPlaces.map { $0.getMissingDetails() }
                all(promises).then(in: .utility) { _ in
                    var filteredPlaces = wdPlaces.filter { place in
                        guard let photos = place.photos else { return false }
                        return !photos.isEmpty
                    }
                    let photoPromises = filteredPlaces.map { $0.getPhotosURLs() }
                    all(photoPromises).then(in: .main) { _ in
                        filteredPlaces = filteredPlaces.filter { $0.photos!.count > 0 }
                        let awPlaces = filteredPlaces.map { AWPlace(id: $0.placeID, name: $0.name, wikipediaName: $0.wikipediaName ?? $0.name, photoURL: $0.photos![0]) }
                        async(in: .main) {
                            self.places = awPlaces
                        }
                    }
                }
            }
        case .favorites:
            fatalError("Not supported")
        }
    }
    
    func getPlaceDetail(_ place: AWPlace) {
        WikipediaAPI.shared.getArticle(articleName: place.wikipediaName).then(in: .main) { article in
            let placeDetail = AWPlaceDetail(awPlace: place, description: article)
            self.placeDetails.append(placeDetail)
        }
    }
}


extension UserData: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        print(location.coordinate)
        self.location = location.coordinate
    }
}


enum SelectedPlaces {
    case nearest
    case popular
    case favorites
}


struct AWPlace: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let wikipediaName: String
    let photoURL: URL
}


struct AWPlaceDetail: Codable, Equatable {
    let awPlace: AWPlace
    let description: String
    
    var id: String {
        self.awPlace.id
    }
}


#if DEBUG
var userData: UserData = {
    let photoURL = URL(string: "https://upload.wikimedia.org/wikipedia/commons/c/c7/Empire_State_Building_from_the_Top_of_the_Rock.jpg")!
    let places = [
        AWPlace(id: UUID().uuidString, name: "Place1", wikipediaName: "Empire_State_Building", photoURL: photoURL),
        AWPlace(id: UUID().uuidString, name: "Place2", wikipediaName: "Empire_State_Building", photoURL: photoURL),
        AWPlace(id: UUID().uuidString, name: "Place3", wikipediaName: "Empire_State_Building", photoURL: photoURL),
        AWPlace(id: UUID().uuidString, name: "Place4", wikipediaName: "Empire_State_Building", photoURL: photoURL),
        AWPlace(id: UUID().uuidString, name: "Place5", wikipediaName: "Empire_State_Building", photoURL: photoURL),
    ]
    let placeDetails = [
        AWPlaceDetail(awPlace: places[0], description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc id metus sollicitudin magna rhoncus sodales id vitae purus. In hac habitasse platea dictumst. Etiam consectetur sodales placerat. Vestibulum id rhoncus nunc. Donec fringilla ac lorem sed tempus. Aenean sapien leo, porta id enim vitae, dignissim lobortis mauris. Donec commodo suscipit nulla eget sagittis. Nam consequat posuere diam, sit amet fringilla lorem faucibus ut. Sed id eros condimentum, consequat erat sit amet, cursus est. Cras ultrices diam a volutpat aliquet. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In congue congue augue gravida iaculis. Morbi mattis mattis magna id luctus. Mauris tincidunt eros vitae rutrum sodales. Donec tincidunt lacus non tellus congue vehicula. Nunc dapibus purus non risus placerat pellentesque.")
    ]
    return UserData(places: places, placeDetails: placeDetails)
}()
#else
var userData = UserData()
#endif
