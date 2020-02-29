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
    //var resultView: UITextView?
    var subView = UIView(frame: CGRect(x: 0, y: 45, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    var transitionBlurEffect = UIVisualEffectView(effect: UIBlurEffect(style: UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light))
    
    func setup() {
        self.navigationItem?.leftBarButtonItem?.title = ""
        self.addSubview(self.transitionBlurEffect)
    }
    
    func style(){
        //self.backgroundColor = .systemBackground
        //self.alpha = 0.90
        self.backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        self.transitionBlurEffect.pin.top().left().right().bottom(90%)
    }
    
    func update(oldModel: CitySearchViewModel?) {
        guard let _ = self.model else { return }
        self.setNeedsLayout()
    }
}
