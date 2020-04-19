//
//  WCSessionDelegate.swift
//  SmartTourist
//
//  Created on 26/03/2020
//

import Foundation
import WatchConnectivity
import Hydra


extension AppDelegate: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if self.store.state.locationState.nearestPlaces.isEmpty && self.store.state.locationState.popularPlaces.isEmpty {
            do {
                try await(self.store.dispatch(LoadState()))
            } catch {
                print("\(#function): \(error.localizedDescription)")
            }
        }
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
                print("\(#function): \(error.localizedDescription)")
                replyMessage["places"] = nil
            }
        case .getDetail:
            let allPlaces = Set<WDPlace>(self.store.state.locationState.nearestPlaces + self.store.state.locationState.popularPlaces)
            guard
                let placeID = message["placeID"] as? String,
                let place = allPlaces.first(where: { $0.placeID == placeID })
            else { return }
            do {
                replyMessage["place_detail"] = try await(self.encodePlaceDetail(place))
            } catch {
                print("\(#function): \(error.localizedDescription)")
                replyMessage["place_detail"] = nil
            }
        }
        replyHandler(replyMessage)
    }
    
    private func encodePlaces(_ places: [WDPlace]) -> Promise<Data> {
        return Promise<Data>(in: .background) { resolve, reject, status in
            let promises = places.filter { place in
                guard let index = places.firstIndex(of: place) else { return false }
                return index < 10
            }.map { self.mapPlace($0, maxPixels: 50) }
            do {
                let awPlaces = try await(all(promises))
                let data = try JSONEncoder().encode(awPlaces)
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
    
    private func mapPlace(_ place: WDPlace, maxPixels: CGFloat) -> Promise<AWGPPlace> {
        return Promise<AWGPPlace>(in: .background) { resolve, reject, status in
            let photoData = self.getPhotoData(place, maxPixels: maxPixels)
            let awPlace = AWGPPlace(id: place.placeID,
                                    name: place.name,
                                    photoData: photoData ?? Data())
            resolve(awPlace)
        }
    }
    
    private func getPhotoData(_ place: WDPlace, maxPixels: CGFloat) -> Data? {
        if let photo = place.photos.first {
            do {
                let image = try await(WikipediaAPI.shared.getPhoto(imageURL: photo))
                return self.resizeImage(image, maxPixels: maxPixels)
            } catch {
                print("\(#function): \(error.localizedDescription)")
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
    
    private func encodePlaceDetail(_ place: WDPlace) -> Promise<Data> {
        return Promise<Data>(in: .background) { resolve, reject, status in
            do {
                let awPlace = try await(self.mapPlace(place, maxPixels: 150))
                let description = try await(WikipediaAPI.shared.search(searchTerms: place.name))
                let awPlaceDetail = AWGPPlaceDetail(awPlace: awPlace, description: description)
                let data = try JSONEncoder().encode(awPlaceDetail)
                print("payload size = \(data.count)")
                if data.count > 65536 {
                    print("Possible WCErrorCodePayloadTooLarge ahead")
                }
                resolve(data)
            } catch {
                print("\(#function): \(error.localizedDescription)")
                reject(error)
            }
        }
    }
}
