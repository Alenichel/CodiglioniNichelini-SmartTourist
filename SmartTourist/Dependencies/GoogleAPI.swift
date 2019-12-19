//
//  GoogleAPI.swift
//  SmartTourist
//
//  Created on 24/11/2019.
//

import Foundation
import GoogleMaps
import Hydra
import Alamofire


class GoogleAPI {
    static let apiKey = "AIzaSyBAtMbvNlX14W5aGIEbcOLp83ZZjskfLck"
    static let shared = GoogleAPI()
    private init() {}
    
    var geocoder = GMSGeocoder()
    
    enum PlaceType: String {
        case touristAttraction = "tourist_attraction"
    }
    
    func getNearbyPlaces(location: CLLocationCoordinate2D) -> Promise<[GPPlace]> {
        return Promise<[GPPlace]>(in: .background) { resolve, reject, status in
            let parameters = [
                "language": "en",
                "key": GoogleAPI.apiKey,
                "location": "\(location.latitude),\(location.longitude)",
                "radius": "\(200)",
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
                        let results = gpResponse.results.sorted(by: {$0.rating > $1.rating})
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
    
    func getPopularPlaces(city: String) -> Promise<[GPPlace]> {
        return Promise<[GPPlace]>(in: .background) { resolve, reject, status in
            let parameters = [
                "language": "en",
                "key": GoogleAPI.apiKey,
                "query": "\(city) main attractions",
            ]
            AF.request("https://maps.googleapis.com/maps/api/place/textsearch/json", parameters: parameters).responseJSON { response in
                switch response.result {
                case .success:
                    guard let data = response.data else { return }
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let gpResponse = try decoder.decode(GPResponse.self, from: data)
                        let results = gpResponse.results.sorted(by: {$0.rating > $1.rating})
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
