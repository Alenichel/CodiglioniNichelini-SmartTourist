//
//  FullScreenMapTest.swift
//  SmartTouristTests
//
//  Created on 05/09/2020
//

import XCTest
@testable import SmartTourist
import Tempura
import TempuraTesting
import MapKit


class FullScrenMapTest: XCTestCase, ViewTestCase {
    var mapRendered = false
    
    let localState = FullScreenMapLocalState(attractions: WDPlace.testPlaces)
    
    func isViewReady(_ view: FullScreenMapView, identifier: String) -> Bool {
        view.mapView.delegate = self
        return self.mapRendered && view.markerPool.markers.count > 0
    }
    
    func test() {
        self.uiTest(testCases: [
            TestCase.FullScreenMap.rawValue: FullScreenMapViewModel(state: nil, localState: self.localState)!
        ])
    }
}


extension FullScrenMapTest: MKMapViewDelegate {
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        self.mapRendered = fullyRendered
    }
}
