//
//  AttractionsViewController.swift
//  SmartTourist
//
//  Created on 23/11/2019.
//

import Foundation
import CoreLocation
import Tempura
import GooglePlaces


class AttractionsViewController: ViewController<AttractionsView>, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationManager.shared.setDelegate(self)
        LocationManager.shared.requestAuth()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("--> didUpdateLocations: \(locations)")
        if let location = locations.first {
            self.dispatch(SetCurrentLocation(location: location.coordinate))
            self.dispatch(GetCurrentPlace())
        }
    }
    
    override func setupInteraction() {
        self.rootView.didTapButton = { [unowned self] in
            self.dispatch(GetCurrentPlace())
        }
    }
}


extension AttractionsViewController: RoutableWithConfiguration {
    var routeIdentifier: RouteElementIdentifier {
        Screen.attractions.rawValue
    }
    
    var navigationConfiguration: [NavigationRequest : NavigationInstruction] {
        [
            .show(Screen.welcome): .presentModally({ [unowned self] context in
                let welcomeViewController = WelcomeViewController(store: self.store, localState: WelcomeLocalState())
                welcomeViewController.modalPresentationStyle = .overCurrentContext
                return welcomeViewController
            })
        ]
    }
}
