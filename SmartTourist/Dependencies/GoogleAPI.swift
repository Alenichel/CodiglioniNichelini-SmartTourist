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

class GoogleAPI {
    
    var placesClient = GMSPlacesClient.shared()
    var geocoder = GMSGeocoder()
    
    enum PlaceType: String {
        case touristAttraction = "tourist_attraction"
    }
    
    func getNearbyPlaces() -> Promise<[GMSPlace]> {
        return Promise<[GMSPlace]>(in: .main) { resolve, reject, status in
            self.placesClient.currentPlace { (placeLikelihoodList, error) -> Void in
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
}
