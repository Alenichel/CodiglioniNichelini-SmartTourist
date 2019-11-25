//
//  PlacesTestView.swift
//  SmartTourist
//
//  Created on 23/11/2019.
//

import UIKit
import Tempura
import PinLayout


struct PlacesTestViewModel: ViewModelWithState {
    let location: String
    let loading: Bool
    
    init(state: AppState) {
        self.location = state.currentPlace ?? ""
        self.loading = state.loading
    }
}


class PlacesTestView: UIView, ViewControllerModellableView {
    var label = UILabel()
    var button = UIButton(type: .system)
    var activityIndicator = UIActivityIndicatorView(style: .large)
    
    var didTapButton: Interaction?
    
    func setup() {
        self.button.on(.touchUpInside) { sender in
            self.didTapButton?()
        }
        self.addSubview(self.label)
        self.addSubview(self.button)
        self.addSubview(self.activityIndicator)
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.label.font = UIFont.systemFont(ofSize: 24)
        self.button.setTitle(" Locate me", for: .normal)
        self.button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        self.button.setImage(UIImage(systemName: "location.fill"), for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.sizeToFit()
        self.button.sizeToFit()
        self.activityIndicator.sizeToFit()
        self.label.pin.center()
        self.button.pin.below(of: self.label, aligned: .center).marginTop(50)
        //self.activityIndicator.pin.above(of: self.label, aligned: .center).marginBottom(100)
        self.activityIndicator.pin.center()
    }
    
    func update(oldModel: PlacesTestViewModel?) {
        if let model = self.model {
            self.label.text = model.location
            if model.loading {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
            self.setNeedsLayout()
        }
    }
}
