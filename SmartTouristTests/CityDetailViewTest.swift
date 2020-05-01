//
//  CityDetailViewTest.swift
//  SmartTouristTests
//
//  Created on 01/05/2020
//

import XCTest
@testable import SmartTourist
import Tempura
import TempuraTesting
import Katana


class CityDetailViewTest: XCTestCase, ViewControllerTestCase {
    var viewController: CityDetailViewController {
        let store = Store<AppState, DependenciesContainer>()
        let vc = CityDetailViewController(store: store, localState: CityDetailLocalState())
        return vc
    }
    
    func configure(vc: CityDetailViewController, for testCase: String) {
        if testCase == TestCase.CityDetailViewAllLoaded.rawValue {
            let localState = CityDetailLocalState(allLoaded: true)
            vc.viewModel = CityDetailViewModel(state: vc.store.state, localState: localState)
        } else if testCase == TestCase.CityDetailViewNotLoaded.rawValue {
            let localState = CityDetailLocalState(allLoaded: false)
            vc.viewModel = CityDetailViewModel(state: vc.store.state, localState: localState)
        }
    }
    
    func test() {
        let testCases = [
            TestCase.CityDetailViewAllLoaded.rawValue,
            TestCase.CityDetailViewNotLoaded.rawValue
        ]
        //self.uiTest(testCases: testCases, context: UITests.VCContext<CityDetailViewTest.VC>())
    }
}
