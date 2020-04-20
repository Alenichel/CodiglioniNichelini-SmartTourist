//
//  UILabel+setText.swift
//  SmartTourist
//
//  Created on 07/03/2020
//

import UIKit
import GoogleMaps

extension UILabel {
    func setText(title: String ,completion: @escaping () -> Void) {
        /*WikipediaAPI.shared.search(searchTerms: searchTerms).then(in: .main) { description in
            self.text = description
        }.always {
            completion()
        }*/
        /*WikipediaAPI.shared.search(searchTerms: searchTerms).then(in: .main) { description in
            self.text = description
            completion()
        }*/
        WikipediaAPI.shared.getArticle(articleName: title).then(in: .main) { description in
            self.text = description
        }.always {
            completion()
        }
    }
    
    func setText(actualLocation: CLLocationCoordinate2D, attraction: WDPlace) {
        MapsAPI.shared.getTravelTime(from:  actualLocation, to: attraction.location).then(in: .main) { travelTime in
            self.text = travelTime
        }
    }
}
