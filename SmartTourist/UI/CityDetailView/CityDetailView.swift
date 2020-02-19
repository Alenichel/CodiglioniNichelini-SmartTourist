//
//  CityDetailView.swift
//  SmartTourist
//
//  Created on 16/02/2020
//

import UIKit
import Katana
import Tempura
import PinLayout
import Cosmos
import CoreLocation
import GoogleMaps


struct CityDetailViewModel: ViewModelWithState {
    let currentCity: String
    let selectedCity: String
    let geo: CLLocationCoordinate2D
    
    init(state: AppState) {
        self.currentCity = state.locationState.currentCity ?? "Diagon Alley"
        self.selectedCity = state.locationState.selectedCity ?? "Atlantide"
        self.geo = state.locationState.actualLocation!
    }
}


class CityDetailView: UIView, ViewControllerModellableView {
    var placeHolderText = UILabel()
    var mapView = GMSMapView()
    
    func setup() {
        self.addSubview(mapView)
        self.addSubview(self.placeHolderText)
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.placeHolderText.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        self.placeHolderText.textAlignment = .center
        self.placeHolderText.layer.cornerRadius = 20
        self.placeHolderText.layer.shadowColor = UIColor.black.cgColor
        self.placeHolderText.layer.shadowOpacity = UITraitCollection.current.userInterfaceStyle == .dark ? 1 : 0.75
        self.placeHolderText.layer.shadowOffset = .zero
        self.placeHolderText.layer.shadowRadius = 1
        self.mapView.settings.compassButton = false
        self.mapView.isUserInteractionEnabled = false
        self.mapView.loadCustomStyle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.placeHolderText.sizeToFit()
        self.placeHolderText.pin.topCenter().size(200)
        self.mapView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 300)
        self.mapView.pin.horizontally(20).topCenter().marginTop(150)
    }
    
    func update(oldModel: CityDetailViewModel?){
        guard let model = self.model else { return }
        self.placeHolderText.text = model.selectedCity
        let marker = GMSMarker(position: model.geo)
        marker.map = self.mapView
    }
}
