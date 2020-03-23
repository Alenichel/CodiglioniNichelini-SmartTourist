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
    var barView = UIView()
    var closeButton = UIButton(type: .system)
    var markerPool : GMSMarkerPool!
    
    var didTapCloseButton: (()->())?
    
    func setup() {
        self.markerPool = GMSMarkerPool(mapView: self.mapView)
        self.mapView.settings.compassButton = true
        self.mapView.settings.tiltGestures = false
        self.closeButton.on(.touchUpInside){ button in
            self.didTapCloseButton?()
        }
        self.addSubview(self.mapView)
        self.addSubview(self.barView)
        self.addSubview(self.closeButton)
    }
    
    func style() {
        self.mapView.loadCustomStyle()
        self.closeButton.setTitle("Close", for: .normal)
        self.closeButton.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 4)
        self.barView.backgroundColor = .systemBackground
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.barView.pin.left().right().height(50)
        self.mapView.pin.below(of: barView).right().left().bottom()
        self.closeButton.pin.topRight(10).sizeToFit()//.marginTop(10).marginRight(10)
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
