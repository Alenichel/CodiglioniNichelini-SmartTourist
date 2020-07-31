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
import FlexLayout
import Cosmos
import CoreLocation
import MapKit
import Hydra
import ImageSlideshow


struct CityDetailViewModel: ViewModelWithLocalState {
    let wdCity: WDCity?
    let cityName: String
    let location: CLLocationCoordinate2D
    let allLoaded: Bool
    
    init?(state: AppState?, localState: CityDetailLocalState) {
        guard let state = state else { return nil }
        self.cityName = state.locationState.currentCity!
        self.location = state.locationState.currentLocation!
        self.allLoaded = localState.allLoaded
        self.wdCity = state.locationState.wdCity
    }
}


class CityDetailView: UIView, ViewControllerModellableView {
    // MARK: Containers
    var scrollView = UIScrollView()
    var titleContainerView = UIView()
    var infoView = UIView()
    var linksView = UIView()
    
    // MARK: Actual views
    var cityLabel = UILabel()
    var countryLabel = UILabel()
    var flagView = UIImageView()
    var slideshow = ImageSlideshow()
    var populationIcon = UIImageView()
    var populationLabel = UILabel()
    var areaIcon = UIImageView()
    var areaLabel = UILabel()
    var elevationIcon = UIImageView()
    var elevationLabel = UILabel()
    var linkButton: RoundedButton!
    var facebookButton: RoundedButton!
    var instagramButton: RoundedButton!
    var twitterButton: RoundedButton!
    var descriptionLabel = UILabel()
    
    // MARK: Utility
    var mapView = MKMapView()
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        formatter.numberStyle = .decimal
        return formatter
    }()
    let measurementFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.unitOptions = .naturalScale
        return formatter
    }()
    
    func setup() {
        self.setupMapView()
        self.setupInfoIcons()
        self.setupSocialButtons()
        self.slideshow.slideshowInterval = 5
        self.slideshow.zoomEnabled = true
        self.slideshow.pageIndicator = nil
        self.slideshow.contentScaleMode = .scaleAspectFill
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.titleContainerView)
        self.scrollView.addSubview(self.slideshow)
        self.scrollView.addSubview(self.infoView)
        self.scrollView.addSubview(self.linksView)
        self.scrollView.addSubview(self.descriptionLabel)
        self.titleContainerView.flex.direction(.column).define { flex in
            flex.alignItems(.center)
            flex.addItem(self.cityLabel)
            flex.addItem().direction(.row).define { flex in
                flex.alignItems(.center)
                flex.addItem(self.countryLabel)
                flex.addItem(self.flagView).marginLeft(5).size(15)
            }
            flex.addItem().height(1).width(95%).marginVertical(5).backgroundColor(.secondaryLabel)
        }
        self.infoView.flex.direction(.row).define { flex in
            flex.alignItems(.center)
            flex.justifyContent(.spaceAround)
            flex.addItem().direction(.column).grow(1).define { flex in
                flex.alignItems(.center)
                flex.addItem(self.populationIcon).size(25)
                flex.addItem(self.populationLabel)
            }
            flex.addItem().direction(.column).grow(1).define { flex in
                flex.alignItems(.center)
                flex.addItem(self.areaIcon).size(25)
                flex.addItem(self.areaLabel)
            }
            flex.addItem().direction(.column).grow(1).define { flex in
                flex.alignItems(.center)
                flex.addItem(self.elevationIcon).size(25)
                flex.addItem(self.elevationLabel)
            }
        }
        self.linksView.flex.direction(.row).justifyContent(.spaceAround).define { flex in
            flex.addItem(self.linkButton).size(40)
            flex.addItem(self.facebookButton).size(40)
            flex.addItem(self.instagramButton).size(40)
            flex.addItem(self.twitterButton).size(40)
        }
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.scrollView.showsVerticalScrollIndicator = false
        self.cityLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        self.countryLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.15 , weight: .thin)
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.15)
        self.descriptionLabel.textAlignment = .justified
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.pin.all().margin(pin.safeArea)
        self.titleContainerView.pin.top().horizontally()
        self.titleContainerView.flex.layout(mode: .adjustHeight)
        self.slideshow.pin.below(of: self.titleContainerView).horizontally().marginTop(5).bottom(50%)
        self.infoView.pin.below(of: self.slideshow).horizontally().marginTop(10)
        self.infoView.flex.layout(mode: .adjustHeight)
        self.linksView.pin.below(of: self.infoView).horizontally().marginTop(15)
        self.linksView.flex.layout(mode: .adjustHeight)
        if let text = self.descriptionLabel.text {
            self.descriptionLabel.sizeToFit()
            let textContentHeight = text.height(constraintedWidth: self.frame.width, font: self.descriptionLabel.font)
            self.descriptionLabel.pin.horizontally(20).below(of: self.linksView).marginTop(10)
            self.descriptionLabel.sizeToFit()
            let contentHeight = self.titleContainerView.frame.height + self.slideshow.frame.height + self.infoView.frame.height + self.linksView.frame.height + textContentHeight + self.safeAreaInsets.top + self.safeAreaInsets.bottom + 70
            self.scrollView.contentSize = CGSize(width: self.frame.width, height: contentHeight)
        }
    }
    
    func update(oldModel: CityDetailViewModel?) {
        guard let model = self.model, let city = model.wdCity else { return }
        self.cityLabel.text = city.cityLabel ?? "NO CITY LABEL"
        self.countryLabel.text = city.countryLabel ?? "NO COUNTRY LABEL"
        self.flagView.image = city.countryFlagImage ?? UIImage(systemName: "photo")
        let mapCamera = MKMapCamera(lookingAtCenter: model.location, fromDistance: 20000, pitch: 0, heading: 0)
        self.mapView.setCamera(mapCamera, animated: false)
        let marker = MarkerPool.getMarker(location: model.location, text: " ")
        self.mapView.addAnnotation(marker)
        let mapScreenshot = self.mapView.screenshot()
        city.getPhotosURLs().then(in: .main) {
            var imagePromises = city.photos.map { WikipediaAPI.shared.getPhoto(imageURL: $0) }
            imagePromises.append(mapScreenshot)
            self.slideshow.setImageInputs(imagePromises.map { PromiseImageSource($0) })
        }
        if let population = city.population {
            self.populationLabel.text = self.numberFormatter.string(from: population as NSNumber)!
        } else {
            self.populationLabel.text = "N/A"
        }
        if let area = city.area {
            let measurement = Measurement(value: area, unit: UnitArea.squareKilometers)
            self.areaLabel.text = self.measurementFormatter.string(from: measurement)
        } else {
            self.areaLabel.text = "N/A"
        }
        if let elevation = city.elevation {
            let measurement = Measurement(value: elevation, unit: UnitLength.meters)
            self.elevationLabel.text = self.measurementFormatter.string(from: measurement)
        } else {
            self.elevationLabel.text = "N/A"
        }
        if let link = city.link {
            let url = URL(string: link)!
            self.linkButton.on(.touchUpInside) { _ in
                UIApplication.shared.open(url)
            }
            self.linkButton.alpha = 1.0
        } else {
            self.linkButton.isEnabled = false
            self.linkButton.alpha = 0.7
        }
        if let facebookId = city.facebookPageId {
            let url = URL(string: "https://www.facebook.com/\(facebookId)")!
            self.facebookButton.on(.touchUpInside) { _ in
                UIApplication.shared.open(url)
            }
            self.facebookButton.alpha = 1.0
        } else if let facebookPlacesId = city.facebookPlacesId {
            let url = URL(string: "https://www.facebook.com/\(facebookPlacesId)")!
            self.facebookButton.on(.touchUpInside) { _ in
                UIApplication.shared.open(url)
            }
            self.facebookButton.alpha = 1.0
        } else {
            self.facebookButton.isEnabled = false
            self.facebookButton.alpha = 0.7
        }
        if let instagramUsername = city.instagramUsername {
            let url = URL(string: "https://www.instagram.com/\(instagramUsername)")!
            self.instagramButton.on(.touchUpInside) { _ in
                UIApplication.shared.open(url)
            }
            self.instagramButton.alpha = 1.0
        } else {
            self.instagramButton.isEnabled = false
            self.instagramButton.alpha = 0.7
        }
        if let twitterUsername = city.twitterUsername {
            let url = URL(string: "https://www.twitter.com/\(twitterUsername)")!
            self.twitterButton.on(.touchUpInside) { _ in
                UIApplication.shared.open(url)
            }
            self.twitterButton.alpha = 1.0
        } else {
            self.twitterButton.isEnabled = false
            self.twitterButton.alpha = 0.7
        }
        self.descriptionLabel.setText(city: city) {
            DispatchQueue.main.async {
                self.setNeedsLayout()
            }
        }
        self.markDirty()
        self.setNeedsLayout()
    }
    
    private func setupMapView() {
        self.mapView.showsTraffic = false
        self.mapView.showsCompass = false
        self.mapView.isUserInteractionEnabled = false
        self.mapView.pointOfInterestFilter = .init(including: [.publicTransport])
        let screenWidth = UIScreen.main.bounds.width
        self.mapView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth)
    }
    
    private func setupInfoIcons() {
        self.populationIcon.image = UIImage.fontAwesomeIcon(name: .users, style: .solid, textColor: .label, size: CGSize(size: 25))
        self.areaIcon.image = UIImage.fontAwesomeIcon(name: .square, style: .solid, textColor: .label, size: CGSize(size: 25))
        self.elevationIcon.image = UIImage.fontAwesomeIcon(name: .mountain, style: .solid, textColor: .label, size: CGSize(size: 25))
    }
    
    private func getLinkButton(icon: UIImage, color: UIColor = .systemBackground) -> RoundedButton {
        let button = RoundedButton()
        button.tintColor = .label
        button.backgroundColor = color
        button.layer.cornerRadius = 20
        button.setImage(icon, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        return button
    }
    
    private func setupSocialButtons() {
        let linkIcon = UIImage.fontAwesomeIcon(name: .link, style: .solid, textColor: .white, size: CGSize(size: 40))
        let linkColor = UIColor(red: 0.99, green: 0.69, blue: 0.27, alpha: 1)
        self.linkButton = self.getLinkButton(icon: linkIcon, color: linkColor)
        let facebookIcon = UIImage.fontAwesomeIcon(name: .facebookF, style: .brands, textColor: .white, size: CGSize(size: 40))
        let facebookColor = UIColor(red: 0.26, green: 0.4, blue: 0.7, alpha: 1)
        self.facebookButton = self.getLinkButton(icon: facebookIcon, color: facebookColor)
        let instagramIcon = UIImage.fontAwesomeIcon(name: .instagram, style: .brands, textColor: .white, size: CGSize(size: 40))
        let instagramColor = UIColor(red: 0.88, green: 0.19, blue: 0.42, alpha: 1)
        self.instagramButton = self.getLinkButton(icon: instagramIcon, color: instagramColor)
        let twitterIcon = UIImage.fontAwesomeIcon(name: .twitter, style: .brands, textColor: .white, size: CGSize(size: 40))
        let twitterColor = UIColor(red: 0.11, green: 0.63, blue: 0.95, alpha: 1)
        self.twitterButton = self.getLinkButton(icon: twitterIcon, color: twitterColor)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupInfoIcons()
    }
    
    private func markDirty() {
        self.cityLabel.flex.markDirty()
        self.countryLabel.flex.markDirty()
        self.flagView.flex.markDirty()
        self.populationIcon.flex.markDirty()
        self.populationLabel.flex.markDirty()
        self.areaIcon.flex.markDirty()
        self.areaLabel.flex.markDirty()
        self.elevationIcon.flex.markDirty()
        self.elevationLabel.flex.markDirty()
        self.linkButton.flex.markDirty()
        self.facebookButton.flex.markDirty()
        self.instagramButton.flex.markDirty()
        self.twitterButton.flex.markDirty()
    }
}

