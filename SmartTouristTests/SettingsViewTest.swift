//
//  SettingsViewTest.swift
//  SmartTouristTests
//
//  Created on 01/05/2020
//

import XCTest
@testable import SmartTourist
import Tempura
import TempuraTesting
import Katana


class SettingsViewTest: XCTestCase, ViewControllerTestCase {
    var viewController: SettingsViewController {
        let store = Store<AppState, DependenciesContainer>()
        let vc = SettingsViewController(store: store, localState: SettingsViewLocalState())
        return vc
    }
    
    func configure(vc: SettingsViewController, for testCase: String) {
        if testCase == TestCase.SettingsViewShowDebug.rawValue {
            let localState = SettingsViewLocalState(showDebug: true)
            vc.viewModel = SettingsViewModel(state: vc.store.state, localState: localState)
        } else if testCase == TestCase.SettingsViewHideDebug.rawValue {
            let localState = SettingsViewLocalState(showDebug: false)
            vc.viewModel = SettingsViewModel(state: vc.store.state, localState: localState)
        }
    }
    
    func test() {
        let testCases = [
            TestCase.SettingsViewShowDebug.rawValue,
            TestCase.SettingsViewHideDebug.rawValue
        ]
        self.uiTest(testCases: testCases, context: UITests.VCContext<SettingsViewTest.VC>())
    }
}
