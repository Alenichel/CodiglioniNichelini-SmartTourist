//
//  AttractionsViewTest.swift
//  SmartTouristTests
//
//  Created on 10/08/2020
//

import XCTest
@testable import SmartTourist
import Tempura
import TempuraTesting
import Katana
import CoreLocation
import MapKit


class AttractionsViewTest: XCTestCase, ViewControllerTestCase {
    let _viewController: AttractionsViewController = {
        let store = Store<AppState, DependenciesContainer>()
        return AttractionsViewController(store: store, localState: AttractionsLocalState(selectedSegmentIndex: .nearest))
    }()
    
    var viewController: AttractionsViewController {
        return _viewController
    }
    
    let appState: AppState = {
        var state = AppState()
        let location = CLLocationCoordinate2D(latitude: 51.501476, longitude: -0.140634)    // Should be Buckingham Palace
        state.locationState.nearestPlaces = WDPlace.testPlaces
        state.locationState.actualLocation = location
        state.locationState.mapLocation = location
        state.locationState.currentCity = "London"
        state.locationState.mapCentered = true
        state.needToMoveMap = true
        print(state.pedometerState)
        return state
    }()
    
    var localState: AttractionsLocalState {
        return AttractionsLocalState(selectedSegmentIndex: .nearest)
    }
    
    func isViewReady(_ view: MapView, identifier: String) -> Bool {
        guard let model = view.model else { return false }
        return self.viewController.mapLoaded && model.places.count > 0
    }
    
    func testMapView() {
        self.uiTest(testCases: [
            TestCase.AttractionsView.rawValue: AttractionsViewModel(state: self.appState, localState: self.localState)!
        ])
    }
}
