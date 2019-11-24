//
//  PlacesTestView.swift
//  SmartTourist
//
//  Created by Fabio Codiglioni on 23/11/2019.
//  Copyright © 2019 Fabio Codiglioni. All rights reserved.
//

import UIKit
import Tempura
import PinLayout


struct PlacesTestViewModel: ViewModelWithState {
    let location: String
    
    init(state: AppState) {
        self.location = state.currentPlace ?? "NO LOCATION"
    }
}


class PlacesTestView: UIView, ViewControllerModellableView {
    var label = UILabel()
    var button = UIButton(type: .system)
    
    var didTapButton: Interaction?
    
    func setup() {
        self.button.on(.touchUpInside) { sender in
            self.didTapButton?()
        }
        self.addSubview(self.label)
        self.addSubview(self.button)
    }
    
    func style() {
        self.backgroundColor = .black
        self.label.textColor = .white
        self.label.font = UIFont.systemFont(ofSize: 24)
        self.button.setTitle(" Locate me", for: .normal)
        self.button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        self.button.setImage(UIImage(systemName: "location.fill"), for: .normal)
    }
    
    func update(oldModel: PlacesTestViewModel?) {
        label.text = self.model?.location
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.sizeToFit()
        self.button.sizeToFit()
        self.label.pin.center()
        self.button.pin.below(of: self.label, aligned: .center).marginTop(50)
    }
}
