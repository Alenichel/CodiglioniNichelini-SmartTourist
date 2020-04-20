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
    
    private let photoCache = NSCache<GPPhoto, UIImage>()
    
    enum PlaceType: String {
        case touristAttraction = "tourist_attraction"
    }
    
    private func placeTextSearch(query: String, limit: Int? = nil, type: PlaceType? = nil) -> Promise<[GPPlace]> {
        return Promise<[GPPlace]>(in: .background) { resolve, reject, status in
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
    
    func getPopularPlaces(city: String) -> Promise<[GPPlace]> {
        return self.placeTextSearch(query: "\(city) top attractions", type: .touristAttraction)
    }
    
    func getCityPlace(city: String) -> Promise<[GPPlace]> {
        return self.placeTextSearch(query: city, limit: 1)
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
