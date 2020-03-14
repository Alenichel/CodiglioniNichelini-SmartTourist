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
    let city: String

    init(state: AppState) {
        self.city = state.locationState.currentCity!
    }
}


class WorldwideFavoritesView: UIView, ViewControllerModellableView {
    var mapView = GMSMapView(frame: .zero)
    
    func setup() {
        self.mapView.settings.compassButton = true
        self.mapView.settings.tiltGestures = false
        self.addSubview(self.mapView)
    }
    
     func style() {
           
       }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.mapView.pin.all()
    }
    
    func update(oldModel: WorldwideFavoritesViewModel?){
        guard let model = self.model else { return }
    }
}
