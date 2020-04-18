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
        PedometerHandler.shared.startUpdates { data, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                self.dispatch(SetPedometerAverageWalkingSpeed(newSpeed: data.averageActivePace as! Double))                
            }
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
            self.dispatch(GetNearestPlaces(throttle: false))
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
        print("[didUpdateLocations]: \(location.coordinate)")
        self.dispatch(SetActualLocation(location: location.coordinate))
        self.locationBasedNotification(lastCoordinates: location.coordinate)
        if self.state.locationState.mapCentered {
            self.dispatch(GetCurrentCity(throttle: true))   // Also calls GetPopularPlaces
            self.dispatch(GetNearestPlaces(throttle: true))
        }
    }
    
    func locationBasedNotification(lastCoordinates: CLLocationCoordinate2D) {
        guard self.state.settings.notificationsEnabled else { return }
        self.state.locationState.popularPlaces.forEach { place in
            if !justVisitedPlaces.contains(place) {
                let distance = lastCoordinates.distance(from: place)
                if distance < NotificationManager.notificationTriggeringDistance {
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
            self.dispatch(GetNearestPlaces(throttle: false))
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
            .show(Screen.welcome): .presentModally { [unowned self] context in
                let vc = WelcomeViewController(store: self.store, localState: WelcomeLocalState())
                vc.modalPresentationStyle = .pageSheet
                return vc
            },
            .show(Screen.citySearch): .presentModally { [unowned self] context in
                let vc = CitySearchViewController(store: self.store)
                vc.modalPresentationStyle = .overCurrentContext
                return vc
            },
            .show(Screen.detail): .push { [unowned self] context in
                AttractionDetailViewController(store: self.store, localState: AttractionDetailLocalState(attraction: context as! GPPlace))
            },
            .show(Screen.cityDetail): .push { [unowned self] context in
                CityDetailViewController(store: self.store, localState: CityDetailLocalState())
            },
            .show(Screen.worldwideFavorites): .presentModally { [unowned self] context in
                let vc = WorldwideFavoritesViewController(store: self.store)
                vc.modalPresentationStyle = .pageSheet
                return vc
            },
        ]
    }
}


struct AttractionsLocalState: LocalState {
    var selectedSegmentIndex: SelectedPlaceList = .nearest
}


enum SelectedPlaceList: Int {
    case nearest = 0
    case popular = 1
    case favorites = 2
}
