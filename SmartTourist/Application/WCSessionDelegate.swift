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
        // TODO: Check if state is populated
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
                    replyMessage["places"] = try await(self.encodePlaces(self.store.state.locationState.nearestPlaces))
                case .popular:
                    replyMessage["places"] = try await(self.encodePlaces(self.store.state.locationState.popularPlaces))
                case .favorites:
                    replyMessage["places"] = try await(self.encodePlaces(self.store.state.favorites))
                }
            } catch {
                print(error.localizedDescription)
                replyMessage["places"] = nil
            }
        default:
            print("ELSE")
        }
        replyHandler(replyMessage)
    }
    
    private func encodePlaces(_ places: [GPPlace]) -> Promise<Data> {
        return Promise<Data>(in: .background) { resolve, reject, status in
            let promises = places.filter { place in
                guard let index = places.firstIndex(of: place) else { return false }
                return index < 10
            }.map { self.mapPlace($0, maxPixels: 50.0) }
            let encoder = JSONEncoder()
            do {
                let awPlaces = try await(all(promises))
                let data = try encoder.encode(awPlaces)
                print("payload size = \(data.count)")
                if data.count > 65536 {
                    print("Possible WCErrorCodePayloadTooLarge ahead")
                }
                resolve(data)
            } catch {
                reject(error)
            }
        }
    }
    
    private func mapPlace(_ place: GPPlace, maxPixels: CGFloat) -> Promise<AWGPPlace> {
        return Promise<AWGPPlace>(in: .background) { resolve, reject, status in
            let photoData = self.getPhotoData(place, maxPixels: maxPixels)
            let awPlace = AWGPPlace(id: place.placeID,
                                    name: place.name,
                                    photoData: photoData ?? Data())
            resolve(awPlace)
        }
    }
    
    private func getPhotoData(_ place: GPPlace, maxPixels: CGFloat) -> Data? {
        if let photo = place.photos?.first {
            do {
                let image = try await(GoogleAPI.shared.getPhoto(photo))
                return self.resizeImage(image, maxPixels: maxPixels)
            } catch {
                print(error.localizedDescription)
                return nil
            }
        } else {
            return nil
        }
    }
    
    private func resizeImage(_ uiImage: UIImage, maxPixels: CGFloat) -> Data? {
        // FIXME: Keep aspect ratio
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixels
        ]
        guard
            let imageData = uiImage.jpegData(compressionQuality: 0.5),
            let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil),
            let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary)
        else { return nil }
        return UIImage(cgImage: image).jpegData(compressionQuality: 1.0)
    }
}
