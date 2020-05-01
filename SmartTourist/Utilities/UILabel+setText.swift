//
//  UILabel+setText.swift
//  SmartTourist
//
//  Created on 07/03/2020
//

import UIKit
import CoreLocation


extension UILabel {
    func setText(title: String ,completion: @escaping () -> Void) {
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
