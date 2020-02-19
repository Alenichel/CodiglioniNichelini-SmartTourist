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
            if self.state.favorites.contains(id) {
                self.dispatch(RemoveFavorite(place: id))
            } else {
                self.dispatch(AddFavorite(place: id))
            }
            self.dispatch(Show(Screen.detail, animated: true, context: id))
        }
        self.rootView.listCardView.didChangeSegmentedValue = { [unowned self] index in
            self.localState.selectedSegmentIndex = index
        }
        self.rootView.didTapLocationName = { [unowned self] in
            self.dispatch(Show(Screen.cityDetail, animated: true, context: nil))
        }
    }
    
    private func updateLocationInfo(_ coordinates: CLLocationCoordinate2D, throttle: Bool) {
        self.dispatch(SetCurrentLocation(location: coordinates))
        self.dispatch(GetCurrentCity(throttle: throttle))
        self.dispatch(GetNearestPlaces(location: coordinates, throttle: throttle))
        //self.dispatch(GetPopularPlaces())     / This gets called by GetCurrentCity
    }
}


extension AttractionsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("[didUpdateLocations]: \(locations)")
        if self.localState.mapCentered {
            guard let location = locations.first else { return }
            self.updateLocationInfo(location.coordinate, throttle: true)
            self.locationBasedNotification(lastCoordinates: location.coordinate)
        }
    }
    
    func locationBasedNotification(lastCoordinates: CLLocationCoordinate2D){
        let current = CLLocation(latitude: lastCoordinates.latitude, longitude: lastCoordinates.longitude)
        self.state.locationState.popularPlaces.forEach { place in
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
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.updateLocationInfo(position.target, throttle: false)
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
                return CityDetailViewController(store: self.store)
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
