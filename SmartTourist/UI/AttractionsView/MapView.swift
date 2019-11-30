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
    }
}


class MapView: UIView, ViewControllerModellableView {
    // MARK: Subviews
    var cityNameLabel = UILabel()
    var mapView: GMSMapView!
    var lastCircle: GMSCircle?
    var topBlurEffect = UIVisualEffectView(effect: UIBlurEffect(style: UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light))
    var listCardView = ListCardView()
    
    // MARK: Interactions
    var didTapButton: Interaction?
    
    // MARK: Setup
    func setup() {
        self.mapView = GMSMapView(frame: .zero)
        do {
            // Set the map style by passing the URL of the local file.
            let style = UITraitCollection.current.userInterfaceStyle == .dark ? "mapStyle.dark" : "mapStyle"
            if let styleURL = Bundle.main.url(forResource: style, withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                print("Unable to find style.json")
            }
        } catch {
            print("One or more of the map styles failed to load. \(error)")
        }
        self.addSubview(self.mapView)
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
        if let model = self.model {
            self.listCardView.pin.bottom().left().right().top(model.cardPercent)
        }
    }
    
    // MARK: Update
    func update(oldModel: AttractionsViewModel?) {
        guard let model = self.model else { return }
        let listCardViewModel = ListCardViewModel(places: model.nearestPlaces)
        self.listCardView.model = listCardViewModel
        if let location = model.currentLocation {
            self.mapView.isMyLocationEnabled = true
            if let lastCircle = self.lastCircle {
                lastCircle.map = nil
            }
            let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 17)
            self.mapView.animate(to: camera)
            let circle = GMSCircle(position: location, radius: 100)
            if traitCollection.userInterfaceStyle == .dark{
                circle.strokeColor = .white
            }
            circle.map = self.mapView
            self.lastCircle = circle
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
}
