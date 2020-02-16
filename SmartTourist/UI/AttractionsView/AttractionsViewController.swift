//
//  AttractionsViewController.swift
//  SmartTourist
//
//  Created on 23/11/2019.
//

import Foundation
import CoreLocation
import Tempura
import GoogleMaps


class AttractionsViewController: ViewControllerWithLocalState<MapView> {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = self.navigationController {
            navigationController.setNavigationBarHidden(true, animated: animated)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navigationController = self.navigationController {
            navigationController.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationManager.shared.setDelegate(self)
        if !LocationManager.shared.locationEnabled || !NotificationManager.shared.notificationsEnabled {
            self.dispatch(Show(Screen.welcome, animated: true))
            LocationManager.shared.stopUpdatingLocation()
        } else {
            LocationManager.shared.startUpdatingLocation()
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
        self.rootView.listCardView.didTapItem = { [unowned self] id in
            self.dispatch(Show(Screen.detail, animated: true, context: id))
        }
        
        self.rootView.listCardView.didChangeSegmentedValue = { [unowned self] index in
            self.localState.selectedSegmentIndex = index
        }
        
        self.rootView.didTapLocationName = { 
            self.dispatch(Show(Screen.cityDetail, animated: true, context: nil))
        }
    }
}


extension AttractionsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("[didUpdateLocations]: \(locations)")
        if let location = locations.first {
            self.dispatch(SetCurrentLocation(location: location.coordinate))
            self.dispatch(GetCurrentCity())
            self.dispatch(GetNearestPlaces(location: location.coordinate))
            //self.dispatch(GetPopularPlaces())
            locationBasedNotification(lastCoordinates: location.coordinate)
        }
    }
    
    func locationBasedNotification(lastCoordinates: CLLocationCoordinate2D){
        let current = CLLocation(latitude: lastCoordinates.latitude, longitude: lastCoordinates.longitude)
        self.state.locationState.popularPlaces.forEach{place in
            let target = CLLocation(latitude: place.location.latitude, longitude: place.location.longitude)
            let distance = Int(current.distance(from: target).rounded())
            if distance < notificationTriggeringDistance {
                NotificationManager.shared.scheduleNotification(body: "You are near a top location: \(place.name)")
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
                let vc = WelcomeViewController(store: self.store, localState: WelcomeLocalState())
                vc.modalPresentationStyle = .overCurrentContext
                return vc
            }),
            .show(Screen.detail): .push({ [unowned self] context in
                return AttractionDetailViewController(store: self.store, localState: AttractionDetailLocalState(attraction: context as! GPPlace))
            }),
            .show(Screen.cityDetail): .push({ [unowned self] context in
                return CityDetailViewController(store: self.store, localState: CityDetailLocalState())
            })
        ]
    }
}


struct AttractionsLocalState: LocalState {
    var cardState: CardState = .collapsed
    var animate: Bool = false
    var mapCentered: Bool = true
    var selectedSegmentIndex: Int = 0
}


enum CardState: Int {
    case expanded = 30
    case collapsed = 70
}
