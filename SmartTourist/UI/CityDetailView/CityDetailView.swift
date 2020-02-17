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


struct CityDetailViewModel: ViewModelWithLocalState {
    let currentCity: String
    
    init?(state: AppState?, localState: CityDetailLocalState){
        guard let state = state else {  return nil }
        self.currentCity = state.locationState.currentCity ?? "Atlantide"
    }
}

class CityDetailView: UIView, ViewControllerModellableView {
    var placeHolderText = UILabel()
    
    func setup() {
        self.addSubview(self.placeHolderText)
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.placeHolderText.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 4)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.placeHolderText.sizeToFit()
        self.placeHolderText.pin.topCenter().size(200)
    }
    
    func update(oldModel: CityDetailViewModel?){
        guard let model = self.model else { return }
        self.placeHolderText.text = model.currentCity
    }
    
}
