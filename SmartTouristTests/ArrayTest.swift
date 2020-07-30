//
//  ArrayTest.swift
//  SmartTouristTests
//
//  Created on 27/04/2020
//

import XCTest
import CoreLocation
import Hydra
@testable import SmartTourist


class ArrayTest: XCTestCase {
    var places = [WDPlace]()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let location = CLLocationCoordinate2D(latitude: 51.501476, longitude: -0.140634)    // Should be Buckingham Palace
        self.places = try await(WikipediaAPI.shared.getNearbyPlaces(location: location, radius: 100, isArticleMandatory: false))
    }
    
    func testSortedInsert() {
        var array = [1, 3, 7, 9]
        let x = Int.random(in: 4..<7)
        array.sortedInsert(x)
        XCTAssert(array.contains(x))
        for i in array.startIndex..<array.endIndex {
            for j in array.startIndex...i {
                XCTAssertLessThanOrEqual(array[j], array[i])
            }
        }
    }
    
    func testFiltersMinRatings() {
        XCTAssertGreaterThan(self.places.count, 0)
        let minRating = 4.0
        let places = WDPlaceFilter(self.places).minRatings(minRating).places
        for p in places {
            if let rating = p.rating {
                XCTAssertGreaterThanOrEqual(rating, minRating)
            }
        }
    }
    
    func testFiltersNoEmoji() {
        XCTAssertGreaterThan(self.places.count, 0)
        let places = WDPlaceFilter(self.places).noEmojis().places
        for p in places {
            XCTAssertFalse(p.name.containsEmoji)
        }
    }
    
    func testFiltersMinTotalRatings() {
        XCTAssertGreaterThan(self.places.count, 0)
        let minTotalRatings = 1000
        let places = WDPlaceFilter(self.places).minTotalRatings(minTotalRatings).places
        for p in places {
            if let totalRatings = p.userRatingsTotal {
                XCTAssertGreaterThan(totalRatings, minTotalRatings)
            }
        }
    }
}
