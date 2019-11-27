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
        self.rootView.didTapLocation = {
            print("Location tapped")
        }
        self.rootView.didTapNotifications = {
            NotificationManager.shared.requestAuth()
            self.localState.notificationsButtonEnabled = !NotificationManager.shared.notificationsEnabled
        }
        self.rootView.didTapClose = { [unowned self] in
            self.dispatch(Hide(animated: true))
        }
    }
}


extension WelcomeViewController: RoutableWithConfiguration {
    var routeIdentifier: RouteElementIdentifier {
        Screen.welcome.rawValue
    }
    
    var navigationConfiguration: [NavigationRequest : NavigationInstruction] {
        [
            .hide(Screen.welcome): .dismissModally(behaviour: .hard)
        ]
    }
}


struct WelcomeLocalState: LocalState {
    var locationButtonEnabled = true
    var notificationsButtonEnabled = true
}
