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
    func setText(coordinates: CLLocationCoordinate2D, searchTerms: String, completion: @escaping () -> Void) {
        /*WikipediaAPI.shared.getArticleNameFromNearbyArticles(coordinates: coordinates, searchTerms: searchTerms).then(WikipediaAPI.shared.search).then { description in
            self.text = description*/
        WikipediaAPI.shared.search(searchTerms: searchTerms).then { description in
            self.text = description
            completion()
        }
    }
}
