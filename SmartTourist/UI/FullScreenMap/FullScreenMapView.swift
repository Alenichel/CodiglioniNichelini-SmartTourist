//
//  FullScreenMapView.swift
//  SmartTourist
//
//  Created on 02/08/2020
//

import UIKit
import Tempura
import PinLayout
import MapKit


struct FullScreenMapViewModel: ViewModelWithLocalState {
    let attractions: [WDPlace]

    init?(state: AppState?, localState: FullScreenMapLocalState) {
        self.attractions = localState.attractions
    }
}


class FullScreenMapView: UIView, ViewControllerModellableView {
    var mapView = MKMapView(frame: .zero)
    var closeButton = UIButton(type: .custom)
    var markerPool : MarkerPool!
    
    var didTapCloseButton: (()->())?
    
    func setup() {
        self.markerPool = MarkerPool(mapView: self.mapView)
        self.mapView.showsCompass = true
        self.mapView.showsTraffic = false
        self.mapView.pointOfInterestFilter = .init(including: [.publicTransport])
        self.closeButton.tintColor = .secondaryLabel
        self.closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        self.closeButton.on(.touchUpInside){ button in
            self.didTapCloseButton?()
        }
        self.addSubview(self.mapView)
        self.addSubview(self.closeButton)
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.closeButton.contentVerticalAlignment = .fill
        self.closeButton.contentHorizontalAlignment = .fill
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.mapView.pin.top(50).right().left().bottom()
        self.closeButton.pin.topRight(12.5).size(25)
    }
    
    func update(oldModel: FullScreenMapViewModel?){
        guard let model = self.model else { return }
        self.markerPool.setMarkers(places: model.attractions)
        self.mapView.showAnnotations(self.markerPool.markers, animated: true)
    }
}
