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
        guard let state = state else { return nil }
        self.currentCity = state.locationState.currentCity ?? "No city"
    }
}

class CityDetailView: UIView, ViewControllerModellableView {
    var placeHolderText = UITextView()
    
    func setup() {
        self.addSubview(placeHolderText)
    }
    
    func style() {
        self.placeHolderText.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.15)
        self.placeHolderText.isScrollEnabled = false
        self.placeHolderText.isEditable = false
        self.placeHolderText.textAlignment = NSTextAlignment.justified
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.placeHolderText.pin.all()
    }
    
    func update(oldModel: CityDetailViewModel?){
        
    }
    
}
