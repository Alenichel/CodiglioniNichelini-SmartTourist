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
        if CLLocationManager.locationServicesEnabled() {
            let authorizationStatus = CLLocationManager.authorizationStatus()
            print(authorizationStatus.rawValue)
            if !(authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse) {
                print("Requesting location")
                locationManager.requestAlwaysAuthorization()
            } else {
                print("Location service enabled")
            }
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            print("Starting updating location")
            locationManager.distanceFilter = 250
        } else {
            let alert = UIAlertController(title: "Attention!", message: "Location services not enabled", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
        /*if self.state.firstLaunch {
            self.dispatch(Show(ScreenID.welcome, animated: true))
        }*/
    }
    
    override func setupInteraction() {
        self.rootView.didTapButton = { [unowned self] in
            self.dispatch(GetCurrentPlace())
        }
    }
}


extension AttractionsViewController: RoutableWithConfiguration {
    var routeIdentifier: RouteElementIdentifier {
        ScreenID.attractions.rawValue
    }
    
    var navigationConfiguration: [NavigationRequest : NavigationInstruction] {
        [
            .show(ScreenID.welcome): .presentModally({ [unowned self] context in
                let welcomeViewController = WelcomeViewController(store: self.store, localState: WelcomeLocalState())
                welcomeViewController.modalPresentationStyle = .overCurrentContext
                return welcomeViewController
            })
        ]
    }
}
