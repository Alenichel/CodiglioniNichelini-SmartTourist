//
//  UITextView+setText.swift
//  SmartTourist
//
//  Created on 05/12/2019
//

import Foundation
import UIKit

extension UITextView {
    func setText(searchTerms: String){
        WikipediaAPI.shared.search(searchTerms: searchTerms).then { description in
            self.text = description
        }
    }
}
