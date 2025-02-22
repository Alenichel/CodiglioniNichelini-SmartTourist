//
//  UILabel+setText.swift
//  SmartTourist
//
//  Created on 07/03/2020
//

import UIKit
import CoreLocation

let defaultDescription = "No description is available. If you are familiar with this place, please consider contributing. Together we can make the world a better place."

extension UILabel {
    func setText(title: String, completion: @escaping () -> Void) {
        WikipediaAPI.shared.getArticle(articleName: title).then(in: .main) { description in
            self.text = description
        }.always(in: .main) {
            if self.text == nil {
                self.text = defaultDescription;
            }
            completion()
        }
    }
    
    func setText(city: WDCity, completion: @escaping () -> Void) {
        WikipediaAPI.shared.getCityArticle(city).then(in: .main) { description in
            self.text = description
        }.always(in: .main) {
            if self.text == nil {
                self.text = defaultDescription
            }
            completion()
        }
    }
}
