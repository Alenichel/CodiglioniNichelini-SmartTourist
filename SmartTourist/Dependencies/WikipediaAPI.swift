//
//  WikipediaAPI.swift
//  SmartTourist
//
//  Created on 03/12/2019
//

import UIKit
import WikipediaKit

class WikipediaAPI {
    
    static let shared = WikipediaAPI()
    let language = WikipediaLanguage("en")
    
    private init() {
        WikipediaNetworking.appAuthorEmailForAPI = "ale.nichelg@gmail.com"
    }
    
    func search(title: String) {
        let _ = Wikipedia.shared.requestOptimizedSearchResults(language: language, term: title) { (searchResults, error) in
            guard error == nil else { return }
            guard let searchResults = searchResults else { return }
            
            for articlePreview in searchResults.items {
                print(articlePreview.displayTitle)
            }
        }
    }
}
