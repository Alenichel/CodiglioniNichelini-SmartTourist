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
import SwiftyXMLParser


class WikipediaAPI {
    
    static let shared = WikipediaAPI()
    let language = WikipediaLanguage("en")
    private let cache = NSCache<NSString, NSString>()
    private let photoCache = NSCache<NSString, UIImage>()
    
    private init() {
        WikipediaNetworking.appAuthorEmailForAPI = "ale.nichelg@gmail.com"
    }
    
    static let wdInstances: Set<String> = {
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
    
    private func getNearbyPlacesQuery(location: CLLocationCoordinate2D) -> String {
        return """
        SELECT DISTINCT ?place ?placeLabel ?location ?image ?instance ?phoneNumber ?website ?wikipediaLink ?wikimediaLink
        WHERE {
            SERVICE wikibase:label { bd:serviceParam wikibase:language "en" }
            SERVICE wikibase:around {
                ?place wdt:P625 ?location .
                bd:serviceParam wikibase:center "Point(\(location.longitude) \(location.latitude))"^^geo:wktLiteral .
                bd:serviceParam wikibase:radius "1" .
            }
            ?place wdt:P31 ?instance  .
            ?wikipediaLink schema:about ?place;
                           schema:inLanguage "en";
                           schema:isPartOf [ wikibase:wikiGroup "wikipedia" ] .
            OPTIONAL {?wikimediaLink schema:about ?place;
                                     schema:inLanguage "en";
                                     schema:isPartOf <https://commons.wikimedia.org/>} .
            ?place wdt:P18 ?image .
            OPTIONAL {?place wdt:P1329 ?phoneNumber}.
            OPTIONAL {?place wdt:P856 ?website} .
        }
        """
    }
    
    private func getCityDetailsQuery(_ cityId: String) -> String {
        return"""
        SELECT DISTINCT ?city ?cityLabel ?country ?countryLabel ?population ?area ?elevation ?link ?facebookPageId ?facebookPlacesId ?instagramUsername ?twitterUsername ?image ?coatOfArmsImage ?cityFlagImage WHERE {
            BIND( <http://www.wikidata.org/entity/\(cityId)> as ?city ).
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
    }
    
    private func getMissingPlaceDetailsQuery(id: String) -> String {
        return """
        SELECT DISTINCT ?instance ?image ?phoneNumber ?website ?wikimediaLink WHERE {
            BIND( <http://www.wikidata.org/entity/\(id)> as ?place ).
            ?place wdt:P31 ?instance  .
            OPTIONAL {?place wdt:P18 ?image } .
            OPTIONAL {?place wdt:P1329 ?phoneNumber}.
            OPTIONAL {?place wdt:P856 ?website} .
            OPTIONAL {?wikimediaLink schema:about ?place;
                                     schema:inLanguage "en";
                                     schema:isPartOf <https://commons.wikimedia.org/>} .
        }
        """
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
    
    func findExactArticleName(searchTerms: String) -> Promise<String> {
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
    
    func findExactArticleName(searchTerms: String, coordinates: CLLocationCoordinate2D) -> Promise<String> {
        return Promise<String>(in: .background) { resolve, reject, status in
            let _ = Wikipedia.shared.requestNearbyResults(language: self.language, latitude: Double(coordinates.latitude), longitude: Double(coordinates.longitude), maxCount: 50) { (articlePreviews, resultsLanguage, error) in
                guard error == nil, let articlePreviews = articlePreviews else {
                    reject(UnknownApiError())
                    return
                }
                
                let fuse = Fuse(threshold: 0.5)
                
                let titles = articlePreviews.map { article -> String in
                    return article.title
                }
                let results = fuse.search(searchTerms.stripped, in: titles).sorted {
                    if $0.score == $1.score {
                        return titles[$0.index].count < titles[$1.index].count
                    } else {
                        return $0.score < $1.score
                    }
                }
                
                guard results.count > 0 else {
                    reject(UnknownApiError())
                    return
                }
                
                let result = titles[results.first!.index]
                resolve(result)
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
                                                resolve(wikidataId)
                                                return
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        reject(UnknownApiError())
                    } catch {
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
    
    func getCityDetail(wikidataId: String) -> Promise<WDCity> {
        return Promise<WDCity>(in: .background) { resolve, reject, status in
            let parameters = [
                "query": self.getCityDetailsQuery(wikidataId),
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
                    } catch {
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
                "query": self.getNearbyPlacesQuery(location: location),
                "format": "json"
            ]
            let url = "https://query.wikidata.org/sparql"
            AF.request(url, parameters: parameters).responseJSON(queue: .global(qos: .utility)) { response in
                switch response.result {
                case .success:
                    guard let data = response.data else { reject(UnknownApiError()); return }
                    do {
                        let results = try JSONDecoder().decode(WDPlaceResponse.self, from: data)
                        let places = results.places.filter { WikipediaAPI.wdInstances.contains($0.instance) }
                        resolve(places)
                    } catch {
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
    
    func getArticle(articleName: String) -> Promise<String> {
        let parameters = [
            "titles" : articleName
        ]
        return Promise<String> (in: .background) { resolve, reject, status in
            let url = "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1"
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
                                        if let extract = number["extract"] as? String {
                                                resolve(extract)
                                                return
                                        }
                                    }
                                }
                            }
                        }
                        reject(UnknownApiError())
                    } catch {
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
    
    func getMissingDetail(place: WDPlace) -> Promise<Void> {
        return Promise<Void> (in: .utility) { resolve, reject, status in
            let parameters = [
                "query": self.getMissingPlaceDetailsQuery(id: place.placeID),
                "format": "json"
            ]
            let url = "https://query.wikidata.org/sparql"
            AF.request(url, parameters: parameters).responseJSON(queue: .global(qos: .utility)) { response in
                switch response.result {
                case .success:
                    guard let data = response.data else { reject(UnknownApiError()); return }
                    do {
                        guard
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                            let results = json["results"] as? [String: Any],
                            let bindings = results["bindings"] as? [[String: Any]],
                            let firstResult = bindings.first
                        else {
                            reject(UnknownApiError())
                            return
                        }
                        if let instance = firstResult["instance"] as? [String: Any],
                            let value = instance["value"] as? String,
                            let instanceIdRange = value.range(of: #"Q[0-9]+"#, options: .regularExpression) {
                            place.instance = String(value[instanceIdRange])
                        }
                        if let wikimediaLink = firstResult["wikimediaLink"] as? [String: Any],
                            let value = wikimediaLink["value"] as? String {
                            place.wikimediaLink = value
                        }
                        if let website = firstResult["website"] as? [String: Any],
                            let value = website["value"] as? String {
                            place.website = value
                        }
                        if let photo = firstResult["image"] as? [String: Any],
                            let value = photo["value"] as? String {
                            place.photos?.append(URL(string: value)!)
                        }
                        resolve(())
                    } catch {
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
        return Promise<UIImage>(in: .background) { resolve, reject, status in
            let urlString = imageURL.absoluteString as NSString
            if let image = self.photoCache.object(forKey: urlString) {
                resolve(image)
            } else if let data = try? Data(contentsOf: imageURL){
                if let img = UIImage(data: data) {
                    self.photoCache.setObject(img, forKey: urlString)
                    resolve(img)
                    return;
                }
                else {
                    reject(UnknownApiError())
                }
            } else {
                reject(UnknownApiError())
                return
            }
        }
    }
    
    private func getImageFiles(from title: String, limit: Int) -> Promise<[String]> {
        return Promise<[String]>(in: .background) { resolve, reject, status in
            let parameters = [
                "action": "query",
                "prop": "images",
                "imlimit": "\(limit)",
                "redirects": "1",
                "titles": title,
                "format": "xml"
            ]
            AF.request("https://commons.wikimedia.org/w/api.php", parameters: parameters).responseData(queue: .global(qos: .utility)) { response in
                switch response.result {
                case .success:
                    guard let data = response.data else { reject(UnknownApiError()); return }
                    var files = [String]()
                    let xml = XML.parse(data)
                    for im in xml.api.query.pages.page.images.im {
                        if let title = im.attributes["title"] {
                            files.append(title)
                        }
                    }
                    resolve(files)
                case .failure:
                    guard let error = response.error else { reject(UnknownApiError()); return }
                    print("\(#function): \(error.localizedDescription)")
                    reject(error)
                }
            }
        }
    }
    
    private func getImageUrls(from files: [String]) -> Promise<[URL]> {
        return Promise<[URL]>(in: .background) { resolve, reject, status in
            let filesString = files.joined(separator: "|")
            let parameters = [
                "image": filesString,
                "thumbwidth": "\(Int(UIScreen.main.bounds.width))"
            ]
            AF.request("https://tools.wmflabs.org/magnus-toolserver/commonsapi.php", parameters: parameters).responseData(queue: .global(qos: .utility)) { response in
                switch response.result {
                case .success:
                    guard let data = response.data else { reject(UnknownApiError()); return }
                    var urls = [String]()
                    let xml = XML.parse(data)
                    for image in xml.response.image {
                        if let url = image.file.urls.file.text {
                            urls.append(url)
                        }
                    }
                    resolve(urls.map { URL(string: $0)! })
                case .failure:
                    guard let error = response.error else { reject(UnknownApiError()); return }
                    print("\(#function): \(error.localizedDescription)")
                    reject(error)
                }
            }
        }
    }
    
    func getImageUrls(from title: String, limit: Int = 10) -> Promise<[URL]> {
        return self.getImageFiles(from: title.stripped, limit: limit).then(self.getImageUrls)
    }
}
