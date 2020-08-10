//
//  AttractionDetailTest.swift
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


class AttractionDetailTest: XCTestCase, ViewControllerTestCase {
    static let place = WDPlace.testPlaces[0]
    static let location = CLLocationCoordinate2D(latitude: 51.501476, longitude: -0.140634)    //  Buckingham Palace
    static let localState = AttractionDetailLocalState(attraction: AttractionDetailTest.place)
    
    var store: Store<AppState, DependenciesContainer> {
        return (UIApplication.shared.delegate as! AppDelegate).store
    }
    
    var _viewController: AttractionDetailViewController?
    
    var viewController: AttractionDetailViewController {
        if self._viewController == nil {
            self._viewController = AttractionDetailViewController(store: self.store, localState: AttractionDetailLocalState(attraction: AttractionDetailTest.place))
        }
        return _viewController!
    }
    
    func isViewReady(_ view: AttractionDetailView, identifier: String) -> Bool {
        guard let model = view.model else { return false }
        return model.allLoaded && view.imageSlideshow.slideshowItems[0].imageView.image != nil
    }
    
    func testDetailView() {
        self.uiTest(testCases: [
            TestCase.AttractionDetail.rawValue: AttractionDetailViewModel(state: self.store.state, localState: AttractionDetailTest.localState)!
        ])
    }
}
