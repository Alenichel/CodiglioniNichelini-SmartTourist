//
//  UILabel+setText.swift
//  SmartTourist
//
//  Created on 07/03/2020
//

import UIKit


extension UILabel {
    func setText(searchTerms: String, completion: @escaping () -> Void) {
        WikipediaAPI.shared.search(searchTerms: searchTerms).then { description in
            self.text = description
        }.always {
            completion()
        }
    }
}
