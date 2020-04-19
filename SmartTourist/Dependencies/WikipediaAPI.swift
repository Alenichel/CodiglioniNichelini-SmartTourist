//
//  WikipediaAPI.swift
//  SmartTourist
//
//  Created on 03/12/2019
//

import UIKit
import WikipediaKit
import Hydra
import Fuse
import Alamofire
import MapKit


let cityDetailsQuery = """
SELECT DISTINCT ?city ?cityLabel ?country ?countryLabel ?population ?area ?elevation ?link ?facebookPageId ?facebookPlacesId ?instagramUsername ?twitterUsername ?image ?coatOfArmsImage ?cityFlagImage WHERE {
BIND( <http://www.wikidata.org/entity/Q60> as ?city ).
OPTIONAL {?city wdt:P17 ?country}.
OPTIONAL {?city wdt:P1082 ?population}.
OPTIONAL {?city wdt:P2046 ?area}.
OPTIONAL {?city wdt:P2044 ?elevation}.
OPTIONAL {?city wdt:P856 ?link}.
OPTIONAL {?city wdt:P2013 ?facebookPageId}.
OPTIONAL {?city wdt:P1997 ?facebookPlacesId}.
OPTIONAL {?city wdt:P2003 ?instagramUsername}.
OPTIONAL {?city wdt:P2002 ?twitterUsername}.
OPTIONAL {?city wdt:P18 ?image}.
OPTIONAL {?city wdt:P94  ?coatOfArmsImage}.
OPTIONAL {?city wdt:P41 ?cityFlagImage}.
SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
}
"""

let nearbyPlacesQuery = """
SELECT DISTINCT ?place ?placeLabel ?location ?image ?instance ?phoneNumber ?website ?wikipediaLink ?wikimediaLink
WHERE
{
  SERVICE wikibase:label { bd:serviceParam wikibase:language "en" }
  SERVICE wikibase:around {
      ?place wdt:P625 ?location .
      bd:serviceParam wikibase:center "Point(9.191383 45.464311)"^^geo:wktLiteral .
      bd:serviceParam wikibase:radius "1" .
  }
  ?place wdt:P31 ?instance  .
  ?wikipediaLink schema:about ?place;
            schema:inLanguage "en";
            schema:isPartOf [ wikibase:wikiGroup "wikipedia" ] .
  OPTIONAL {?wikimediaLink schema:about ?place;
            schema:inLanguage "en";
            schema:isPartOf <https://commons.wikimedia.org/>} .

  OPTIONAL {?place wdt:P18 ?image } .
  OPTIONAL {?place wdt:P1329 ?phoneNumber}.
  OPTIONAL {?place wdt:P856 ?website} .
 }
"""


let WDInstances: Set<String> = {
    if let url = Bundle.main.url(forResource: "WDInstances", withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            let list = try JSONDecoder().decode([String].self, from: data)
            return Set<String>(list)
        } catch {
            fatalError("\(#function): \(error.localizedDescription)")
        }
    } else {
        fatalError("\(#function): RESOURCE NOT FOUND")
    }
}()


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
                        print("\(#function): \(error.localizedDescription)")
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
                    print("\(#function): \(error.localizedDescription)")
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
                "titles" : title,
                "format" : "json"
            ]
            let url = "https://en.wikipedia.org/w/api.php"
            AF.request(url, parameters: parameters).responseJSON(queue: .global(qos: .utility)) { response in
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
    
    func getCityDetail(CityName: String, WikidataId: String) -> Promise<WDCity> {
        return Promise<WDCity>(in: .background) { resolve, reject, status in
            let parameters = [
                "query": cityDetailsQuery,
                "format": "json"
            ]
            let url = "https://query.wikidata.org/sparql"
            AF.request(url, parameters: parameters).responseJSON(queue: .global(qos: .utility)) { response in
                switch response.result {
                case .success:
                    guard let data = response.data else { reject(UnknownApiError()); return }
                    do {
                        let city = try JSONDecoder().decode(WDCity.self, from: data)
                        resolve(city)
                    } catch let error as NSError {
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
    
    func getNearbyPlaces(location: CLLocationCoordinate2D) -> Promise<[WDPlace]> {
        return Promise<[WDPlace]>(in: .background) { resolve, reject, status in
            let parameters = [
                "query": nearbyPlacesQuery.replacingOccurrences(of: "<LATITUDE>", with: String(location.latitude))
                    .replacingOccurrences(of: "<LONGITUDE>", with: String(location.longitude)),
                "format": "json"
            ]
            let url = "https://query.wikidata.org/sparql"
            AF.request(url, parameters: parameters).responseJSON(queue: .global(qos: .utility)) { response in
                switch response.result {
                case .success:
                    guard let data = response.data else { reject(UnknownApiError()); return }
                    do {
                        let results = try JSONDecoder().decode(WDPlaceResponse.self, from: data)
                        let places = results.places.filter { WDInstances.contains($0.instance) }
                        resolve(places)
                    } catch let error as NSError {
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
    
    func getPhoto(imageURL: URL) -> Promise<UIImage> {
        return Promise<UIImage>(in: .utility) { resolve, reject, status in
            if let data = try? Data(contentsOf: imageURL){
                if let img = UIImage(data: data) {
                    resolve(img)
                    return;
                }
                else {
                    reject(UnknownApiError())
                }
            }
            else {
                reject(UnknownApiError())
                return
            }
        }
    }
}


