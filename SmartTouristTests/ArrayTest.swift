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
    func testSortedInsert() {
        var array = [1, 3, 7, 9]
        for _ in 0..<10 {
            let x = Int.random(in: 0...10)
            array.sortedInsert(x)
            XCTAssert(array.contains(x))
            for i in array.startIndex..<array.endIndex {
                for j in array.startIndex...i {
                    XCTAssertLessThanOrEqual(array[j], array[i])
                }
            }
        }
    }
}
