//
//  GoogleAPI.swift
//  SmartTourist
//
//  Created on 24/11/2019.
//

import UIKit
import Hydra
import Alamofire


class GoogleAPI {
    static let apiKey = "AIzaSyBRyXdxfKGblNikXdbjmGoLMDvMdWqeku0"
    static let apiThrottleTime: Double = 15   // seconds
    
    static let shared = GoogleAPI()
    private init() {}
        
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
}


class UnknownApiError: Error {}
