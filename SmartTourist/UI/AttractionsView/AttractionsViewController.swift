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
import GoogleMaps


class AttractionsViewController: ViewControllerWithLocalState<MapView>, CLLocationManagerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationManager.shared.setDelegate(self)
        if self.state.firstLaunch {
            self.dispatch(SetFirstLaunch())
            self.dispatch(Show(Screen.welcome, animated: true))
            LocationManager.shared.stopUpdatingLocation()
        } else {
            LocationManager.shared.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("[didUpdateLocations]: \(locations)")
        if let location = locations.first {
            self.dispatch(SetCurrentLocation(location: location.coordinate))
            self.dispatch(GetCurrentPlace())
            self.dispatch(GetCurrentCity())
        }
    }
    
    override func setupInteraction() {
        self.rootView.listCardView.animate = { [unowned self] in
            self.localState.animate = true
            switch self.localState.cardState {
            case .expanded:
                self.localState.cardState = .collapsed
            case .collapsed:
                self.localState.cardState = .expanded
            }
        }
    }
}


extension AttractionsViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        self.localState.mapCentered = !gesture      // If the user moved the map (gesture = true), than the map is not centered anymore
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


struct AttractionsLocalState: LocalState {
    enum CardState: Int {
        case expanded = 30
        case collapsed = 70
    }
    
    var cardState: CardState = .collapsed
    var animate: Bool = false
    var mapCentered: Bool = true
}
