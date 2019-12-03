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
import GooglePlaces


struct AttractionsViewModel: ViewModelWithLocalState {
    let nearestPlaces: [GMSPlace]
    let currentLocation: CLLocationCoordinate2D?
    let currentCity: String?
    let cardPercent: Percent
    let animateCard: Bool
    let mapCentered: Bool
    
    init(state: AppState?, localState: AttractionsLocalState) {
        if let state = state {
            self.nearestPlaces = state.locationState.nearestPlaces
            self.currentLocation = state.locationState.currentLocation
            self.currentCity = state.locationState.currentCity
        } else {
            self.nearestPlaces = []
            self.currentLocation = nil
            self.currentCity = nil
        }
        self.cardPercent = localState.cardState.rawValue%
        self.animateCard = localState.animate
        self.mapCentered = localState.mapCentered
    }
}


class MapView: UIView, ViewControllerModellableView {
    // MARK: Subviews
    var cityNameLabel = UILabel()
    var mapView: GMSMapView!
    var locationButton = RoundedButton()
    var lastLittleCircle: GMSCircle?
    var lastBigCircle: GMSCircle?
    var topBlurEffect = UIVisualEffectView(effect: UIBlurEffect(style: UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light))
    var listCardView = ListCardView()
    
    // MARK: Setup
    func setup() {
        self.mapView = GMSMapView(frame: .zero)
        self.loadMapStyle()
        self.mapView.settings.compassButton = true
        self.mapView.settings.tiltGestures = false
        self.mapView.delegate = self.viewController as? AttractionsViewController
        self.locationButton.tintColor = .label
        self.locationButton.on(.touchUpInside) { button in
            self.centerMap()
        }
        self.addSubview(self.mapView)
        self.addSubview(self.locationButton)
        self.addSubview(self.cityNameLabel)
        self.addSubview(self.topBlurEffect)
        self.addSubview(self.listCardView)
        self.listCardView.setup()
        self.listCardView.style()
    }
    
    // MARK: Style
    func style() {
        self.backgroundColor = .systemBackground
        self.cityNameLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        self.locationButton.backgroundColor = .systemBackground
        self.locationButton.layer.cornerRadius = 20
        self.locationButton.layer.shadowColor = UIColor.black.cgColor
        self.locationButton.layer.shadowOpacity = UITraitCollection.current.userInterfaceStyle == .dark ? 1 : 0.75
        self.locationButton.layer.shadowOffset = .zero
        self.locationButton.layer.shadowRadius = 4
    }
    
    // MARK: Layout subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        self.cityNameLabel.sizeToFit()
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
        let listCardViewModel = ListCardViewModel(places: model.nearestPlaces, currentLocation: model.currentLocation)
        self.listCardView.model = listCardViewModel
        self.locationButton.setImage(UIImage(systemName: model.mapCentered ? "location.fill" : "location"), for: .normal)
        if let location = model.currentLocation {
            self.mapView.isMyLocationEnabled = true
            if model.mapCentered {
                self.centerMap()
            }
            if let lastLittleCircle = self.lastLittleCircle {
                lastLittleCircle.map = nil
            }
            if let lastBigCircle = self.lastBigCircle {
                lastBigCircle.map = nil
            }
            let littleCircle = GMSCircle(position: location, radius: 333)
            let bigCircle = GMSCircle(position: location, radius: 1000)
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
            self.cityNameLabel.text = city
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
