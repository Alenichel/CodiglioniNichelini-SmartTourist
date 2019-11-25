//
//  WelcomeViewController.swift
//  SmartTourist
//
//  Created on 25/11/2019
//

import UIKit
import Tempura


class WelcomeViewController: ViewControllerWithLocalState<WelcomeView> {
    override func setupInteraction() {
        self.rootView.didTapButton = { [unowned self] in
            self.localState.pageIndex += 1
            if self.localState.pageIndex >= 3 {
                self.dispatch(Hide(animated: true))
                self.dispatch(SetFirstLaunch())
            }
        }
    }
}


extension WelcomeViewController: RoutableWithConfiguration {
    var routeIdentifier: RouteElementIdentifier {
        ScreenID.welcome.rawValue
    }
    
    var navigationConfiguration: [NavigationRequest : NavigationInstruction] {
        [
            .hide(ScreenID.welcome): .dismissModally(behaviour: .hard)
        ]
    }
}


struct WelcomeLocalState: LocalState {
    var pageIndex: Int = 0
}
