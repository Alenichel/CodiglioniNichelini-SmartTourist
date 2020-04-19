//
//  UILabel+setText.swift
//  SmartTourist
//
//  Created on 07/03/2020
//

import UIKit
import GoogleMaps

extension UILabel {
    func setText(coordinates: CLLocationCoordinate2D ,searchTerms: String, completion: @escaping () -> Void) {
        /*WikipediaAPI.shared.search(searchTerms: searchTerms).then(in: .main) { description in
            self.text = description
        }.always {
            completion()
        }*/
        /*WikipediaAPI.shared.search(searchTerms: searchTerms).then(in: .main) { description in
            self.text = description
            completion()
        }*/
        WikipediaAPI.shared.getDescriptionFromNearbyArticles(coordinates: coordinates, searchTerms: searchTerms).then(in: .main) { description in
            self.text = description
        }.always {
            completion()
        }
    }
    
    func setText(actualLocation: CLLocationCoordinate2D, attraction: WDPlace) {
        GoogleAPI.shared.getTravelTime(origin:  actualLocation, destination: attraction.location).then(in: .main) { travelTime in
            self.text = travelTime
        }
    }
}
