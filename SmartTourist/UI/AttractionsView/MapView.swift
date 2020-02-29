//
//  MapView.swift
//  SmartTourist
//
//  Created on 23/11/2019.
//

import UIKit
import Tempura
import PinLayout
import GoogleMaps


struct AttractionsViewModel: ViewModelWithLocalState {
    let places: [GPPlace]
    let location: CLLocationCoordinate2D?
    let city: String?
    let cardState: CardState
    let cardPercent: Percent
    let animateCard: Bool
    let mapCentered: Bool
    let favorites: [GPPlace]
    let needToMoveMap: Bool
    
    init?(state: AppState?, localState: AttractionsLocalState) {
        guard let state = state else { return nil }
        switch localState.selectedSegmentIndex {
        case .nearest:
            self.places = state.locationState.nearestPlaces
        case .popular:
            self.places = state.locationState.popularPlaces
        case .favorites:
            self.places = state.favorites
        }
        self.location = state.locationState.currentLocation
        self.city = state.locationState.currentCity
        self.cardState = localState.cardState
        self.cardPercent = localState.cardState.rawValue%
        self.animateCard = localState.animate
        self.mapCentered = state.locationState.mapCentered
        self.favorites = state.favorites
        self.needToMoveMap = localState.needToMoveMap
    }
}


class MapView: UIView, ViewControllerModellableView {
    // MARK: Subviews
    var cityNameButton = UIButton()
    var mapView: GMSMapView!
    var locationButton = RoundedButton()
    var littleCircle = GMSCircle()
    var bigCircle = GMSCircle()
    var locationMarker = GMSCircle()
    var topBlurEffect = UIVisualEffectView(effect: UIBlurEffect(style: UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light))
    var listCardView = ListCardView()
    var markerPool: GMSMarkerPool!
    var searchButton = RoundedButton()
    
    // MARK: - Interactions
    var didTapLocationName: Interaction?
    var didTapLocationButton: Interaction?
    var ditTapSearchButton: Interaction?
    var didMoveMap: Interaction?
    
    // MARK: Setup
    func setup() {
        self.mapView = GMSMapView(frame: .zero)
        self.loadMapStyle()
        self.mapView.settings.compassButton = true
        self.mapView.settings.tiltGestures = false
        self.mapView.delegate = self.viewController as? AttractionsViewController
        self.locationButton.tintColor = .label
        self.locationButton.on(.touchUpInside) { button in
            self.didTapLocationButton?()
            self.centerMap()
        }
        self.searchButton.tintColor = .label
        self.searchButton.on(.touchUpInside) { button in
            self.ditTapSearchButton?()
        }
        
        self.cityNameButton.on(.touchUpInside) { button in
            self.didTapLocationName?()
        }
        self.markerPool = GMSMarkerPool(mapView: self.mapView)
        self.addSubview(self.mapView)
        self.addSubview(self.locationButton)
        self.addSubview(self.topBlurEffect)
        self.addSubview(self.listCardView)
        self.addSubview(self.cityNameButton)
        self.addSubview(self.searchButton)
        self.listCardView.setup()
        self.listCardView.style()
    }
    
    // MARK: Style
    func style() {
        self.backgroundColor = .systemBackground
        self.cityNameButton.setTitleColor(.label, for: .normal)
        self.cityNameButton.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        self.cityNameButton.contentHorizontalAlignment = .left
        self.locationButton.backgroundColor = .systemBackground
        self.locationButton.layer.cornerRadius = 20
        self.locationButton.layer.shadowColor = UIColor.black.cgColor
        self.locationButton.layer.shadowOpacity = UITraitCollection.current.userInterfaceStyle == .dark ? 1 : 0.75
        self.locationButton.layer.shadowOffset = .zero
        self.locationButton.layer.shadowRadius = 4
        self.searchButton.backgroundColor = .systemBackground
        self.searchButton.layer.cornerRadius = 20
        self.searchButton.layer.shadowColor = UIColor.black.cgColor
        self.searchButton.layer.shadowOpacity = UITraitCollection.current.userInterfaceStyle == .dark ? 1 : 0.75
        self.searchButton.layer.shadowOffset = .zero
        self.searchButton.layer.shadowRadius = 4
        self.searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
    }
    
    // MARK: Layout subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        self.cityNameButton.sizeToFit()
        self.mapView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height * 0.70)
        self.topBlurEffect.pin.top().left().right().bottom(94.5%)
        self.cityNameButton.pin.below(of: self.topBlurEffect).left(10)
        self.searchButton.pin.right(of: self.cityNameButton, aligned: .center).margin(2%).size(40)
        self.layoutCardView()
    }
    
    func layoutCardView() {
        guard let model = self.model else { return }
        self.listCardView.pin.bottom().left().right().top(model.cardPercent)
        self.mapView.frame.size.height = model.cardPercent.of(self.frame.height)
        let inversePercent = (100 - model.cardPercent.of(100) + 2)%
        self.locationButton.pin.bottom(inversePercent).right(4%).size(40)
        self.layoutIfNeeded()
    }
    
    // MARK: Update
    func update(oldModel: AttractionsViewModel?) {
        guard let model = self.model else { return }
        if self.mapView.camera.zoom >= 9 {
            self.markerPool.setMarkers(places: model.places)
            self.cityNameButton.isHidden = false
        } else {
            self.markerPool.setMarkers(places: [])
            self.cityNameButton.isHidden = true
        }
        let listCardViewModel = ListCardViewModel(currentLocation: model.location, places: model.places, cardState: model.cardState, favorites: model.favorites)
        self.listCardView.model = listCardViewModel
        self.locationButton.setImage(UIImage(systemName: model.mapCentered ? "location.fill" : "location"), for: .normal)
        if let location = model.location {
            self.mapView.isMyLocationEnabled = true
            self.locationMarker.position = location
            self.locationMarker.radius = 819200.0 * pow(2, -Double(self.mapView.camera.zoom))
            self.locationMarker.map = self.mapView
            if model.mapCentered {
                self.locationMarker.strokeColor = .clear
                self.locationMarker.fillColor = .clear
                self.centerMap()
            } else {
                self.locationMarker.strokeColor = .label
                self.locationMarker.fillColor = .label
            }
            self.littleCircle.position = location
            self.littleCircle.radius = littleCircleRadius
            self.bigCircle.position = location
            self.bigCircle.radius = bigCircleRadius
            self.littleCircle.strokeColor = .label
            self.bigCircle.strokeColor = .label
            self.littleCircle.map = self.mapView
            self.bigCircle.map = self.mapView
            if model.needToMoveMap {
                self.moveMap(to: location)
                self.didMoveMap?()
            }
        }
        if let city = model.city {
            self.cityNameButton.setTitle(city, for: .normal)
        }
        if model.animateCard {
            UIView.animate(withDuration: 0.5) {
                self.layoutCardView()
            }
        } else {
            self.setNeedsLayout()
        }
    }
    
    private func moveMap(to location: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 17)
        self.mapView.animate(to: camera)
    }
    
    private func centerMap() {
        guard let model = self.model, let location = model.location else { return }
        self.moveMap(to: location)
    }
    
    private func loadMapStyle() {
        do {
            let style = UITraitCollection.current.userInterfaceStyle == .dark ? "mapStyle.dark" : "mapStyle"
            if let styleURL = Bundle.main.url(forResource: style, withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                print("Unable to find style.json")
            }
        } catch {
            print("One or more of the map styles failed to load. \(error)")
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.loadMapStyle()
        self.topBlurEffect.effect = UIBlurEffect(style: UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light)
    }
}
