//
//  Array+GPPlace+blacklist.swift
//  SmartTourist
//
//  Created on 16/03/2020
//

import Foundation


class GPPlaceFilter {
    var places: [GPPlace]
    
    init(_ places: [GPPlace]) {
        self.places = places
    }
    
    func nonNegativeRatings() -> GPPlaceFilter {
        self.places = self.places.filter { place in
            guard let rating = place.rating else { return false }
            return rating > 0.0
        }
        return self
    }
    
    func noEmojis() -> GPPlaceFilter {
        self.places = self.places.filter { !$0.name.containsEmoji }
        return self
    }
}


extension Array where Element: GPPlace {
    var blacklisted: [GPPlace] {
        GPPlaceFilter(self)
            .nonNegativeRatings()
            .noEmojis()
            .places
    }
}
