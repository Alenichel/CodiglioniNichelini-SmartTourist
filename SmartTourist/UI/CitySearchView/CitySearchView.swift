//
//  CitySearchView.swift
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


struct CitySearchViewModel: ViewModelWithState {
    init(state: AppState) {}
}


class CitySearchView: UIView, ViewControllerModellableView {
    var resultView: UITextView?
    var subView = UIView(frame: CGRect(x: 0, y: 65.0, width: 350.0, height: 45.0))
    
    func setup() {
        self.navigationItem?.leftBarButtonItem?.title = ""
    }
    
    func style(){
        self.backgroundColor = .systemBackground
        self.alpha = 0.90
    }
    
    override func layoutSubviews() {
        //self.subView.pin.all()
    }
    
    func update(oldModel: CitySearchViewModel?) {
        guard let _ = self.model else { return }
        self.setNeedsLayout()
    }
}
