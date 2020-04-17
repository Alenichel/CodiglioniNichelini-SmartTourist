//
//  WelcomeViewController.swift
//  SmartTourist
//
//  Created on 25/11/2019
//

import UIKit
import CoreLocation
import Tempura


class WelcomeViewController: ViewControllerWithLocalState<WelcomeView> {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LocationManager.shared.setDelegate(self)
        NotificationManager.shared.onPermissionGranted = { [unowned self] in
            self.localState.notificationsButtonEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationManager.shared.onPermissionGranted = nil
    }
    
    override func setupInteraction() {
        self.rootView.didTapLocation = {
            LocationManager.shared.requestAuth()
            self.localState.locationButtonEnabled = !LocationManager.shared.locationEnabled
        }
        self.rootView.didTapNotifications = {
            NotificationManager.shared.requestAuth()
        }
        self.rootView.didTapClose = { [unowned self] in
            self.dispatch(Hide(animated: true))
            guard let navigationController = self.presentingViewController as? UINavigationController else { return }
            guard let attractionsController = navigationController.viewControllers.first as? AttractionsViewController else { return }
            LocationManager.shared.setDelegate(attractionsController)
            LocationManager.shared.startUpdatingLocation()
        }
    }
}


extension WelcomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.localState.locationButtonEnabled = !LocationManager.shared.locationEnabled
    }
}


extension WelcomeViewController: RoutableWithConfiguration {
    var routeIdentifier: RouteElementIdentifier {
        Screen.welcome.rawValue
    }
    
    var navigationConfiguration: [NavigationRequest : NavigationInstruction] {
        [
            .hide(Screen.welcome): .dismissModally(behaviour: .hard),
        ]
    }
}


struct WelcomeLocalState: LocalState {
    var locationButtonEnabled = !LocationManager.shared.locationEnabled
    var notificationsButtonEnabled = !NotificationManager.shared.notificationsEnabled
}
