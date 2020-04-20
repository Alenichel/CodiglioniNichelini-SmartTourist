//
//  AttractionDetailView.swift
//  SmartTourist
//
//  Created on 01/12/2019
//

import UIKit
import Katana
import Tempura
import PinLayout
import Cosmos
import CoreLocation
import MapKit
import ImageSlideshow
import FontAwesome_swift


struct AttractionDetailViewModel: ViewModelWithLocalState {
    let attraction: WDPlace
    let photos: [URL]?
    let nRatings: String
    let wikipediaSearchTerms: String
    let currentLocation: CLLocationCoordinate2D
    let favorite: Bool
    let allLoaded: Bool
    let link: String?
    
    init?(state: AppState?, localState: AttractionDetailLocalState) {
        guard let state = state else { return nil }
        self.attraction = localState.attraction
        self.photos = self.attraction.photos
        if let nRatings = localState.attraction.userRatingsTotal {
            self.nRatings = nRatings > 1000 ? "\(Int(nRatings / 1000))k" : "\(nRatings)"
        } else {
            self.nRatings = "0"
        }
        self.wikipediaSearchTerms = self.attraction.name
        self.currentLocation = state.locationState.currentLocation!
        self.favorite = state.favorites.contains(attraction)
        self.allLoaded = localState.allLoaded
        self.link = localState.attraction.website
    }
}


class AttractionDetailView: UIView, ViewControllerModellableView {
    private static let isFavoriteImage = UIImage(systemName: "heart.fill")
    private static let isNotFavoriteImage = UIImage(systemName: "heart")
    //private static let walkingIconImage = UIImage(named: "walking_icon")?.withRenderingMode(.alwaysTemplate)
    private static let linkImage = UIImage(systemName: "link")
    
    var descriptionText = UILabel()
    var nRatingsLabel = UILabel()
    var cosmos = CosmosView(frame: .zero)
    var containerView = UIView()
    var imageSlideshow = ImageSlideshow()
    var lineView = UIView()
    var scrollView = UIScrollView()
    var mapView = MKMapView()
    var favoriteButton = UIBarButtonItem()
    var curtainView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var directionButton = RoundedButton()
    var linkButton = RoundedButton()
    var timeLabel = UILabel()
    
    var didTapFavoriteButton: ((WDPlace) -> Void)?
    var didLoadEverything: Interaction?
    var didTapDirectionButton: (( CLLocationCoordinate2D?, WDPlace?) -> Void)?
    var didTapLinkButton: ((String?) -> Void)?

    func setup() {
        self.mapView.showsTraffic = false
        self.mapView.pointOfInterestFilter = .init(including: [.publicTransport])
        self.scrollView.delegate = self
        self.addSubview(self.scrollView)
        self.addSubview(self.curtainView)
        self.curtainView.addSubview(self.activityIndicator)
        self.scrollView.addSubview(self.imageSlideshow)
        self.scrollView.addSubview(self.containerView)
        self.containerView.addSubview(self.descriptionText)
        self.containerView.addSubview(self.cosmos)
        self.containerView.addSubview(self.lineView)
        self.containerView.addSubview(self.nRatingsLabel)
        self.containerView.addSubview(self.mapView)
        self.containerView.addSubview(self.directionButton)
        self.containerView.addSubview(self.linkButton)
        self.containerView.addSubview(self.timeLabel)
        self.navigationItem?.rightBarButtonItem = self.favoriteButton
        self.favoriteButton.onTap { button in
            guard let model = self.model else { return }
            self.didTapFavoriteButton?(model.attraction)
        }
        self.descriptionText.numberOfLines = 0
        self.directionButton.on(.touchUpInside) { button in
            self.didTapDirectionButton?(self.model?.currentLocation, self.model?.attraction)
        }
        self.linkButton.on(.touchUpInside) { button in
            self.didTapLinkButton?(self.model?.link)
        }
        self.imageSlideshow.slideshowInterval = 5
        self.imageSlideshow.zoomEnabled = true
        self.imageSlideshow.pageIndicator = nil
        self.imageSlideshow.contentScaleMode = .scaleAspectFill
        self.scrollView.showsVerticalScrollIndicator = false
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.descriptionText.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.15)
        self.descriptionText.textAlignment = NSTextAlignment.justified
        self.cosmos.settings.updateOnTouch = false
        self.cosmos.settings.starSize = Double(UIFont.systemFontSize) * 1.1
        self.cosmos.settings.starMargin = 5
        self.cosmos.settings.fillMode = .precise
        self.cosmos.settings.filledImage = UIImage(systemName: "star.fill")?.maskWithColor(color: .orange)
        self.cosmos.settings.emptyImage = UIImage(systemName: "star")?.maskWithColor(color: .orange)
        self.cosmos.settings.disablePanGestures = true
        self.containerView.backgroundColor = .systemBackground
        self.nRatingsLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .bold)
        self.nRatingsLabel.textColor = .systemOrange
        self.lineView.backgroundColor = .secondaryLabel
        self.mapView.showsCompass = false
        self.mapView.isUserInteractionEnabled = false
        self.curtainView.backgroundColor = .systemBackground
        self.activityIndicator.startAnimating()
        self.directionButton.tintColor = .label
        self.directionButton.backgroundColor = .systemBackground
        self.directionButton.layer.cornerRadius = 15
        self.directionButton.layer.shadowColor = UIColor.label.cgColor
        self.directionButton.layer.shadowOpacity = 0.75
        self.directionButton.layer.shadowOffset = .zero
        self.directionButton.layer.shadowRadius = 1
        self.directionButton.setImage(UIImage.fontAwesomeIcon(name: .shoePrints, style: .solid, textColor: .label, size: CGSize(size: 30)), for: .normal)
        //self.directionButton.setImage(AttractionDetailView.walkingIconImage, for: .normal)
        self.directionButton.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        self.linkButton.tintColor = .label
        self.linkButton.backgroundColor = .systemBackground
        self.linkButton.layer.cornerRadius = 15
        self.linkButton.layer.shadowColor = UIColor.label.cgColor
        self.linkButton.layer.shadowOpacity = 0.75
        self.linkButton.layer.shadowOffset = .zero
        self.linkButton.layer.shadowRadius = 1
        self.linkButton.setImage(AttractionDetailView.linkImage, for: .normal)
        self.linkButton.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        self.timeLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .light)
        self.timeLabel.textAlignment = .right
        self.timeLabel.sizeToFit()
        self.favoriteButton.tintColor = .systemRed
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageSlideshow.sizeToFit()
        self.imageSlideshow.pin.top().bottom(50%).left().right()
        self.containerView.pin.horizontally().bottom(10).below(of: self.imageSlideshow)
        self.cosmos.sizeToFit()
        self.cosmos.pin.topLeft().marginHorizontal(20).marginTop(15)
        if (model?.link != nil){
            self.linkButton.pin.topRight().marginHorizontal(16).marginTop(8).size(30)
            self.directionButton.pin.left(of: self.linkButton, aligned: .center).size(30).margin(5)
        } else {
            self.directionButton.pin.topRight().marginHorizontal(16).marginTop(8).size(30)
        }
        self.timeLabel.pin.before(of: self.directionButton, aligned: .center).size(150).margin(5)
        self.nRatingsLabel.sizeToFit()
        self.nRatingsLabel.pin.after(of: self.cosmos, aligned: .center).marginLeft(5)
        self.lineView.pin.below(of: self.cosmos).horizontally(7).height(1).marginTop(15)
        if let text = self.descriptionText.text {
            self.descriptionText.sizeToFit()
            let textContentHeight = text.height(constraintedWidth: self.frame.width, font: self.descriptionText.font)
            self.descriptionText.pin.horizontally(20).below(of: self.lineView).marginTop(5)//.height(textContentHeight)
            self.descriptionText.sizeToFit()
            let frameHeight: CGFloat = self.frame.height
            let mapHeight: CGFloat = 300
            let h = textContentHeight + frameHeight / 1.8 + mapHeight + 50
            self.scrollView.contentSize = CGSize(width: self.frame.width, height: h)
        }
        self.mapView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 300)
        self.mapView.pin.horizontally(20).below(of: descriptionText).marginTop(20)
        self.scrollView.pin.top(self.safeAreaInsets).bottom().horizontally()
        self.curtainView.pin.all()
        self.activityIndicator.pin.center().size(30)
    }
    
    func update(oldModel: AttractionDetailViewModel?) {
        guard let model = self.model else { return }
        if let rating = model.attraction.rating {
            self.cosmos.rating = rating
        } else {
            self.cosmos.rating = 0
        }
        self.nRatingsLabel.text = model.nRatings
        
        if !model.allLoaded {
            let imagePromises = model.photos!.map { WikipediaAPI.shared.getPhoto(imageURL: $0) }
            self.imageSlideshow.setImageInputs(imagePromises.map { PromiseImageSource($0) })
            self.descriptionText.setText(coordinates: model.attraction.location, searchTerms: model.wikipediaSearchTerms) {
                self.didLoadEverything?()
            }
        }

        let camera = MKMapCamera(lookingAtCenter: model.attraction.location, fromDistance: 1000, pitch: 0, heading: 0)
        self.mapView.setCamera(camera, animated: true)
        
        let marker = MarkerPool.getMarker(place: model.attraction)
        self.mapView.addAnnotation(marker)
        
        if model.favorite {
            self.favoriteButton.image = AttractionDetailView.isFavoriteImage
        } else {
            self.favoriteButton.image = AttractionDetailView.isNotFavoriteImage
        }
        
        if model.allLoaded && !self.curtainView.isHidden {
            GoogleAPI.shared.getTravelTime(origin: model.currentLocation, destination: model.attraction.location).then(in: .utility) { _ in }
            self.curtainView.isHidden = true
            self.curtainView.removeFromSuperview()
        }
        
        self.timeLabel.setText(actualLocation: model.currentLocation, attraction: model.attraction)
        if self.timeLabel.text == "Unavailable" {
            self.directionButton.isEnabled = false
        } else {
            self.directionButton.isEnabled = true
        }
        self.setNeedsLayout()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.directionButton.setImage(UIImage.fontAwesomeIcon(name: .shoePrints, style: .solid, textColor: .label, size: CGSize(size: 30)), for: .normal)
        self.directionButton.layer.shadowColor = UIColor.label.cgColor
        self.linkButton.layer.shadowColor = UIColor.label.cgColor
    }
}


extension AttractionDetailView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        if offset.y < 0.0 {
            var transform = CATransform3DTranslate(CATransform3DIdentity, 0, offset.y, 0)
            let imageHeight = self.imageSlideshow.frame.height
            let scaleFactor = 1 + (-1 * offset.y / (imageHeight / 2))
            transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1)
            self.imageSlideshow.layer.transform = transform
        } else {
            self.imageSlideshow.layer.transform = CATransform3DIdentity
        }
    }
}
