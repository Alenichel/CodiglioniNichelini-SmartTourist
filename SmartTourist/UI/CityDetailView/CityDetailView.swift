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
        self.geo = state.locationState.selectedLocation ?? state.locationState.actualLocation!
    }
}


class CityDetailView: UIView, ViewControllerModellableView {
    let icon = UIImage(systemName: "magnifyingglass")
    
    var cityNameLabel = UILabel()
    var mapView = GMSMapView()
    var descriptionText = UITextView()
    var changeCityButton = UIBarButtonItem()
    var containerView = UIView()
    var lineView = UIView()
    
    var didTapChangeCityButton: (() -> Void )?
    
    func setup() {
        self.addSubview(mapView)
        self.addSubview(self.cityNameLabel)
        self.addSubview(descriptionText)
        
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.lineView)
        
        self.changeCityButton.image = self.icon
        self.changeCityButton.style = .plain
        self.navigationItem?.rightBarButtonItem = self.changeCityButton
        self.changeCityButton.onTap { button in
            self.didTapChangeCityButton?()
        }
        
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.cityNameLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        self.cityNameLabel.textAlignment = .center
        self.cityNameLabel.layer.cornerRadius = 20
        self.mapView.settings.compassButton = false
        self.mapView.isUserInteractionEnabled = false
        self.mapView.loadCustomStyle()
        self.descriptionText.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.15)
        self.descriptionText.isEditable = false
        self.descriptionText.textAlignment = NSTextAlignment.justified
        self.lineView.backgroundColor = .secondaryLabel
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.mapView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 250)
        self.mapView.pin.horizontally(5).topCenter().marginTop(150)
        self.descriptionText.pin.horizontally(8).below(of: self.mapView).marginTop(5).bottom()
        
        self.containerView.pin.horizontally().top(115).above(of: self.mapView)
        self.lineView.pin.top().height(1).horizontally(7)
        
        self.cityNameLabel.sizeToFit()
        self.cityNameLabel.pin.top(self.safeAreaInsets).above(of: containerView).horizontally()
    }
    
    func update(oldModel: CityDetailViewModel?){
        guard let model = self.model else { return }
        let camera = GMSCameraPosition.camera(withTarget: model.geo, zoom: 4)
        self.mapView.camera = camera
        self.descriptionText.setText(searchTerms: model.selectedCity) {
            self.setNeedsLayout()
        }
        self.cityNameLabel.text = model.selectedCity
        let marker = GMSMarker(position: model.geo)
        marker.map = self.mapView
    }
}
