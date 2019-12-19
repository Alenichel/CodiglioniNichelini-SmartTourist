//
//  WikipediaAPI.swift
//  SmartTourist
//
//  Created on 03/12/2019
//

import UIKit
import WikipediaKit
import Hydra
import GoogleMaps

class WikipediaAPI {
    
    static let shared = WikipediaAPI()
    let language = WikipediaLanguage("en")
    
    private init() {
        WikipediaNetworking.appAuthorEmailForAPI = "ale.nichelg@gmail.com"
    }
    
    func search(searchTerms: String) -> Promise<String> {
        return Promise<String>(in: .background) { resolve, reject, status in
            let _ = Wikipedia.shared.requestOptimizedSearchResults(language: self.language, term: searchTerms) { (searchResults, error) in
            if let error = error {reject(error)}
            if let searchResults = searchResults {
                for articlePreview in searchResults.items { print(articlePreview.displayTitle) }
                resolve(searchResults.items.first?.displayText ?? "No description")
                }
            }
        }
    }
    
    
    func getArticleFromNearbyArticles(coordinates: CLLocationCoordinate2D, searchTerms: String) -> Promise<[WikipediaArticlePreview]> {
        return Promise<[WikipediaArticlePreview]>(in: .background) { resolve, reject, status in
            let _ = Wikipedia.shared.requestNearbyResults(language: self.language, latitude: Double(coordinates.latitude), longitude: Double(coordinates.longitude)) { (articlePreviews, resultsLanguage, error) in
                guard error == nil else { return }
                guard let articlePreviews = articlePreviews else { return }
                
                for a in articlePreviews {
                    print(a.displayTitle)
                    if let coordinate = a.coordinate {
                        print(coordinate.latitude)
                        print(coordinate.longitude)
                    }
                }
                resolve(articlePreviews)
            }
        }
    }
}
