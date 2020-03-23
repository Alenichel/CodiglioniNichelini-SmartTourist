//
//  Array+sortedInsert.swift
//  SmartTourist
//
//  Created on 23/03/2020
//

import Foundation


extension Array where Element: Comparable {
    mutating func sortedInsert(_ element: Element) {
        if let index = self.firstIndex(where: { $0 > element}) {
            self.insert(element, at: index)
        } else {
            self.insert(element, at: self.count)
        }
    }
}
