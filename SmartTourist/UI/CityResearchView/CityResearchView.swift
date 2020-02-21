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
    var searchBar = UISearchBar()
    
    func setup() {
        self.navigationItem?.leftBarButtonItem?.title = ""
        self.navigationItem!.titleView = searchBar
        self.addSubview(searchBar)
    }
    
    func style(){
        self.backgroundColor = .systemBackground
        searchBar.sizeToFit()
    }
    
    override func layoutSubviews() {
        
    }
    
    func update(oldModel: CityDetailViewModel?) {
        guard let model = self.model else { return }
        
        self.setNeedsLayout()
    }
    
}
