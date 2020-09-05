//
//  WikipediaAPI.swift
//  SmartTourist
//
//  Created on 03/12/2019
//

#if os(watchOS)
    import Foundation
#else
    import UIKit
#endif
import Hydra
import Fuse
import Alamofire
import MapKit
import SwiftyXMLParser


class WikipediaAPI {
    static let shared = WikipediaAPI()
    static let apiThrottleTime: Double = 15   // seconds

    private let cache = NSCache<NSString, NSString>()
    private let photoCache = NSCache<NSString, UIImage>()
    
    private init() {}
    
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
    
    private func getNearbyPlacesQuery(location: CLLocationCoordinate2D, radius: Int, isArticleMandatory: Bool) -> String {
        var query = """
        SELECT DISTINCT ?place ?placeLabel ?location ?image ?instance ?website ?wikipediaLink
        WHERE {
            SERVICE wikibase:label { bd:serviceParam wikibase:language "en, it" }
            SERVICE wikibase:around {
                ?place wdt:P625 ?location .
                bd:serviceParam wikibase:center "Point(\(location.longitude) \(location.latitude))"^^geo:wktLiteral .
                bd:serviceParam wikibase:radius "\(radius)" .
            }
            ?place wdt:P31 ?instance .
        ?place wdt:P18 ?image .
        OPTIONAL {?place wdt:P856 ?website} .
        """
        if !isArticleMandatory {
            query += "OPTIONAL "
        }
        query += """
            {?wikipediaLink schema:about ?place;
            schema:inLanguage "en";
            schema:isPartOf [ wikibase:wikiGroup "wikipedia" ]} .
        }
        """
        return query
    }
    
    private func getCityDetailsQuery(_ cityId: String) -> String {
        return"""
        SELECT DISTINCT ?city ?cityLabel ?country ?countryLabel ?population ?area ?elevation ?link ?facebookPageId ?facebookPlacesId ?instagramUsername ?twitterUsername ?image ?coatOfArmsImage ?cityFlagImage ?countryCode ?wikipediaLink WHERE {
            BIND (<http://www.wikidata.org/entity/\(cityId)> as ?city).
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
            OPTIONAL {?country wdt:P297 ?countryCode}.
            OPTIONAL {?wikipediaLink schema:about ?city;
              schema:inLanguage "en";
              schema:isPartOf [ wikibase:wikiGroup "wikipedia" ]}.
            SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
        }
        """
    }
    
    private func getMissingPlaceDetailsQuery(_ id: String) -> String {
        return """
        SELECT DISTINCT ?instance ?image ?website ?wikimediaLink WHERE {
            BIND(<http://www.wikidata.org/entity/\(id)> as ?place).
            ?place wdt:P31 ?instance .
            OPTIONAL {?place wdt:P18 ?image} .
            OPTIONAL {?place wdt:P856 ?website} .
            OPTIONAL {?wikimediaLink schema:about ?place;
                                     schema:inLanguage "en";
                                     schema:isPartOf <https://commons.wikimedia.org/>} .
        }
        """
    }
    
    func findExactArticleName(searchTerms: String, coordinates: CLLocationCoordinate2D) -> Promise<String> {
        return Promise<String>(in: .background) { resolve, reject, status in
            let parameters = [
                "action": "query",
                "ggscoord": "\(coordinates.latitude)|\(coordinates.longitude)",
                "format": "xml",
                "generator": "geosearch",
                "ggsradius": "10000",
                "prop": "coordinates",
                "codistancefrompoint": "\(coordinates.latitude)|\(coordinates.longitude)",
                "colimit": "50"
            ]
            let url = "https://en.wikipedia.org/w/api.php"
            AF.request(url, parameters: parameters).responseData(queue: .global(qos: .utility)) { response in
                switch response.result {
                case .success:
                    guard let data = response.data else { reject(UnknownApiError()); return }
                    let xml = XML.parse(data)
                    let pages = xml.api.query.pages.page;
                    let titles = pages.map { $0.attributes["title"]! }
                    let fuse = Fuse(threshold: 0.5)
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
                case .failure:
                    guard let error = response.error else { reject(UnknownApiError()); return }
                    print("\(#function): \(error.localizedDescription)")
                    reject(error)
                }
            }
        }
    }
    
    func getWikidataId(title: String) -> Promise<String> {
        return Promise<String>(in: .background) { resolve, reject, status in
            let parameters = [
                "action" : "query",
                "prop" : "pageprops",
                "ppprop": "wikibase_item",
                "redirects": "1",
                "titles" : title,
                "format" : "xml"
            ]
            let url = "https://en.wikipedia.org/w/api.php"
            AF.request(url, parameters: parameters).responseData(queue: .global(qos: .utility)) { response in
                switch response.result {
                case .success:
                    guard let data = response.data else { reject(UnknownApiError()); return }
                    let xml = XML.parse(data)
                    if let wdID = xml.api.query.pages.page.pageprops.attributes["wikibase_item"] {
                        resolve(wdID)
                    } else {
                        reject(UnknownApiError())
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
                        if city.population == nil && city.area == nil && city.elevation == nil {
                            reject(DisambiguationPageError())
                        } else {
                            resolve(city)
                        }
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
    
    func getCityArticle(_ city: WDCity) -> Promise<String> {
        return Promise<String>(in: .background) { resolve, reject, status in
            guard let wikiLink = city.wikipediaLink,
                let wikiName = wikiLink.components(separatedBy: "/").last
            else { reject(UnknownApiError()); return }
            let url = "https://en.wikipedia.org/api/rest_v1/page/summary/\(wikiName)"
            AF.request(url).responseJSON(queue: .global(qos: .utility)) { response in
                switch response.result {
                case .success:
                    guard let data = response.data else { reject(UnknownApiError()); return }
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            if let extract = json["extract"] as? String {
                                resolve(extract)
                                return
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
    
    func getNearbyPlaces(location: CLLocationCoordinate2D, radius: Int, isArticleMandatory: Bool) -> Promise<[WDPlace]> {
        return Promise<[WDPlace]>(in: .background) { resolve, reject, status in
            let parameters = [
                "query": self.getNearbyPlacesQuery(location: location, radius: radius, isArticleMandatory: isArticleMandatory),
                "format": "json"
            ]
            let url = "https://query.wikidata.org/sparql"
            AF.request(url, parameters: parameters).responseJSON(queue: .global(qos: .utility)) { response in
                switch response.result {
                case .success:
                    guard let data = response.data else { reject(UnknownApiError()); return }
                    do {
                        let results = try JSONDecoder().decode(WDPlaceResponse.self, from: data)
                        let places = results.places.filter { place in
                            let rightInstance = WikipediaAPI.wdInstances.contains(place.instance)
                            let nonQLabel = place.name.range(of: #"Q[0-9]+"#, options: .regularExpression) == nil
                            return rightInstance && nonQLabel
                        }
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
                "query": self.getMissingPlaceDetailsQuery(place.placeID),
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
                print("Getting photo from cache")
                resolve(image)
            } else if let data = try? Data(contentsOf: imageURL){
                print("Requesting photo from API")
                if let img = UIImage(data: data) {
                    self.photoCache.setObject(img, forKey: urlString)
                    resolve(img)
                    return;
                } else {
                    reject(UnknownApiError())
                }
            } else {
                reject(UnknownApiError())
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
                "action": "query",
                "titles": filesString,
                "prop": "imageinfo",
                "iiprop": "url",
                "format": "xml"
            ]
            AF.request("https://en.wikipedia.org/w/api.php", parameters: parameters).responseData(queue: .global(qos: .utility)) { response in
                switch response.result {
                case .success:
                    guard let data = response.data else { reject(UnknownApiError()); return }
                    var urls = [String]()
                    let xml = XML.parse(data)
                    for page in xml.api.query.pages.page {
                        if let url = page.imageinfo.ii.attributes["url"] {
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


class DisambiguationPageError: Error {}
