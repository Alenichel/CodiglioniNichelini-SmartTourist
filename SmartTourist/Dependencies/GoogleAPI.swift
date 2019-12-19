//
//  GoogleAPI.swift
//  SmartTourist
//
//  Created on 24/11/2019.
//

import Foundation
import GoogleMaps
import GooglePlaces
import Hydra
import Alamofire

class GoogleAPI {
    
    static let apiKey = "AIzaSyBAtMbvNlX14W5aGIEbcOLp83ZZjskfLck"
    static let shared = GoogleAPI()
    private init() {}
    
    var placesClient = GMSPlacesClient.shared()
    var geocoder = GMSGeocoder()
    
    enum PlaceType: String {
        case touristAttraction = "tourist_attraction"
    }
    
    func getNearbyPlaces() -> Promise<[GMSPlace]> {
        return Promise<[GMSPlace]>(in: .main) { resolve, reject, status in
            self.placesClient.currentPlace { placeLikelihoodList, error in
                if let error = error {
                    print(error.localizedDescription)
                    reject(error)
                }
                if let placeLikelihoodList = placeLikelihoodList {
                    let places = placeLikelihoodList.likelihoods
                        .map({$0.place})
                    print("Nearby places: \(places.map({$0.name ?? ""}))")
                    resolve(places)
                }
            }
        }
    }
    
    func getNearbyAttractions() -> Promise<[GMSPlace]> {
        return Promise<[GMSPlace]>(in: .background) { resolve, reject, status in
            self.getNearbyPlaces().then { places in
                let attractions = places.filter({$0.types?.contains(PlaceType.touristAttraction.rawValue) ?? false})
                print("Nearby attractions: \(attractions.map({$0.name ?? ""}))")
                resolve(attractions)
            }.catch { error in
                reject(error)
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
    
    func getPlacePicture(photoMetadata: GMSPlacePhotoMetadata) -> Promise<UIImage> {
        return Promise<UIImage>(in: .background) { resolve, reject, status in
            self.placesClient.loadPlacePhoto(photoMetadata) { photo, error in
                if let error = error {
                    print("Error loading photo metadata: \(error.localizedDescription)")
                    reject(error)
                } else {
                    resolve(photo!)
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
                "fields": "geometry,place_id,name"
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
}
