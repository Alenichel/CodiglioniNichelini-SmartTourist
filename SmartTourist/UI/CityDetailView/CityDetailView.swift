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
    let city: WDCity?
    let cityName: String
    let location: CLLocationCoordinate2D
    let allLoaded: Bool
    
    init?(state: AppState?, localState: CityDetailLocalState) {
        guard let state = state else { return nil }
        self.cityName = state.locationState.currentCity!
        self.location = state.locationState.currentLocation!
        self.allLoaded = localState.allLoaded
        self.city = state.locationState.wdCity
    }
}


class CityDetailView: UIView, ViewControllerModellableView {
    
    static private var elevationImage = UIImage.fontAwesomeIcon(name: .mountain, style: .solid, textColor: .label, size: CGSize(size: 25))
    static private var populationImage = UIImage.fontAwesomeIcon(name: .users, style: .solid, textColor: .label, size: CGSize(size: 25))
    static private var areaImage = UIImage.fontAwesomeIcon(name: .square, style: .solid, textColor: .label, size: CGSize(size: 25))
    
    var titleContainerView = UIView()
    var cityNameLabel = UILabel()
    var countryNameLabel = UILabel()
    var mapView = MKMapView()
    var descriptionText = UITextView()
    var lineView = UIView()
    var detailsContainerView = UIView()
    var elevationImageView = UIImageView()
    var elevationLabel = UILabel()
    var populationImageView = UIImageView()
    var populationLabel = UILabel()
    var areaImageView = UIImageView()
    var areaLabel = UILabel()
    
    func setup() {
        self.mapView.showsTraffic = false
        self.mapView.pointOfInterestFilter = .init(including: [.publicTransport])
        self.addSubview(self.titleContainerView)
        self.titleContainerView.addSubview(self.cityNameLabel)
        self.titleContainerView.addSubview(self.countryNameLabel)
        self.addSubview(self.lineView)
        self.addSubview(self.mapView)
        self.addSubview(self.detailsContainerView)
        self.detailsContainerView.addSubview(self.elevationImageView)
        self.detailsContainerView.addSubview(self.elevationLabel)
        self.detailsContainerView.addSubview(self.populationImageView)
        self.detailsContainerView.addSubview(self.populationLabel)
        self.detailsContainerView.addSubview(self.areaImageView)
        self.detailsContainerView.addSubview(self.areaLabel)

        self.addSubview(self.descriptionText)
        self.descriptionText.showsVerticalScrollIndicator = false
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.cityNameLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        self.cityNameLabel.textAlignment = .center
        self.cityNameLabel.layer.cornerRadius = 20
        self.countryNameLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.15 , weight: .thin)
        self.countryNameLabel.textAlignment = .center
        self.countryNameLabel.layer.cornerRadius = 20
        self.mapView.showsCompass = false
        self.mapView.isUserInteractionEnabled = false
        self.descriptionText.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.15)
        self.descriptionText.isEditable = false
        self.descriptionText.textAlignment = NSTextAlignment.justified
        self.lineView.backgroundColor = .secondaryLabel
//        self.detailsContainerView.backgroundColor = .lightGray
        self.detailsContainerView.alpha = 0.3
        self.elevationLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.15 , weight: .thin)
        self.elevationLabel.textAlignment = .center
        self.elevationLabel.layer.cornerRadius = 20
        self.populationLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.15 , weight: .thin)
        self.populationLabel.textAlignment = .center
        self.populationLabel.layer.cornerRadius = 20
        self.areaLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.15 , weight: .thin)
        self.areaLabel.textAlignment = .center
        self.areaLabel.layer.cornerRadius = 20
        self.elevationImageView.image = CityDetailView.elevationImage
        self.populationImageView.image = CityDetailView.populationImage
        self.areaImageView.image = CityDetailView.areaImage
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.cityNameLabel.sizeToFit()
        self.cityNameLabel.pin.top().horizontally().marginTop(3)
        self.countryNameLabel.sizeToFit()
        self.countryNameLabel.pin.below(of: cityNameLabel, aligned: .center).marginTop(3)
        let tcvHeight = self.cityNameLabel.frame.height + self.countryNameLabel.frame.height + 8
        self.titleContainerView.pin.top(self.safeAreaInsets).width(100%).height(tcvHeight)
        self.lineView.pin.below(of: self.titleContainerView).height(1).horizontally(7)
        self.mapView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 250)
        self.mapView.pin.below(of: self.lineView).horizontally(5).marginTop(5)
        self.elevationImageView.sizeToFit()
        self.elevationImageView.pin.topLeft().marginTop(10).marginLeft(20)
        self.elevationLabel.sizeToFit()
        self.elevationLabel.pin.below(of: self.elevationImageView, aligned: .center)
        self.populationImageView.sizeToFit()
        self.populationImageView.pin.topCenter().marginTop(10)
        self.populationLabel.sizeToFit()
        self.populationLabel.pin.below(of: self.populationImageView, aligned: .center)
        self.areaImageView.sizeToFit()
        self.areaImageView.pin.topRight().marginTop(10).marginRight(20)
        self.areaLabel.sizeToFit()
        self.areaLabel.pin.below(of: self.areaImageView, aligned: .center)
        self.detailsContainerView.pin.below(of: self.mapView).horizontally().height(100)
        self.descriptionText.pin.horizontally(8).below(of: self.detailsContainerView).marginTop(5).bottom()
    }
    
    func update(oldModel: CityDetailViewModel?){
        guard let model = self.model else { return }
        let camera = MKMapCamera(lookingAtCenter: model.location, fromDistance: 20000, pitch: 0, heading: 0)
        self.mapView.setCamera(camera, animated: true)
        self.descriptionText.setText(searchTerms: model.cityName) {
            self.setNeedsLayout()
        }
        if let city = model.city {
            self.countryNameLabel.text = city.countryLabel ?? "No country detected"
            self.elevationLabel.text = "\(city.elevation ?? 0)"
            self.populationLabel.text = "\(city.population ?? 0)"
            self.areaLabel.text = "\(city.area ?? 0)"
            if elevationLabel.text == "0" {
                self.elevationImageView.isHidden = true
                self.elevationLabel.isHidden = true
            }
            if populationLabel.text == "0" {
                self.populationImageView.isHidden = true
                self.populationLabel.isHidden = true
            }
            if areaLabel.text == "0" {
                self.areaImageView.isHidden = true
                self.areaLabel.isHidden = true
            }

        }
        self.cityNameLabel.text = model.cityName
        let marker = MarkerPool.getMarker(location: model.location, text: model.cityName)
        self.mapView.addAnnotation(marker)
    }
}
