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
            LocationManager.shared.requestAuth()
            self.localState.locationButtonEnabled = !LocationManager.shared.locationEnabled
        }
        self.rootView.didTapNotifications = {
            NotificationManager.shared.requestAuth()
            self.localState.notificationsButtonEnabled = !NotificationManager.shared.notificationsEnabled
        }
        self.rootView.didTapClose = { [unowned self] in
            self.dispatch(Hide(animated: true))
            LocationManager.shared.startUpdatingLocation()
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
    var locationButtonEnabled = true//!LocationManager.shared.locationEnabled
    var notificationsButtonEnabled = true//!NotificationManager.shared.notificationsEnabled
}
