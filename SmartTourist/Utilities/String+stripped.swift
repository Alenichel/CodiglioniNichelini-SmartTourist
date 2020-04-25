//
//  String+stripped.swift
//  SmartTourist
//
//  Created on 25/04/2020
//

import Foundation


extension String {
    var stripped: String {
        self.replacingOccurrences(of: "The ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
