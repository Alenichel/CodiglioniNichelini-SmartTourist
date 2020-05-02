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
    var titleContainerView = UIView()
    var cityNameLabel = UILabel()
    var countryNameLabel = UILabel()
    var mapView = MKMapView()
    var descriptionText = UITextView()
    var lineView = UIView()
    var detailsStackView: UIStackView!
    var infoView = ManualStackView()
    var linksView = ManualStackView()
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
        self.linksView.setup()
        self.addSubview(self.linksView)
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
        self.linksView.style()
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
        let linksViewHeight = (self.linksView.stackedSubviews as! [RoundedButton]).map({$0.frame.height}).max()
        self.linksView.pin.below(of: self.infoView).horizontally(5).marginTop(10).height(linksViewHeight ?? 0)
        self.descriptionText.pin.horizontally(8).below(of: self.linksView).marginTop(5).bottom()
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
            var infoViews = [UIView]()
            if let population = city.population {
                let icon = UIImage.fontAwesomeIcon(name: .users, style: .solid, textColor: .label, size: CGSize(size: 25))
                infoViews.append(self.getIconView(label: "\(population)", icon: icon))
            }
            if let area = city.area {
                let icon = UIImage.fontAwesomeIcon(name: .square, style: .solid, textColor: .label, size: CGSize(size: 25))
                infoViews.append(self.getIconView(label: "\(area)", icon: icon))
            }
            if let elevation = city.elevation {
                let icon = UIImage.fontAwesomeIcon(name: .mountain, style: .solid, textColor: .label, size: CGSize(size: 25))
                infoViews.append(self.getIconView(label: "\(elevation)", icon: icon))
            }
            let infoViewModel = ManualStackViewModel(views: infoViews)
            self.infoView.model = infoViewModel
            var linkViews = [UIView]()
            if let link = city.link {
                let icon = UIImage.fontAwesomeIcon(name: .link, style: .solid, textColor: .white, size: CGSize(size: 40))
                let color = UIColor(red: 0.99, green: 0.69, blue: 0.27, alpha: 1)
                linkViews.append(self.getLinkButton(url: URL(string: link)!, icon: icon, color: color))
            }
            if let facebookId = city.facebookPageId {
                let url = URL(string: "https://www.facebook.com/\(facebookId)")!
                let icon = UIImage.fontAwesomeIcon(name: .facebookF, style: .brands, textColor: .white, size: CGSize(size: 40))
                let color = UIColor(red: 0.26, green: 0.4, blue: 0.7, alpha: 1)
                linkViews.append(self.getLinkButton(url: url, icon: icon, color: color))
            }
            if let instagramUsername = city.instagramUsername {
                let url = URL(string: "https://www.instagram.com/\(instagramUsername)")!
                let icon = UIImage.fontAwesomeIcon(name: .instagram, style: .brands, textColor: .white, size: CGSize(size: 40))
                let color = UIColor(red: 0.88, green: 0.19, blue: 0.42, alpha: 1)
                linkViews.append(self.getLinkButton(url: url, icon: icon, color: color))
            }
            if let twitterUsername = city.twitterUsername {
                let url = URL(string: "https://www.twitter.com/\(twitterUsername)")!
                let icon = UIImage.fontAwesomeIcon(name: .twitter, style: .brands, textColor: .white, size: CGSize(size: 40))
                let color = UIColor(red: 0.11, green: 0.63, blue: 0.95, alpha: 1)
                linkViews.append(self.getLinkButton(url: url, icon: icon, color: color))
            }
            let linksViewModel = ManualStackViewModel(views: linkViews)
            self.linksView.model = linksViewModel
            
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
    
    private func getLinkButton(url: URL, icon: UIImage, color: UIColor = .systemBackground) -> UIView {
        var button = RoundedButton()
        button.tintColor = .label
        button.backgroundColor = color
        button.layer.cornerRadius = 20
        /*button.layer.shadowColor = UIColor.label.cgColor
        button.layer.shadowOpacity = 0.75
        button.layer.shadowOffset = .zero
        button.layer.shadowRadius = 1*/
        button.setImage(icon, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        button.on(.touchUpInside) { _ in
            UIApplication.shared.open(url)
        }
        button.pin.size(40)
        return button
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let model = self.model
        self.model = model
    }
}
