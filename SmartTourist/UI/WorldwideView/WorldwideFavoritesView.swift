//
//  WorldwideFavoritesView.swift
//  SmartTourist
//
//  Created on 14/03/2020
//

import UIKit
import Tempura
import PinLayout
import GoogleMaps


struct WorldwideFavoritesViewModel: ViewModelWithState {
    let favorites: [GPPlace]

    init(state: AppState) {
        self.favorites = state.favorites
    }
}


class WorldwideFavoritesView: UIView, ViewControllerModellableView {
    var mapView = GMSMapView(frame: .zero)
    var closeButton = UIButton(type: .custom)
    var markerPool : GMSMarkerPool!
    
    var didTapCloseButton: (()->())?
    
    func setup() {
        self.markerPool = GMSMarkerPool(mapView: self.mapView)
        self.mapView.settings.compassButton = true
        self.mapView.settings.tiltGestures = false
        self.closeButton.tintColor = .secondaryLabel
        self.closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        self.closeButton.on(.touchUpInside){ button in
            self.didTapCloseButton?()
        }
        self.addSubview(self.mapView)
        self.addSubview(self.closeButton)
    }
    
    func style() {
        self.mapView.loadCustomStyle()
        self.backgroundColor = .systemBackground
        self.closeButton.contentVerticalAlignment = .fill
        self.closeButton.contentHorizontalAlignment = .fill
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.mapView.pin.top(50).right().left().bottom()
        self.closeButton.pin.topRight(12.5).size(25)
    }
    
    func update(oldModel: WorldwideFavoritesViewModel?){
        guard let model = self.model else { return }
        self.markerPool.setMarkers(places: model.favorites)
        self.mapView.adaptToPlaces(model.favorites)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.mapView.loadCustomStyle()
    }
}
