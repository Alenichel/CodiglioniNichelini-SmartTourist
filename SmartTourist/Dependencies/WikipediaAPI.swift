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
import Alamofire

class WikipediaAPI {
    
    static let shared = WikipediaAPI()
    let language = WikipediaLanguage("en")
    private let cache = NSCache<NSString, NSString>()
    
    private init() {
        WikipediaNetworking.appAuthorEmailForAPI = "ale.nichelg@gmail.com"
    }
    
    func search(searchTerms: String) -> Promise<String> {
        return Promise<String>(in: .background) { resolve, reject, status in
            if let description = self.cache.object(forKey: searchTerms as NSString) {
                resolve(description as String)
            } else {
                let _ = Wikipedia.shared.requestOptimizedSearchResults(language: self.language, term: searchTerms) { (searchResults, error) in
                    if let error = error {
                        reject(error)
                    }
                    if let searchResults = searchResults {
                        //for articlePreview in searchResults.items { print(articlePreview.displayTitle) }
                        let description = searchResults.items.first?.displayText ?? "No description"
                        self.cache.setObject(description as NSString, forKey: searchTerms as NSString)
                        resolve(description)
                    }
                }
            }
        }
    }
    
    func getDescriptionFromNearbyArticles(coordinates: CLLocationCoordinate2D, searchTerms: String) -> Promise<String> {
        return Promise<String>(in: .background) { resolve, reject, status in
            let _ = Wikipedia.shared.requestNearbyResults(language: self.language, latitude: Double(coordinates.latitude), longitude: Double(coordinates.longitude), maxCount: 50) { (articlePreviews, resultsLanguage, error) in
                guard error == nil, let articlePreviews = articlePreviews else {
                    reject(UnknownApiError())
                    return
                }
                
                let fuse = Fuse(threshold: 0.5)
                
                let titles = articlePreviews.map { article -> String in
                    //print(articlePreviews.firstIndex(of: article)!, article.title)
                    return article.title
                }
                let results = fuse.search(searchTerms, in: titles).sorted(by: {
                    $0.score < $1.score
                })
                
                guard results.count > 0 else {
                    resolve("No description available")
                    return
                }
 
                self.search(searchTerms: titles[results.first!.index]).then(in: .utility) { description in
                    resolve(description)
                }.catch(in: .utility) { error in
                    reject(error)
                }
            }
        }
    }
    
    func findExactWikipediaArticleName(searchTerms: String) -> Promise<String> {
        return Promise<String>(in: .background) { resolve, reject, status in
            let _ = Wikipedia.shared.requestOptimizedSearchResults(language: self.language, term: searchTerms, maxCount: 50) { (articlePreviews, error) in
                guard error == nil, let articlePreviews = articlePreviews else {
                    reject(UnknownApiError())
                    return
                }
                
                let fuse = Fuse(threshold: 0.5)
                
                let titles = articlePreviews.items.map{article -> String in
                    return article.title
                }
                
                let results = fuse.search(searchTerms, in: titles).sorted(by: {
                    $0.score < $1.score
                })
                
                resolve(titles[results.first!.index])
            }
        }
    }
    
    func getWikidataId(title: String) -> Promise<String> {
        return Promise<String>(in: .background) { resolve, reject, status in
            let parameters = [
                "action" : "query",
                "prop" : "pageprops",
                "titles" : title,//.replacingOccurrences(of: " ", with: "_"),
                "format" : "json"
            ]
            let url = "https://en.wikipedia.org/w/api.php"//
            AF.request(url, parameters: parameters).responseJSON{ response in
                switch response.result {
                case .success:
                    guard let data = response.data else { reject(UnknownApiError()); return }
                    do {
                        // make sure this JSON is in the format we expect
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            // try to read out a string array
                            if let query = json["query"] as? [String: Any] {
                                if let pages = query["pages"] as? [String: Any]{
                                    if let number = pages[pages.keys.first ?? ""] as? [String: Any]{
                                        if let pageprops = number["pageprops"] as? [String: Any]{
                                            if let wikidataId = pageprops["wikibase_item"] as? String{
                                                print(wikidataId)
                                                resolve(wikidataId)
                                                return
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        reject(UnknownApiError())
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                        reject(error)
                    }
                case .failure:
                    guard let error = response.error else { reject(UnknownApiError()); return }
                    print(error.localizedDescription)
                    reject(error)
                }
            }
        }
    }
}
