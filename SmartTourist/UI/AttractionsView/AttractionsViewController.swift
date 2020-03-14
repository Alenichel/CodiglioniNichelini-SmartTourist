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
        self.rootView.listCardView.didTapItem = { [unowned self] id in
            self.dispatch(Show(Screen.detail, animated: true, context: id))
        }
        self.rootView.listCardView.didChangeSegmentedValue = { [unowned self] index in
            self.localState.selectedSegmentIndex = SelectedPlaceList(rawValue: index)!
        }
        self.rootView.didTapCityNameButton = { [unowned self] in
            self.dispatch(Show(Screen.cityDetail, animated: true))
        }
        self.rootView.didTapLocationButton = { [unowned self] in
            self.dispatch(SetMapCentered(value: true))
            self.dispatch(GetCurrentCity(throttle: false))   // Also calls GetPopularPlaces
            self.dispatch(GetNearestPlaces(location: self.state.locationState.actualLocation, throttle: false))
        }
        self.rootView.ditTapSearchButton = { [unowned self] in
            self.dispatch(Show(Screen.citySearch, animated: true))
        }
        self.rootView.didMoveMap = { [unowned self] in
            self.dispatch(SetNeedToMoveMap(value: false))
        }
        self.rootView.listCardView.didTapMapButton = { [unowned self] in
            self.dispatch(Show(Screen.worldwideFavorites, animated: true))
        }
    }
}


extension AttractionsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        print("[didUpdateLocations]: \(location)")
        self.dispatch(SetActualLocation(location: location.coordinate))
        self.locationBasedNotification(lastCoordinates: location.coordinate)
        if self.state.locationState.mapCentered {
            self.dispatch(GetCurrentCity(throttle: true))   // Also calls GetPopularPlaces
            self.dispatch(GetNearestPlaces(location: location.coordinate, throttle: true))
        }
    }
    
    func locationBasedNotification(lastCoordinates: CLLocationCoordinate2D) {
        guard self.state.settings.notificationsEnabled else { return }
        let current = CLLocation(latitude: lastCoordinates.latitude, longitude: lastCoordinates.longitude)
        self.state.locationState.popularPlaces.forEach { place in
            if !justVisitedPlaces.contains(place) {
                let target = CLLocation(latitude: place.location.latitude, longitude: place.location.longitude)
                let distance = Int(current.distance(from: target).rounded())
                if distance < notificationTriggeringDistance {
                    NotificationManager.shared.sendNearbyTopAttractionNotification(place: place)
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
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let place = marker.userData as! GPPlace
        self.dispatch(Show(Screen.detail, animated: true, context: place))
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
                vc.modalPresentationStyle = .pageSheet
                return vc
            }),
            .show(Screen.citySearch): .presentModally({ [unowned self] context in
                let vc = CitySearchViewController(store: self.store)
                vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                return vc
            }),
            .show(Screen.detail): .push({ [unowned self] context in
                return AttractionDetailViewController(store: self.store, localState: AttractionDetailLocalState(attraction: context as! GPPlace))
            }),
            .show(Screen.cityDetail): .push({ [unowned self] context in
                return CityDetailViewController(store: self.store)
            }),
            .show(Screen.worldwideFavorites): .presentModally({[unowned self] context in
                return WorldwideFavoritesViewController(store: self.store)
            })
        ]
    }
}


struct AttractionsLocalState: LocalState {
    var selectedSegmentIndex: SelectedPlaceList = .nearest
}
