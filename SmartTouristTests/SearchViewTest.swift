//
//  SearchViewTest.swift
//  SmartTouristTests
//
//  Created on 05/09/2020
//

import XCTest
@testable import SmartTourist
import Katana
import Tempura
import TempuraTesting
import MapKit


class SearchViewTest: XCTestCase, ViewControllerTestCase {
    var viewController: SearchViewController {
        let store = Store<AppState, DependenciesContainer>()
        let localState = SearchViewLocalState(results: [])
        let vc = SearchViewController(store: store, localState: localState)
        return vc
    }
    
    let emptyViewModel = SearchViewModel(state: nil, localState: SearchViewLocalState(results: []))!
    
    func configure(vc: SearchViewController, for testCase: String, model: SearchViewModel) {
        if testCase == TestCase.Search.rawValue {
            let queryFragment = "Bucking"
            vc.rootView.searchBar.text = queryFragment
            vc.searchCompleter.queryFragment = queryFragment
            vc.viewModel = SearchViewModel(state: nil, localState: vc.localState)
        } else {
            vc.viewModel = model
        }
    }
    
    func isViewReady(_ view: SearchView, identifier: String) -> Bool {
        if identifier == TestCase.Search.rawValue {
            guard let model = view.model else { return false }
            return model.results.count > 0
        } else {
            return true
        }
    }
    
    func test() {
        self.uiTest(testCases: [
            TestCase.SearchEmpty.rawValue: emptyViewModel,
            TestCase.Search.rawValue: emptyViewModel
        ])
    }
}
