//
//  PlacesTestView.swift
//  SmartTourist
//
//  Created on 23/11/2019.
//

import UIKit
import Tempura
import PinLayout
import GoogleMaps
import GooglePlaces


struct AttractionsViewModel: ViewModelWithState {
    let currentPlace: GMSPlace?
    let currentLocation: CLLocationCoordinate2D?
    let loading: Bool
    
    init(state: AppState) {
        self.currentPlace = state.locationState.currentPlace
        self.currentLocation = state.locationState.currentLocation
        self.loading = state.loading
    }
}


class AttractionsView: UIView, ViewControllerModellableView {
    var label = UILabel()
    var button = UIButton(type: .system)
    var activityIndicator = UIActivityIndicatorView(style: .large)
    var mapView: GMSMapView!
    
    var didTapButton: Interaction?
    
    func setup() {
        self.button.on(.touchUpInside) { sender in
            self.didTapButton?()
        }
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
        self.addSubview(self.label)
        self.addSubview(self.button)
        self.addSubview(self.activityIndicator)
        self.addSubview(self.mapView)
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.label.font = UIFont.systemFont(ofSize: 24)
        self.button.setTitle(" Locate me", for: .normal)
        self.button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        self.button.setImage(UIImage(systemName: "location.fill"), for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.sizeToFit()
        self.button.sizeToFit()
        self.activityIndicator.sizeToFit()
        self.mapView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height * 0.65)
        self.label.pin.bottom(25%).hCenter()
        self.button.pin.bottom(15%).hCenter()
        self.activityIndicator.pin.bottom(25%).hCenter()
    }
    
    func update(oldModel: AttractionsViewModel?) {
        if let model = self.model {
            if let currentPlace = model.currentPlace, let placeName = currentPlace.name {
                self.label.text = placeName
            }
            if let location = model.currentLocation {
                self.mapView.isMyLocationEnabled = true
                let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 17)
                self.mapView.animate(to: camera)
            }
            if model.loading {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
            self.setNeedsLayout()
        }
    }
}
