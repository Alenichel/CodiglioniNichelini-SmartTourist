//
//  WelcomeViewTest.swift
//  SmartTouristTests
//
//  Created on 01/05/2020
//

import XCTest
@testable import SmartTourist
import Tempura
import TempuraTesting
import Katana


class WelcomeViewTest: XCTestCase, ViewControllerTestCase {
    var viewController: WelcomeViewController {
        let store = Store<AppState, DependenciesContainer>()
        let vc = WelcomeViewController(store: store, localState: WelcomeLocalState())
        return vc
    }
    
    func configure(vc: WelcomeViewController, for testCase: String) {
        if testCase == TestCase.WelcomeViewAllEnabled.rawValue {
            let localState = WelcomeLocalState(locationButtonEnabled: false, notificationsButtonEnabled: false)
            vc.viewModel = WelcomeViewModel(state: vc.store.state, localState: localState)
        } else if testCase == TestCase.WelcomeViewAllDisabled.rawValue {
            let localState = WelcomeLocalState(locationButtonEnabled: true, notificationsButtonEnabled: true)
            vc.viewModel = WelcomeViewModel(state: vc.store.state, localState: localState)
        }
    }
    
    func test() {
        let testCases = [
            TestCase.WelcomeViewAllEnabled.rawValue,
            TestCase.WelcomeViewAllDisabled.rawValue
        ]
        self.uiTest(testCases: testCases, context: UITests.VCContext<WelcomeViewTest.VC>())
    }
}
