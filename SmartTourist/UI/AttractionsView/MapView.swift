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
    let currentLocation: CLLocationCoordinate2D?
    let currentCity: String?
    let cardState: CardState
    let cardPercent: Percent
    let animateCard: Bool
    let mapCentered: Bool
    let favorites: [GPPlace]
    
    init?(state: AppState?, localState: AttractionsLocalState) {
        guard let state = state else { return nil }
        self.places = localState.selectedSegmentIndex == 0 ? state.locationState.nearestPlaces : state.locationState.popularPlaces
        self.currentLocation = state.locationState.currentLocation
        self.currentCity = state.locationState.currentCity
        self.cardState = localState.cardState
        self.cardPercent = localState.cardState.rawValue%
        self.animateCard = localState.animate
        self.mapCentered = state.locationState.mapCentered
        self.favorites = state.favorites
    }
}


class MapView: UIView, ViewControllerModellableView {
    // MARK: Subviews
    var cityNameLabel = UIButton()
    var mapView: GMSMapView!
    var locationButton = RoundedButton()
    var lastLittleCircle: GMSCircle?
    var lastBigCircle: GMSCircle?
    var locationMarker: GMSMarker!
    var topBlurEffect = UIVisualEffectView(effect: UIBlurEffect(style: UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light))
    var listCardView = ListCardView()
    
    // MARK: - Interactions
    var didTapLocationName: Interaction?
    var didTapLocationButton: Interaction?
    
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
        self.cityNameLabel.frame = CGRect(x: 100, y: 100, width: 100, height: 50)
        self.cityNameLabel.on(.touchUpInside) { button in
            self.didTapLocationName?()
        }
        self.locationMarker = GMSMarker()
        self.locationMarker.map = self.mapView
        self.addSubview(self.mapView)
        self.addSubview(self.locationButton)
        self.addSubview(self.topBlurEffect)
        self.addSubview(self.listCardView)
        self.addSubview(self.cityNameLabel)
        self.listCardView.setup()
        self.listCardView.style()
    }
    
    // MARK: Style
    func style() {
        self.backgroundColor = .systemBackground
        self.cityNameLabel.setTitleColor(UIColor.black, for: .normal)
        self.cityNameLabel.titleLabel!.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        self.cityNameLabel.contentHorizontalAlignment = .left
        self.locationButton.backgroundColor = .systemBackground
        self.locationButton.layer.cornerRadius = 20
        self.locationButton.layer.shadowColor = UIColor.black.cgColor
        self.locationButton.layer.shadowOpacity = UITraitCollection.current.userInterfaceStyle == .dark ? 1 : 0.75
        self.locationButton.layer.shadowOffset = .zero
        self.locationButton.layer.shadowRadius = 4
        self.locationMarker.icon = UIImage(systemName: "smallcircle.fill.circle")
        self.locationMarker.tracksViewChanges = true
        self.locationMarker.opacity = 0
    }
    
    // MARK: Layout subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        //self.cityNameLabel.sizeToFit()
        self.cityNameLabel.pin.topLeft().size(50)
        self.mapView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height * 0.70)
        self.cityNameLabel.pin.top(5.5%).left(2%).right()
        self.topBlurEffect.pin.top().left().right().bottom(94.5%)
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
        let listCardViewModel = ListCardViewModel(currentLocation: model.currentLocation, places: model.places, cardState: model.cardState, favorites: model.favorites)
        self.listCardView.model = listCardViewModel
        self.locationButton.setImage(UIImage(systemName: model.mapCentered ? "location.fill" : "location"), for: .normal)
        if let location = model.currentLocation {
            self.locationMarker.position = location
            self.mapView.isMyLocationEnabled = true
            if model.mapCentered {
                self.locationMarker.opacity = 0
                self.centerMap()
            } else {
                self.locationMarker.opacity = 1
            }
            if let lastLittleCircle = self.lastLittleCircle {
                lastLittleCircle.map = nil
            }
            if let lastBigCircle = self.lastBigCircle {
                lastBigCircle.map = nil
            }
            let littleCircle = GMSCircle(position: location, radius: 200)
            let bigCircle = GMSCircle(position: location, radius: 800)
            if traitCollection.userInterfaceStyle == .dark{
                littleCircle.strokeColor = .white
                bigCircle.strokeColor = .white
            }
            littleCircle.map = self.mapView
            bigCircle.map = self.mapView
            self.lastLittleCircle = littleCircle
            self.lastBigCircle = bigCircle
        }
        if let city = model.currentCity {
            self.cityNameLabel.setTitle(city, for: .normal)
        }
        if model.animateCard {
            UIView.animate(withDuration: 0.5) {
                self.layoutCardView()
            }
        } else {
            self.setNeedsLayout()
        }
    }
    
    private func centerMap() {
        guard let model = self.model, let location = model.currentLocation else { return }
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 17)
        self.mapView.animate(to: camera)
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
