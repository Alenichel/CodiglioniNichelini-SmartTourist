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
    
    func minTotalRatings(_ minRatingsTotal: Int) -> GPPlaceFilter {
        self.places = self.places.filter {
            guard let userRatingsTotal = $0.userRatingsTotal else { return false }
            return userRatingsTotal > minRatingsTotal
        }
        return self
    }
    
    func minTotalRatingsNormalized(_ threshold: Double) -> GPPlaceFilter {
        let placesWithRatings = self.places.filter { $0.userRatingsTotal != nil }
        let userRatingsTotals = placesWithRatings.map { $0.userRatingsTotal! }
        guard let max = userRatingsTotals.max() else { return self }
        let minRatingsTotal = Int(Double(max) * threshold)
        return self.minTotalRatings(minRatingsTotal)
    }
}


extension Array where Element: GPPlace {
    var blacklisted: [GPPlace] {
        GPPlaceFilter(self)
            .nonNegativeRatings()
            .noEmojis()
            //.minTotalRatings(100)
            .places
    }
}
