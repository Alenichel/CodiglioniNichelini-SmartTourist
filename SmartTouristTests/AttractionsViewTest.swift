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
import Hydra
import CoreLocation
import MapKit


class AttractionsViewTest: XCTestCase, ViewControllerTestCase {
    var allLoaded: Bool = false
    
    let _viewController: AttractionsViewController = {
        let store = Store<AppState, DependenciesContainer>()
        return AttractionsViewController(store: store, localState: AttractionsLocalState(selectedSegmentIndex: .nearest))
    }()
    
    var viewController: AttractionsViewController {
        return _viewController
    }
    
    static let location = CLLocationCoordinate2D(latitude: 51.50998, longitude: -0.1337)
    
    let appState: AppState = {
        var state = AppState()
        state.locationState.nearestPlaces = WDPlace.testPlaces
        state.locationState.actualLocation = location
        state.locationState.mapLocation = location
        state.locationState.currentCity = "London"
        state.locationState.mapCentered = true
        state.needToMoveMap = true
        return state
    }()
    
    var localState: AttractionsLocalState {
        return AttractionsLocalState(selectedSegmentIndex: .nearest)
    }
    
    func isViewReady(_ view: MapView, identifier: String) -> Bool {
        guard let model = view.model else { return false }
        if self.viewController.mapLoaded && model.places.count > 0 && !self.allLoaded {
            async(in: .background) {
                sleep(5)
                self.allLoaded = true
            }
        }
        return self.allLoaded
    }
    
    func testMapView() {
        self.uiTest(testCases: [
            TestCase.AttractionsView.rawValue: AttractionsViewModel(state: self.appState, localState: self.localState)!
        ])
    }
}
