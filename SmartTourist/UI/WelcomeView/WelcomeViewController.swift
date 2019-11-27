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
    var locationButtonEnabled: Bool {
        return true     // Should return if the button should be enabled or not
    }
    
    var notificationsButtonEnabled: Bool {
        NotificationManager.shared.notificationsEnabled
    }
}
