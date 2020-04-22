//
//  AttractionsViewController.swift
//  SmartTourist
//
//  Created on 23/11/2019.
//

import Foundation
import Tempura
import MapKit


var justVisitedPlaces: [WDPlace] = []


class AttractionsViewController: ViewControllerWithLocalState<MapView> {
    var mapLoaded = false
    
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
                print("\(#function): \(error.localizedDescription)")
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
            self.rootView.mapView.setUserTrackingMode(.follow, animated: true)
            self.dispatch(GetCurrentCity(throttle: false))   // Also calls GetPopularPlaces
            self.dispatch(GetNearestPlaces(throttle: false))
        }
        self.rootView.ditTapSearchButton = { [unowned self] in
            self.dispatch(Show(Screen.search, animated: true))
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


extension AttractionsViewController: MKMapViewDelegate {
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if !self.mapLoaded {
            mapView.setUserTrackingMode(.follow, animated: true)
            self.mapLoaded = true
        }
    }
    
    // Called at every minimum change of the visible region
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        self.dispatch(SetMapLocation(location: mapView.centerCoordinate))
    }
    
    // Called when the region finishes changing
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.dispatch(SetMapLocation(location: mapView.centerCoordinate))
        if !self.state.locationState.mapCentered {
            self.dispatch(GetCurrentCity(throttle: false))   // Also calls GetPopularPlaces
            self.dispatch(GetNearestPlaces(throttle: false))
        }
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        if mode == .none {
            self.dispatch(SetMapCentered(value: false))
        } else {
            self.dispatch(SetMapCentered(value: true))
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let _ = annotation as? MKUserLocation {
            return nil
        } else if let placemark = annotation as? MKPlacemark {
            let view = MKMarkerAnnotationView(annotation: placemark, reuseIdentifier: "marker")
            view.canShowCallout = true
            let button = UIButton(type: .detailDisclosure)
            button.tintColor = .label
            button.sizeToFit()
            view.rightCalloutAccessoryView = button
            return view
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circle = overlay as? MKCircle {
            let circleView = MKCircleRenderer(circle: circle)
            circleView.strokeColor = .label
            circleView.lineWidth = 1
            return circleView
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print(#function)
        guard let placemark = view.annotation as? MKPlacemark else { return }
        if let title = placemark.title {
            print("didTap \(title)")
        }
        guard let place = self.rootView.markerPool.getPlace(from: placemark) else { return }
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
            .show(Screen.search): .presentModally { [unowned self] context in
                let vc = SearchViewController(store: self.store, localState: SearchViewLocalState())
                vc.modalPresentationStyle = .overCurrentContext
                return vc
            },
            .show(Screen.detail): .push { [unowned self] context in
                AttractionDetailViewController(store: self.store, localState: AttractionDetailLocalState(attraction: context as! WDPlace))
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
