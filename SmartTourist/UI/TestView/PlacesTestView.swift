//
//  PlacesTestView.swift
//  SmartTourist
//
//  Created on 23/11/2019.
//

import UIKit
import Tempura
import PinLayout
import GoogleMaps


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
    var mapView: GMSMapView!
    
    var didTapButton: Interaction?
    
    func setup() {
        self.button.on(.touchUpInside) { sender in
            self.didTapButton?()
        }
        print(self.frame)
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        self.mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        self.addSubview(self.label)
        self.addSubview(self.button)
        self.addSubview(self.activityIndicator)
        self.addSubview(self.mapView)
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
        self.mapView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height * 0.65)
        self.label.pin.center()
        self.button.pin.bottom(15%).hCenter()
        self.activityIndicator.pin.center()
        //self.mapView.pin.center()
    }
    
    func update(oldModel: PlacesTestViewModel?) {
        print(self.frame.size)
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
