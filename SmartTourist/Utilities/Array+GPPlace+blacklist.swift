//
//  Array+GPPlace+blacklist.swift
//  SmartTourist
//
//  Created on 16/03/2020
//

import Foundation
import SigmaSwiftStatistics


class GPPlaceFilter {
    var places: [GPPlace]
    
    init(_ places: [GPPlace]) {
        self.places = places
    }
    
    func minRatings(_ threshold: Double) -> GPPlaceFilter {
        self.places = self.places.filter { place in
            guard let rating = place.rating else { return false }
            return rating >= threshold
        }
        return self
    }
    
    func nonNegativeRatings() -> GPPlaceFilter {
        return self.minRatings(0.0)
    }
    
    func noEmojis() -> GPPlaceFilter {
        self.places = self.places.filter { !$0.name.containsEmoji }
        return self
    }
    
    func minTotalRatings(_ minRatingsTotal: Int) -> GPPlaceFilter {
        self.places = self.places.filter { place in
            guard let userRatingsTotal = place.userRatingsTotal else { return false }
            return userRatingsTotal > minRatingsTotal
        }
        return self
    }
    
    func minTotalRatingsPercentile(_ alpha: Double) -> GPPlaceFilter {
        let ratings = self.places
            .filter { $0.userRatingsTotal != nil }
            .map { Double($0.userRatingsTotal!) }
        guard let percentile = Sigma.percentile(ratings, percentile: alpha) else { return self }
        print("percentile = \(percentile)")
        return self.minTotalRatings(Int(percentile))
    }
}


extension Array where Element: GPPlace {
    var blacklisted: [GPPlace] {
        GPPlaceFilter(self)
            .noEmojis()
            .minRatings(2.5)
            .minTotalRatingsPercentile(0.05)
            .places
    }
}
