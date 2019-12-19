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
import Fuse

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
    
    
    func getArticleNameFromNearbyArticles(coordinates: CLLocationCoordinate2D, searchTerms: String) -> Promise<String> {
        return Promise<String>(in: .background) { resolve, reject, status in
            let _ = Wikipedia.shared.requestNearbyResults(language: self.language, latitude: Double(coordinates.latitude), longitude: Double(coordinates.longitude), maxCount: 50) { (articlePreviews, resultsLanguage, error) in
                guard error == nil else { return }
                guard let articlePreviews = articlePreviews else { return }
                
                let fuse = Fuse()
                
                let titles = articlePreviews.map{article -> String in
                    print(article.title)
                    return article.title
                }
                let results = fuse.search(searchTerms, in: titles).sorted(by: {
                    $0.score > $1.score
                })

                results.forEach { item in
                    print("index: " + String(item.index))
                    print("score: " + String(item.score))
                }
                
                resolve(titles[results.first!.index])
            }
        }
    }
}
