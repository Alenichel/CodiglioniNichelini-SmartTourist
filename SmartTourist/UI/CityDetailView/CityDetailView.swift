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
import MapKit


struct CityDetailViewModel: ViewModelWithLocalState {
    let city: String
    let location: CLLocationCoordinate2D
    let allLoaded: Bool
    
    init?(state: AppState?, localState: CityDetailLocalState) {
        guard let state = state else { return nil }
        self.city = state.locationState.currentCity!
        self.location = state.locationState.currentLocation!
        self.allLoaded = localState.allLoaded
    }
}


class CityDetailView: UIView, ViewControllerModellableView {
    var cityNameLabel = UILabel()
    var mapView = MKMapView()
    var descriptionText = UITextView()
    var lineView = UIView()
    
    func setup() {
        self.mapView.showsTraffic = false
        self.mapView.pointOfInterestFilter = .init(including: [.publicTransport])
        self.addSubview(self.mapView)
        self.addSubview(self.cityNameLabel)
        self.addSubview(self.descriptionText)
        self.addSubview(self.lineView)
        self.descriptionText.showsVerticalScrollIndicator = false
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.cityNameLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        self.cityNameLabel.textAlignment = .center
        self.cityNameLabel.layer.cornerRadius = 20
        self.mapView.showsCompass = false
        self.mapView.isUserInteractionEnabled = false
        self.descriptionText.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.15)
        self.descriptionText.isEditable = false
        self.descriptionText.textAlignment = NSTextAlignment.justified
        self.lineView.backgroundColor = .secondaryLabel
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.cityNameLabel.sizeToFit()
        self.cityNameLabel.pin.top(self.safeAreaInsets).horizontally().marginTop(3)
        self.lineView.pin.below(of: self.cityNameLabel).height(1).horizontally(7)
        self.mapView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 250)
        self.mapView.pin.below(of: self.lineView).horizontally(5).marginTop(10)
        self.descriptionText.pin.horizontally(8).below(of: self.mapView).marginTop(5).bottom()
    }
    
    func update(oldModel: CityDetailViewModel?){
        guard let model = self.model else { return }
        let camera = MKMapCamera(lookingAtCenter: model.location, fromDistance: 1000, pitch: 0, heading: 0)
        self.mapView.setCamera(camera, animated: true)
        self.descriptionText.setText(searchTerms: model.city) {
            self.setNeedsLayout()
        }
        self.cityNameLabel.text = model.city
        let marker = MarkerPool.getMarker(location: model.location, text: model.city)
        self.mapView.addAnnotation(marker)
        //WikipediaAPI.shared.findExactWikipediaArticleName(searchTerms: model.city).then(WikipediaAPI.shared.getWikidataId).then(in: .background) {_ in }
        WikipediaAPI.shared.getCityDetail(CityName: model.city, WikidataId: "").then(in: .background){_ in}
    }
}
