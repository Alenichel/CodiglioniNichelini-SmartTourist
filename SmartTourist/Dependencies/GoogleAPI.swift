//
//  GoogleAPI.swift
//  SmartTourist
//
//  Created on 24/11/2019.
//

import UIKit
import GoogleMaps
import Hydra
import Alamofire


class GoogleAPI {
    static let apiKey = "AIzaSyBRyXdxfKGblNikXdbjmGoLMDvMdWqeku0"
    static let apiThrottleTime: Double = 30   // seconds
    
    static let shared = GoogleAPI()
    private init() {}
    
    private let geocoder = CLGeocoder()
    private let photoCache = NSCache<GPPhoto, UIImage>()
    
    enum PlaceType: String {
        case touristAttraction = "tourist_attraction"
    }
    
    func getCityName(coordinates: CLLocationCoordinate2D) -> Promise<String> {
        return Promise<String>(in: .background) { resolve, reject, status in
            let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            self.geocoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
                if let error = error {
                    reject(error)
                }
                else if let placemark = placemarks?[0], let locality = placemark.locality {
                    resolve(locality)
                }
            })
        }
    }
    
    func getNearbyPlaces(location: CLLocationCoordinate2D) -> Promise<[WDPlace]> {
        return Promise<[WDPlace]>(in: .background) { resolve, reject, status in
            let parameters = [
                "language": "en",
                "key": GoogleAPI.apiKey,
                "location": "\(location.latitude),\(location.longitude)",
                "rankby": "distance",
                "type": PlaceType.touristAttraction.rawValue
            ]
            AF.request("https://maps.googleapis.com/maps/api/place/nearbysearch/json", parameters: parameters).responseJSON(queue: .global(qos: .utility)) { response in
                switch response.result {
                case .success:
                    guard let data = response.data else { reject(UnknownApiError()); return }
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let gpResponse = try decoder.decode(GPPlaceSearchResponse.self, from: data)
                        resolve(gpResponse.results)
                    } catch {
                        print("\(#function): \(error.localizedDescription)")
                        reject(error)
                    }
                    reject(UnknownApiError())
                case .failure:
                    guard let error = response.error else { reject(UnknownApiError()); return }
                    print("\(#function): \(error.localizedDescription)")
                    reject(error)
                }
            }
        }
    }
    
    private func placeTextSearch(query: String, limit: Int? = nil, type: PlaceType? = nil) -> Promise<[WDPlace]> {
        return Promise<[WDPlace]>(in: .background) { resolve, reject, status in
            var parameters = [
                "language": "en",
                "key": GoogleAPI.apiKey,
                "query": query,
            ]
            if let limit = limit {
                parameters["limit"] = "\(limit)"
            }
            if let type = type {
                parameters["type"] = type.rawValue
            }
            AF.request("https://maps.googleapis.com/maps/api/place/textsearch/json", parameters: parameters).responseJSON(queue: .global(qos: .utility)) { response in
                switch response.result {
                case .success:
                    guard let data = response.data else { reject(UnknownApiError()); return }
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let gpResponse = try decoder.decode(GPPlaceSearchResponse.self, from: data)
                        let results = gpResponse.results.sorted(by: {$0.rating! > $1.rating!})
                        resolve(results)
                    } catch {
                        print("\(#function): \(error.localizedDescription)")
                        reject(error)
                    }
                    reject(UnknownApiError())
                case .failure:
                    guard let error = response.error else { reject(UnknownApiError()); return }
                    print("\(#function): \(error.localizedDescription)")
                    reject(error)
                }
            }
        }
    }
        
    func getPopularPlaces(city: String) -> Promise<[WDPlace]> {
        return self.placeTextSearch(query: "\(city) top attractions", type: .touristAttraction)
    }
    
    func getCityPlace(city: String) -> Promise<[WDPlace]> {
        return self.placeTextSearch(query: city, limit: 1)
    }
    
    func getPlaceDetails(placeID: String) -> Promise<GPPlaceDetailResultsResponse> {
        return Promise<GPPlaceDetailResultsResponse>(in: .background) { resolve, reject, status in
            let parameters = [
                "key": GoogleAPI.apiKey,
                "place_id": placeID,
                "fields": "photos,website"
            ]
            AF.request("https://maps.googleapis.com/maps/api/place/details/json", parameters: parameters).response { response in
                switch response.result {
                case .success:
                    guard let data = response.data else { reject(UnknownApiError()); return }
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let gpResponse = try decoder.decode(GPPlaceDetailResponse.self, from: data)
                        resolve(gpResponse.result)
                    } catch {
                        print("\(#function): \(error.localizedDescription)")
                        reject(error)
                    }
                    reject(UnknownApiError())
                case .failure:
                    guard let error = response.error else { reject(UnknownApiError()); return }
                    print("\(#function): \(error.localizedDescription)")
                    reject(error)
                }
            }
        }
    }
    
    func getPhoto(_ photo: GPPhoto) -> Promise<UIImage> {
        return Promise<UIImage>(in: .background) { resolve, reject, status in
            if let image = self.photoCache.object(forKey: photo) {
                resolve(image)
            } else {
                let parameters = [
                    "key": GoogleAPI.apiKey,
                    "photoreference": photo.photoReference,
                    "maxheight": "\(photo.height)",
                    "maxwidth": "\(photo.width)"
                ]
                AF.request("https://maps.googleapis.com/maps/api/place/photo", parameters: parameters).response { response in
                    switch response.result {
                    case .success:
                        guard let data = response.data else { reject(UnknownApiError()); return }
                        guard let image = UIImage(data: data) else { reject(UnknownApiError()); return }
                        self.photoCache.setObject(image, forKey: photo)
                        resolve(image)
                    case .failure:
                        guard let error = response.error else { reject(UnknownApiError()); return }
                        print("\(#function): \(error.localizedDescription)")
                        reject(error)
                    }
                }
            }
        }
    }
    
    func buildDirectionURL(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D , destinationPlaceId: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "google.com"
        components.path = "/maps/dir/"
        components.queryItems = [
            URLQueryItem(name: "api", value: "1"),
            URLQueryItem(name: "destination", value: "\(destination.latitude),\(destination.longitude)"),
            URLQueryItem(name: "destination_place_id", value: destinationPlaceId),
            URLQueryItem(name: "travelmode", value: "walking"),
            URLQueryItem(name: "origin", value: "\(origin.latitude),\(origin.longitude)")
        ]
        return components.url!
    }
    
    func getTravelTime(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) -> Promise<String> {
        return Promise<String>(in: .background) { resolve, reject, status in
            let parameters = [
                "language": "en",
                "origin" : "\(origin.latitude),\(origin.longitude)",
                "destination" : "\(destination.latitude),\(destination.longitude)",
                "key": GoogleAPI.apiKey
            ]
            AF.request("https://maps.googleapis.com/maps/api/directions/json", parameters: parameters).responseJSON(queue: .global(qos: .utility)) { response in
                switch response.result {
                case .success:
                    guard let data = response.data else { reject(UnknownApiError()); return }
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .useDefaultKeys
                    do {
                        let response = try decoder.decode(GMDResponse.self, from: data)
                        let r = response.routes.first?.legs.first?.durationText
                        resolve(r ?? "Unavailable")
                    } catch {
                        print("\(#function): \(error.localizedDescription)")
                        reject(error)
                    }
                case .failure:
                    guard let error = response.error else { reject(UnknownApiError()); return }
                    print("\(#function): \(error.localizedDescription)")
                    reject(error)
                }
            }
        }
    }
}


class UnknownApiError: Error {}
