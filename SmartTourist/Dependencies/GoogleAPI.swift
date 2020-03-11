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
    static let apiKey = "AIzaSyBAtMbvNlX14W5aGIEbcOLp83ZZjskfLck"
    
    static let shared = GoogleAPI()
    private init() {}
    
    private let geocoder = GMSGeocoder()
    private let photoCache = NSCache<GPPhoto, UIImage>()
    
    enum PlaceType: String {
        case touristAttraction = "tourist_attraction"
    }
    
    func getCityName(coordinates: CLLocationCoordinate2D) -> Promise<String> {
        return Promise<String>(in: .background) { resolve, reject, status in
            self.geocoder.reverseGeocodeCoordinate(coordinates) { response, error in
                if let error = error {
                    reject(error)
                }
                if let city = response?.firstResult()?.locality {
                    resolve(city)
                }
            }
        }
    }
    
    func getNearbyPlaces(location: CLLocationCoordinate2D) -> Promise<[GPPlace]> {
        return Promise<[GPPlace]>(in: .background) { resolve, reject, status in
            let parameters = [
                "language": "en",
                "key": GoogleAPI.apiKey,
                "location": "\(location.latitude),\(location.longitude)",
                //"radius": "\(200)",
                "rankby": "distance",
                "type": PlaceType.touristAttraction.rawValue
            ]
            AF.request("https://maps.googleapis.com/maps/api/place/nearbysearch/json", parameters: parameters).responseJSON { response in
                switch response.result {
                case .success:
                    guard let data = response.data else { return }
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let gpResponse = try decoder.decode(GPResponse.self, from: data)
                        resolve(gpResponse.results)
                    } catch {
                        print(error.localizedDescription)
                        reject(error)
                    }
                case .failure:
                    guard let error = response.error else { return }
                    print(error.localizedDescription)
                    reject(error)
                }
            }
        }
    }
    
    func getPopularPlaces(city: String) -> Promise<[GPPlace]> {
        return Promise<[GPPlace]>(in: .background) { resolve, reject, status in
            let parameters = [
                "language": "en",
                "key": GoogleAPI.apiKey,
                "query": "\(city) main attractions",
                "type": PlaceType.touristAttraction.rawValue
            ]
            AF.request("https://maps.googleapis.com/maps/api/place/textsearch/json", parameters: parameters).responseJSON { response in
                switch response.result {
                case .success:
                    guard let data = response.data else { return }
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let gpResponse = try decoder.decode(GPResponse.self, from: data)
                        let results = gpResponse.results.sorted(by: {$0.rating! > $1.rating!})
                        resolve(results)
                    } catch {
                        print(error.localizedDescription)
                        reject(error)
                    }
                case .failure:
                    guard let error = response.error else { return }
                    print(error.localizedDescription)
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
                        guard let data = response.data else { return }
                        guard let image = UIImage(data: data) else { return }
                        self.photoCache.setObject(image, forKey: photo)
                        resolve(image)
                    case .failure:
                        guard let error = response.error else { return }
                        print(error.localizedDescription)
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
}
