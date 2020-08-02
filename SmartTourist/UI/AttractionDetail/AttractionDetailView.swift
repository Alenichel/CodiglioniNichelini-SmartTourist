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
    let nRatings: String
    let wikipediaLink: String?
    let wikipediaSearchTerms: String
    let actualLocation: CLLocationCoordinate2D
    let favorite: Bool
    let allLoaded: Bool
    let link: String?
    
    init?(state: AppState?, localState: AttractionDetailLocalState) {
        guard let state = state else { return nil }
        self.attraction = localState.attraction
        if let nRatings = localState.attraction.userRatingsTotal {
            self.nRatings = nRatings > 1000 ? "\(Int(nRatings / 1000))k" : "\(nRatings)"
        } else {
            self.nRatings = "0"
        }
        self.wikipediaSearchTerms = self.attraction.wikipediaName ?? ""
        self.wikipediaLink = self.attraction.wikipediaLink
        self.actualLocation = state.locationState.currentLocation!
        self.favorite = state.favorites.contains(attraction)
        self.allLoaded = localState.allLoaded
        self.link = localState.attraction.website
    }
}


class AttractionDetailView: UIView, ViewControllerModellableView {
    private static let isFavoriteImage = UIImage(systemName: "heart.fill")
    private static let isNotFavoriteImage = UIImage(systemName: "heart")
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
    var wikipediaButton = RoundedButton()
    var timeLabel = UILabel()
    var buttonsStack = ManualStackView()
    var contributeButton = RoundedButton()
    
    var didTapFavoriteButton: ((WDPlace) -> Void)?
    var didLoadEverything: Interaction?
    var didTapDirectionButton: ((CLLocationCoordinate2D?, WDPlace?) -> Void)?
    var didTapLinkButton: ((String?) -> Void)?
    var didTapWikipediaButton: ((String?) -> Void)?
    var didTapContributeButton: Interaction?
    var didTapMap: ((WDPlace) -> Void)?

    func setup() {
        self.navigationItem?.rightBarButtonItem = self.favoriteButton
        self.favoriteButton.onTap { button in
            guard let model = self.model else { return }
            self.didTapFavoriteButton?(model.attraction)
        }
        
        self.scrollView.delegate = self
        self.scrollView.showsVerticalScrollIndicator = false
        self.addSubview(self.scrollView)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        recognizer.cancelsTouchesInView = false
        self.scrollView.addGestureRecognizer(recognizer)
        
        self.imageSlideshow.slideshowInterval = 5
        self.imageSlideshow.zoomEnabled = true
        self.imageSlideshow.pageIndicator = nil
        self.imageSlideshow.contentScaleMode = .scaleAspectFill
        self.scrollView.addSubview(self.imageSlideshow)
        
        self.scrollView.addSubview(self.containerView)
        self.containerView.addSubview(self.cosmos)
        self.containerView.addSubview(self.nRatingsLabel)
        self.directionButton.on(.touchUpInside) { button in
            self.didTapDirectionButton?(self.model?.actualLocation, self.model?.attraction)
        }
        self.linkButton.on(.touchUpInside) { button in
            self.didTapLinkButton?(self.model?.link)
        }
        self.wikipediaButton.on(.touchUpInside) { button in
            self.didTapWikipediaButton?(self.model?.wikipediaLink)
        }
        self.contributeButton.on(.touchUpInside) { button in
            self.didTapContributeButton?()
        }
        self.buttonsStack.setup()
        self.containerView.addSubview(self.buttonsStack)
        self.containerView.addSubview(self.lineView)
        
        self.descriptionText.numberOfLines = 0
        self.containerView.addSubview(self.descriptionText)
        self.containerView.addSubview(self.contributeButton)
        self.containerView.addSubview(self.mapView)
        
        //self.containerView.addSubview(self.timeLabel)
        self.mapView.showsTraffic = false
        self.mapView.pointOfInterestFilter = .init(including: [.publicTransport])
        
        //must be at the end to cover all the screen
        self.curtainView.addSubview(self.activityIndicator)
        self.addSubview(self.curtainView)
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.descriptionText.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.15)
        self.descriptionText.textAlignment = NSTextAlignment.justified
        self.cosmos.settings.updateOnTouch = false
        self.cosmos.settings.starSize = Double(UIFont.systemFontSize) * 1.4
        self.cosmos.settings.starMargin = 5
        self.cosmos.settings.fillMode = .precise
        self.cosmos.settings.filledImage = UIImage(systemName: "star.fill")?.maskWithColor(color: .orange)
        self.cosmos.settings.emptyImage = UIImage(systemName: "star")?.maskWithColor(color: .orange)
        self.cosmos.settings.disablePanGestures = true
        self.containerView.backgroundColor = .systemBackground
        self.nRatingsLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.2, weight: .bold)
        self.nRatingsLabel.textColor = .systemOrange
        self.lineView.backgroundColor = .secondaryLabel
        self.mapView.showsCompass = false
        self.curtainView.backgroundColor = .systemBackground
        self.activityIndicator.startAnimating()
        styleRoundedButton(button: self.directionButton, image: UIImage.fontAwesomeIcon(name: .shoePrints, style: .solid, textColor: .label, size: CGSize(size: 30)))
        styleRoundedButton(button: self.linkButton, image: AttractionDetailView.linkImage!)
        styleRoundedButton(button: self.wikipediaButton, image: UIImage.fontAwesomeIcon(name: .wikipediaW, style: .brands, textColor: .label, size: CGSize(size: 40)))
        self.contributeButton.setTitle("Contribute!", for: .normal)
        self.contributeButton.setTitleColor(.label, for: .normal)
        self.contributeButton.backgroundColor = .systemBackground
        self.contributeButton.layer.cornerRadius = 20
        self.contributeButton.layer.shadowColor = UIColor.label.cgColor
        self.contributeButton.layer.shadowOpacity = 0.75
        self.contributeButton.layer.shadowOffset = .zero
        self.timeLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .light)
        self.timeLabel.textAlignment = .right
        self.timeLabel.sizeToFit()
        self.favoriteButton.tintColor = .systemRed
        self.buttonsStack.style()
    }
    
    func styleRoundedButton(button: RoundedButton, image: UIImage){
        button.tintColor = .label
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.label.cgColor
        button.layer.shadowOpacity = 0.40
        button.layer.shadowOffset = .zero
        button.layer.shadowRadius = 1
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.pin.top(self.safeAreaInsets).bottom().horizontally()
        self.curtainView.pin.all()
        self.activityIndicator.pin.center().size(30)
        
        self.imageSlideshow.sizeToFit()
        self.imageSlideshow.pin.top().bottom(50%).left().right()
        
        self.containerView.pin.horizontally().bottom(10).below(of: self.imageSlideshow)
        
        self.cosmos.sizeToFit()
        self.cosmos.pin.topLeft().marginHorizontal(20).marginTop(15)
        self.nRatingsLabel.sizeToFit()
        self.nRatingsLabel.pin.after(of: self.cosmos, aligned: .center).marginLeft(5)
        
        self.linkButton.pin.size(40)
        self.directionButton.pin.size(40)
        self.wikipediaButton.pin.size(40)
        let linksViewHeight = (self.buttonsStack.stackedSubviews as! [RoundedButton]).map({$0.frame.height}).max()
        if let model = self.model {
            if model.nRatings == "0" {
                self.buttonsStack.pin.top().horizontally().height(linksViewHeight ?? 50).marginTop(15)
            } else {
                self.buttonsStack.pin.below(of: self.cosmos).horizontally().height(linksViewHeight ?? 50).marginTop(15)
            }
        }
        
        self.lineView.pin.below(of: [self.buttonsStack]).horizontally(7).height(1).marginTop(15)
        
        self.mapView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 300)
        if let text = self.descriptionText.text {
            self.descriptionText.sizeToFit()
            let textContentHeight = text.height(constraintedWidth: self.frame.width, font: self.descriptionText.font)
            self.descriptionText.pin.horizontally(20).below(of: self.lineView).marginTop(5)//.height(textContentHeight)
            self.descriptionText.sizeToFit()
            let frameHeight: CGFloat = self.frame.height
            let mapHeight: CGFloat = 300
            let h = textContentHeight + frameHeight / 1.8 + mapHeight + 50
            self.scrollView.contentSize = CGSize(width: self.frame.width, height: h)
            if text != defaultDescription {
                self.mapView.pin.horizontally(20).below(of: descriptionText).marginTop(20)
            } else {
                self.contributeButton.sizeToFit()
                self.contributeButton.pin.below(of: descriptionText, aligned: .center).horizontally(20).marginTop(20).width(180)
                self.mapView.pin.horizontally(20).below(of: contributeButton).marginTop(20)
            }
        } else {
            self.mapView.pin.horizontally(20).below(of: self.lineView).marginTop(15)
        }
    }
    
    func update(oldModel: AttractionDetailViewModel?) {
        guard let model = self.model else { return }
        if let rating = model.attraction.rating {
            if (rating == 0) {
                self.cosmos.isHidden = true
                self.nRatingsLabel.isHidden = true
            }
            self.cosmos.rating = rating
        }
        self.nRatingsLabel.text = model.nRatings
        
        if !model.allLoaded {
            model.attraction.getPhotosURLs().then(in: .main) {
                var photos = [URL]()
                if let attractionPhotos = model.attraction.photos {
                    photos = attractionPhotos
                }
                let imagePromises = photos.map { WikipediaAPI.shared.getPhoto(imageURL: $0) }
                self.imageSlideshow.setImageInputs(imagePromises.map { PromiseImageSource($0) })
                self.descriptionText.setText(title: model.wikipediaSearchTerms) {
                    self.didLoadEverything?()
                }
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
            self.curtainView.isHidden = true
            self.curtainView.removeFromSuperview()
        }
        
        self.timeLabel.setText(actualLocation: model.actualLocation, attraction: model.attraction)
        if self.timeLabel.text == "Unavailable" {
            self.directionButton.isEnabled = false
        } else {
            self.directionButton.isEnabled = true
        }
        
        
        var views = [self.directionButton]
        if model.wikipediaLink != nil {
            views.append(self.wikipediaButton)
        }
        if model.link != nil {
            views.append(self.linkButton)
        }
        let bsViewModel = ManualStackViewModel(views: views)
        self.buttonsStack.model = bsViewModel
        
        self.setNeedsLayout()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.directionButton.setImage(UIImage.fontAwesomeIcon(name: .shoePrints, style: .solid, textColor: .label, size: CGSize(size: 30)), for: .normal)
        self.directionButton.layer.shadowColor = UIColor.label.cgColor
        self.linkButton.layer.shadowColor = UIColor.label.cgColor
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: self.mapView)
        let frame = self.mapView.frame
        if point.x >= 0 && point.x <= frame.width && point.y >= 0 && point.y <= frame.height {
            guard let model = self.model else { return }
            self.didTapMap?(model.attraction)
        }
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
