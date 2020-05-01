//
//  Array+WDPlace+blacklist.swift
//  SmartTourist
//
//  Created on 16/03/2020
//

import Foundation
import SigmaSwiftStatistics


class WDPlaceFilter {
    var places: [WDPlace]
    
    init(_ places: [WDPlace]) {
        self.places = places
    }
    
    func minRatings(_ threshold: Double) -> WDPlaceFilter {
        self.places = self.places.filter { place in
            guard let rating = place.rating else { return false }
            return rating >= threshold
        }
        return self
    }
    
    func nonNegativeRatings() -> WDPlaceFilter {
        return self.minRatings(0.0)
    }
    
    func noEmojis() -> WDPlaceFilter {
        self.places = self.places.filter { !$0.name.containsEmoji }
        return self
    }
    
    func minTotalRatings(_ minRatingsTotal: Int) -> WDPlaceFilter {
        self.places = self.places.filter { place in
            guard let userRatingsTotal = place.userRatingsTotal else { return false }
            return userRatingsTotal > minRatingsTotal
        }
        return self
    }
    
    func minTotalRatingsPercentile(_ alpha: Double) -> WDPlaceFilter {
        let ratings = self.places
            .filter { $0.userRatingsTotal != nil }
            .map { Double($0.userRatingsTotal!) }
        guard let percentile = Sigma.percentile(ratings, percentile: alpha) else { return self }
        //print("percentile = \(percentile)")
        return self.minTotalRatings(Int(percentile))
    }
}


extension Array where Element: WDPlace {
    var blacklisted: [WDPlace] {
        WDPlaceFilter(self)
            .noEmojis()
            .minRatings(2.5)
            .minTotalRatingsPercentile(0.05)
            .places
    }
}
