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
import Hydra


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
    var detailsStackView: UIStackView!
    var infoView = ManualStackView()
    var flagImageView = UIImageView()
    
    func setup() {
        self.mapView.showsTraffic = false
        self.mapView.pointOfInterestFilter = .init(including: [.publicTransport])
        self.addSubview(self.titleContainerView)
        self.titleContainerView.addSubview(self.cityNameLabel)
        self.titleContainerView.addSubview(self.countryNameLabel)
        self.titleContainerView.addSubview(self.flagImageView)
        self.addSubview(self.lineView)
        self.addSubview(self.mapView)
        self.infoView.setup()
        self.addSubview(self.infoView)
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
        self.infoView.style()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.cityNameLabel.sizeToFit()
        self.cityNameLabel.pin.top().horizontally().marginTop(3)
        self.countryNameLabel.sizeToFit()
        self.countryNameLabel.pin.below(of: cityNameLabel, aligned: .center).marginTop(3)
        self.flagImageView.sizeToFit()
        self.flagImageView.pin.after(of: self.countryNameLabel, aligned: .center).marginLeft(5)
        let tcvHeight = self.cityNameLabel.frame.height + self.countryNameLabel.frame.height + 8
        self.titleContainerView.pin.top(self.safeAreaInsets).width(100%).height(tcvHeight)
        self.lineView.pin.below(of: self.titleContainerView).height(1).horizontally(7)
        self.mapView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 250)
        self.mapView.pin.below(of: self.lineView).horizontally(5).marginTop(5)
        let infoViewHeight = (self.infoView.stackedSubviews as! [CityDetailInfoIcon]).map({$0.getHeight()}).max()
        self.infoView.pin.below(of: self.mapView).horizontally(5).marginTop(10).height(infoViewHeight ?? 0)
        self.descriptionText.pin.horizontally(8).below(of: self.infoView).marginTop(5).bottom()
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
            self.flagImageView.image = city.countryFlagImage
            var views = [UIView]()
            if let population = city.population {
                views.append(self.getPopulationView(value: population))
            }
            if let area = city.area {
                views.append(self.getAreaView(value: area))
            }
            if let elevation = city.elevation {
                views.append(self.getElevationView(value: elevation))
            }
            let infoViewModel = ManualStackViewModel(views: views)
            self.infoView.model = infoViewModel
        }
        self.cityNameLabel.text = model.cityName
        let marker = MarkerPool.getMarker(location: model.location, text: model.cityName)
        self.mapView.addAnnotation(marker)
    }
    
    private func getIconView(label: String, icon: UIImage) -> UIView {
        let view = CityDetailInfoIcon()
        view.setup()
        view.style()
        let viewModel = CityDetailInfoIconViewModel(label: label, icon: icon)
        view.model = viewModel
        return view
    }
    
    private func getElevationView(value: Int) -> UIView {
        return getIconView(label: "\(value)", icon: CityDetailView.elevationImage)
    }
    
    private func getPopulationView(value: Int) -> UIView {
        return getIconView(label: "\(value)", icon: CityDetailView.populationImage)
    }
    
    private func getAreaView(value: Double) -> UIView {
        return getIconView(label: "\(value)", icon: CityDetailView.areaImage)
    }
}
