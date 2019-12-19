//
//  UITextView+setText.swift
//  SmartTourist
//
//  Created on 05/12/2019
//

import Foundation
import UIKit
import GoogleMaps

extension UITextView {
    func setText(coordinates: CLLocationCoordinate2D ,searchTerms: String){
        /*WikipediaAPI.shared.getArticleNameFromNearbyArticles(coordinates: coordinates, searchTerms: searchTerms).then(WikipediaAPI.shared.search).then { description in
            self.text = description*/
        WikipediaAPI.shared.getArticleNameFromNearbyArticles(coordinates: coordinates, searchTerms: searchTerms).then { description in
        self.text = description
        }
    }
}
