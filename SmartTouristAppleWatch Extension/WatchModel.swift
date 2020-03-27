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
import WatchConnectivity


class UserData: ObservableObject {
    @Published var places: [AWGPPlace] = []
    
    init(places: [AWGPPlace] = []) {
        self.places = places
    }
    
    func getPlaces(type: AppleWatchMessage.PlaceType) {
        guard WCSession.default.isReachable else {
            print("UNREACHABLE SESSION")
            return
        }
        let message = ["type": AppleWatchMessage.getPlaces.rawValue, "place_type": type.rawValue]
        WCSession.default.sendMessage(message, replyHandler: { response in
            print(response)
            guard let places = response["places"] as? [AWGPPlace] else { return }
            DispatchQueue.main.async {
                self.places = places
            }
        }, errorHandler: { error in
            print(error.localizedDescription)
        })
    }
}


enum SelectedPlaces {
    case nearest
    case popular
    case favorites
}


struct AWGPPlace: Identifiable {
    var id: String { self.placeID }
    let placeID: String
    //let location: CLLocationCoordinate2D
    let name: String
    let city: String
    let photoData: Data
    let rating: Double
    let userRatingsTotal: Int
    let isFavorite: Bool
    
    var image: Image? {
        guard
            let source = CGImageSourceCreateWithData(self.photoData as CFData, nil),
            let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else { return nil}
        return Image(decorative: image, scale: 1)
    }
}


#if DEBUG
var userData = UserData(places: [
    /*AWGPPlace(placeID: UUID().uuidString, location: CLLocationCoordinate2D(latitude: 0, longitude: 0), name: "Place0", city: "City0", photoData: nil, rating: nil, userRatingsTotal: nil, isFavorite: false),
    AWGPPlace(placeID: UUID().uuidString, location: CLLocationCoordinate2D(latitude: 1, longitude: 1), name: "Place1", city: "City1", photoData: nil, rating: nil, userRatingsTotal: nil, isFavorite: true),
    AWGPPlace(placeID: UUID().uuidString, location: CLLocationCoordinate2D(latitude: 2, longitude: 2), name: "Place2", city: "City2", photoData: nil, rating: nil, userRatingsTotal: nil, isFavorite: false),
    AWGPPlace(placeID: UUID().uuidString, location: CLLocationCoordinate2D(latitude: 3, longitude: 3), name: "Place3", city: "City3", photoData: nil, rating: nil, userRatingsTotal: nil, isFavorite: false),
    AWGPPlace(placeID: UUID().uuidString, location: CLLocationCoordinate2D(latitude: 4, longitude: 4), name: "Place4", city: "City4", photoData: nil, rating: nil, userRatingsTotal: nil, isFavorite: true),*/
])
#else
var userData = UserData()
#endif
