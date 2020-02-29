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

var justVisitedPlaces: [GPPlace] = []

class AttractionsViewController: ViewControllerWithLocalState<MapView> {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = self.navigationController {
            navigationController.setNavigationBarHidden(true, animated: animated)
        }
        self.localState.needToMoveMap = true
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
            self.localState.selectedSegmentIndex = SelectedPlaceList(rawValue: index)!
        }
        self.rootView.didTapCityNameButton = { [unowned self] in
            self.dispatch(Show(Screen.cityDetail, animated: true, context: nil))
        }
        self.rootView.didTapLocationButton = { [unowned self] in
            self.dispatch(SetMapCentered(value: true))
            self.dispatch(GetCurrentCity(throttle: false))   // Also calls GetPopularPlaces
            self.dispatch(GetNearestPlaces(location: self.state.locationState.actualLocation, throttle: false))
        }
        self.rootView.ditTapSearchButton = { [unowned self] in
            self.dispatch(Show(Screen.citySearch, animated: true, context: nil))
        }
        self.rootView.didMoveMap = { [unowned self] in
            self.localState.needToMoveMap = false
        }
    }
}


extension AttractionsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("[didUpdateLocations]: \(locations)")
        if self.state.locationState.mapCentered {
            guard let location = locations.first else { return }
            self.dispatch(SetActualLocation(location: location.coordinate))
            self.dispatch(GetCurrentCity(throttle: true))   // Also calls GetPopularPlaces
            self.dispatch(GetNearestPlaces(location: location.coordinate, throttle: true))
            self.locationBasedNotification(lastCoordinates: location.coordinate)
        }
    }
    
    func locationBasedNotification(lastCoordinates: CLLocationCoordinate2D){
        let current = CLLocation(latitude: lastCoordinates.latitude, longitude: lastCoordinates.longitude)
        self.state.locationState.popularPlaces.forEach { place in
            if !justVisitedPlaces.contains(place) {
                let target = CLLocation(latitude: place.location.latitude, longitude: place.location.longitude)
                let distance = Int(current.distance(from: target).rounded())
                if distance < notificationTriggeringDistance {
                    NotificationManager.shared.scheduleNotification(body: "You are near a top location: \(place.name)")
                    justVisitedPlaces.append(place)
                }
            }
        }
    }
}


extension AttractionsViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture { self.dispatch(SetMapCentered(value: false)) }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.dispatch(SetMapLocation(location: position.target))
        if !self.state.locationState.mapCentered {
            self.dispatch(GetCurrentCity(throttle: false))   // Also calls GetPopularPlaces
            self.dispatch(GetNearestPlaces(location: position.target, throttle: false))
        }
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.dispatch(SetMapLocation(location: position.target))
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        self.dispatch(SetMapCentered(value: false))
        return false
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
            .show(Screen.citySearch): .presentModally({ [unowned self] context in
                let vc = CitySearchViewController(store: self.store)
                vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
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
    var selectedSegmentIndex: SelectedPlaceList = .nearest
    var needToMoveMap: Bool = false
}


enum CardState: Int {
    case expanded = 30
    case collapsed = 70
}
