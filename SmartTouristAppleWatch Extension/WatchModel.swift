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
            guard let data = response["places"] as? Data else { return }
            let decoder = JSONDecoder()
            do {
                let places = try decoder.decode([AWGPPlace].self, from: data)
                DispatchQueue.main.async {
                    self.places = places
                }
            } catch {
                print(error.localizedDescription)
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


struct AWGPPlace: Identifiable, Codable {
    let id: String
    let name: String
    let photoData: Data
    
    var image: Image? {
        guard
            let source = CGImageSourceCreateWithData(self.photoData as CFData, nil),
            let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else { return nil}
        return Image(decorative: image, scale: 1)
    }
}


struct AWGPPlaceDetail: Codable {
    let awPlace: AWGPPlace
    let description: String
}


#if DEBUG
var userData = UserData(places: [
    AWGPPlace(id: UUID().uuidString, name: "Place1", photoData: Data()),
    AWGPPlace(id: UUID().uuidString, name: "Place2", photoData: Data()),
    AWGPPlace(id: UUID().uuidString, name: "Place3", photoData: Data()),
    AWGPPlace(id: UUID().uuidString, name: "Place4", photoData: Data()),
    AWGPPlace(id: UUID().uuidString, name: "Place5", photoData: Data()),
])
#else
var userData = UserData()
#endif
