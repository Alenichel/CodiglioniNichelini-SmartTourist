//
//  CityResearchView.swift
//  SmartTourist
//
//  Created on 21/02/2020
//

import UIKit
import Katana
import Tempura
import PinLayout
import CoreLocation
import GoogleMaps

struct CityResearchViewModel: ViewModelWithLocalState {

    let selectedCity: String
    
    init?(state: AppState?, localState: CityResearchLocalState) {
        guard let state = state else { return nil }
        self.selectedCity = state.locationState.selectedCity!
    }
}

class CityResearchView: UIView, ViewControllerModellableView {
    var resultView: UITextView?
    var subView = UIView(frame: CGRect(x: 0, y: 65.0, width: 350.0, height: 45.0))
    
    func setup() {
        self.navigationItem?.leftBarButtonItem?.title = ""
    }
    
    func style(){
        self.backgroundColor = .systemBackground
        ////self.subView.backgroundColor = .green
    }
    
    override func layoutSubviews() {
        //self.subView.pin.all()
        
    }
    
    func update(oldModel: CityDetailViewModel?) {
        guard let _ = self.model else { return }
        self.setNeedsLayout()
    }
    
}
