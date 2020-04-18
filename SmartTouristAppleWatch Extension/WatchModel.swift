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
    @Published var placeDetails: [AWGPPlaceDetail] = []
    
    init(places: [AWGPPlace] = [], placeDetails: [AWGPPlaceDetail] = []) {
        self.places = places
        self.placeDetails = placeDetails
    }
    
    func getPlaces(type: AppleWatchMessage.PlaceType) {
        guard WCSession.default.isReachable else {
            print("UNREACHABLE SESSION")
            return
        }
        let message = ["type": AppleWatchMessage.getPlaces.rawValue, "place_type": type.rawValue]
        WCSession.default.sendMessage(message, replyHandler: { response in
            guard let data = response["places"] as? Data else { return }
            do {
                let places = try JSONDecoder().decode([AWGPPlace].self, from: data)
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
    
    func getPlaceDetail(_ place: AWGPPlace) {
        guard !self.placeDetails.map({ $0.awPlace }).contains(place) else { return }
        guard WCSession.default.isReachable else {
            print("UNREACHABLE SESSION")
            return
        }
        let message = ["type": AppleWatchMessage.getDetail.rawValue, "placeID": place.id]
        WCSession.default.sendMessage(message, replyHandler: { response in
            guard let data = response["place_detail"] as? Data else { return }
            do {
                let placeDetail = try JSONDecoder().decode(AWGPPlaceDetail.self, from: data)
                DispatchQueue.main.async {
                    self.placeDetails.append(placeDetail)
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


struct AWGPPlace: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let photoData: Data
    
    var image: Image? {
        guard
            let source = CGImageSourceCreateWithData(self.photoData as CFData, nil),
            let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else { return nil}
        return Image(decorative: image, scale: 1).resizable()
    }
}


struct AWGPPlaceDetail: Codable, Equatable {
    let awPlace: AWGPPlace
    let description: String
    
    var id: String {
        self.awPlace.id
    }
}


#if DEBUG
var userData: UserData = {
    var photoData: Data
    if let navigationImage = UIImage(named: "empire"), let data = navigationImage.jpegData(compressionQuality: 1.0) {
        photoData = data
    } else {
        photoData = Data()
    }
    return UserData(places: [
        AWGPPlace(id: UUID().uuidString, name: "Place1", photoData: photoData),
        AWGPPlace(id: UUID().uuidString, name: "Place2", photoData: photoData),
        AWGPPlace(id: UUID().uuidString, name: "Place3", photoData: photoData),
        AWGPPlace(id: UUID().uuidString, name: "Place4", photoData: photoData),
        AWGPPlace(id: UUID().uuidString, name: "Place5", photoData: photoData),
    ], placeDetails: [AWGPPlaceDetail(awPlace: AWGPPlace(id: UUID().uuidString, name: "Place1", photoData: photoData), description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc id metus sollicitudin magna rhoncus sodales id vitae purus. In hac habitasse platea dictumst. Etiam consectetur sodales placerat. Vestibulum id rhoncus nunc. Donec fringilla ac lorem sed tempus. Aenean sapien leo, porta id enim vitae, dignissim lobortis mauris. Donec commodo suscipit nulla eget sagittis. Nam consequat posuere diam, sit amet fringilla lorem faucibus ut. Sed id eros condimentum, consequat erat sit amet, cursus est. Cras ultrices diam a volutpat aliquet. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In congue congue augue gravida iaculis. Morbi mattis mattis magna id luctus. Mauris tincidunt eros vitae rutrum sodales. Donec tincidunt lacus non tellus congue vehicula. Nunc dapibus purus non risus placerat pellentesque.")])
}()
#else
var userData = UserData()
#endif
