//
//  UILabel+setText.swift
//  SmartTourist
//
//  Created on 07/03/2020
//

import UIKit
import GoogleMaps

extension UILabel {
    func setText(searchTerms: String, completion: @escaping () -> Void) {
        WikipediaAPI.shared.search(searchTerms: searchTerms).then(in: .main) { description in
            self.text = description
        }.always {
            completion()
        }
    }
    
    func setText(actualLocation: CLLocationCoordinate2D, attraction: GPPlace, completion: @escaping () -> Void) {
        GoogleAPI.shared.getTravelTime(origin:  actualLocation, destination: attraction.location).then(in: .main) { travelTime in
            self.text = travelTime
        }
        completion()
    }
}
