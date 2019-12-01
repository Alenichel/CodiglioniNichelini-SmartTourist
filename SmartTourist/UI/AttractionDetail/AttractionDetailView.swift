//
//  AttractionDetailView.swift
//  SmartTourist
//
//  Created on 01/12/2019
//

import UIKit
import Katana
import Tempura
import GooglePlaces


struct AttractionDetailViewModel: ViewModelWithLocalState {
    let attraction: GMSPlace
    
    init(state: AppState?, localState: AttractionDetailLocalState) {
        self.attraction = localState.attraction
    }
}


class AttractionDetailView: UIView, ViewControllerModellableView {
    func setup() {
        
    }
    
    func style() {
        
    }
    
    override func layoutSubviews() {
        
    }
    
    func update(oldModel: AttractionDetailViewModel?) {
        
    }
}
