//
//  WCSessionDelegate.swift
//  SmartTourist
//
//  Created on 26/03/2020
//

import Foundation
import WatchConnectivity
import Hydra


extension SceneDelegate: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(activationState)
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        guard let typeString = message["type"] as? String, let type = AppleWatchMessage(rawValue: typeString) else { return }
        var replyMessage: [String: Any] = [:]
        switch type {
        case .test:
            print("MESSAGE RECEIVED")
            replyMessage = message
        case .getPlaces:
            guard
                let placeTypeString = message["place_type"] as? String,
                let placeType = AppleWatchMessage.PlaceType(rawValue: placeTypeString)
                else { return }
            do {
                switch placeType {
                case .nearest:
                    replyMessage["places"] = try await(mapPlaces(self.store.state.locationState.nearestPlaces))
                case .popular:
                    replyMessage["places"] = try await(mapPlaces(self.store.state.locationState.popularPlaces))
                case .favorites:
                    replyMessage["places"] = try await(mapPlaces(self.store.state.favorites))
                }
            } catch {
                print(error.localizedDescription)
                replyMessage["places"] = []
            }
        default:
            print("ELSE")
        }
        replyHandler(replyMessage)
    }
    
    private func mapPlaces(_ places: [GPPlace]) -> Promise<[AWGPPlace]> {
        return Promise<[AWGPPlace]>(in: .background) { resolve, reject, status in
            let awPlaces: [AWGPPlace] = places.map { place in
                let photoData = self.getPhotoData(place: place)
                return AWGPPlace(placeID: place.placeID,
                                 //location: place.location,
                                 name: place.name,
                                 city: place.city ?? "",
                                 photoData: photoData ?? Data(),
                                 rating: place.rating ?? -1,
                                 userRatingsTotal: place.userRatingsTotal ?? -1,
                                 isFavorite: self.store.state.favorites.contains(place))
            }
            resolve(awPlaces)
        }
    }
    
    private func getPhotoData(place: GPPlace) -> Data? {
        if let photo = place.photos?.first {
            do {
                let image = try await(GoogleAPI.shared.getPhoto(photo))
                return image.pngData()
            } catch {
                print(error.localizedDescription)
                return nil
            }
        } else {
            return nil
        }
    }
}
