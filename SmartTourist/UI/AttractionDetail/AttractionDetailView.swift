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
import GoogleMaps


struct AttractionDetailViewModel: ViewModelWithLocalState {
    let attraction: GPPlace
    let photo: GPPhoto?
    let nRatings: String
    let wikipediaSearchTerms: String
    let currentLocation: CLLocationCoordinate2D
    let favorite: Bool
    
    init?(state: AppState?, localState: AttractionDetailLocalState) {
        guard let state = state else { return nil }
        self.attraction = localState.attraction
        if let photos = self.attraction.photos {
            self.photo = photos.first
        } else {
            self.photo = nil
        }
        if let nRatings = localState.attraction.userRatingsTotal {
            self.nRatings = nRatings > 1000 ? "\(Int(nRatings / 1000))k" : "\(nRatings)"
        } else {
            self.nRatings = "0"
        }
        self.wikipediaSearchTerms = self.attraction.name
        self.currentLocation = state.locationState.currentLocation!
        self.favorite = state.favorites.contains(attraction)
    }
}


class AttractionDetailView: UIView, ViewControllerModellableView {
    private static let isFavoriteImage = UIImage(systemName: "heart.fill")
    private static let isNotFavoriteImage = UIImage(systemName: "heart")
    
    var descriptionText = UITextView()
    var nRatingsLabel = UILabel()
    var cosmos = CosmosView(frame: .zero)
    var containerView = UIView()
    var imageView = UIImageView()
    var lineView = UIView()
    var scrollView = UIScrollView()
    var mapView = GMSMapView()
    var favoriteButton = UIBarButtonItem()
    
    var didTapFavoriteButton: ((GPPlace) -> Void)?
    
    func setup() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.imageView)
        self.scrollView.addSubview(self.containerView)
        self.containerView.addSubview(self.descriptionText)
        self.containerView.addSubview(self.cosmos)
        self.containerView.addSubview(self.lineView)
        self.containerView.addSubview(self.nRatingsLabel)
        self.containerView.addSubview(self.mapView)
        self.navigationItem?.rightBarButtonItem = self.favoriteButton
        self.favoriteButton.onTap { button in
            guard let model = self.model else { return }
            self.didTapFavoriteButton?(model.attraction)
        }
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.imageView.contentMode = .scaleAspectFill
        self.descriptionText.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.15)
        self.descriptionText.isScrollEnabled = false
        self.descriptionText.isEditable = false
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
        self.mapView.settings.compassButton = false
        self.mapView.isUserInteractionEnabled = false
        self.mapView.loadCustomStyle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.sizeToFit()
        self.imageView.pin.top().bottom(50%).left().right()
        self.containerView.pin.horizontally().bottom(10).below(of: self.imageView)
        self.cosmos.sizeToFit()
        self.cosmos.pin.topLeft().marginHorizontal(20).marginTop(15)
        self.nRatingsLabel.sizeToFit()
        self.nRatingsLabel.pin.after(of: self.cosmos, aligned: .center).marginLeft(5)
        self.lineView.pin.below(of: self.cosmos).horizontally(7).height(1).marginTop(15)
        self.descriptionText.sizeToFit()
        let textContentHeight = self.descriptionText.contentSize.height / 10
        self.descriptionText.pin.horizontally(20).below(of: self.lineView).marginTop(5).height(textContentHeight)
        self.mapView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 300)
        self.mapView.pin.horizontally(20).below(of: descriptionText).marginTop(20)
        self.scrollView.pin.top(self.safeAreaInsets).bottom().horizontally()
        let frameHeight: CGFloat = self.frame.height
        let mapHeight: CGFloat = 300
        print(textContentHeight)
        print(frameHeight)
        print(mapHeight)
        let h = textContentHeight + frameHeight / 1.8 + mapHeight
        self.scrollView.contentSize = CGSize(width: self.frame.width, height: h)
    }
    
    func update(oldModel: AttractionDetailViewModel?) {
        guard let model = self.model else { return }
        if let rating = model.attraction.rating {
            self.cosmos.rating = rating
        } else {
            self.cosmos.rating = 0
        }
        self.imageView.setImage(model.photo)
        self.nRatingsLabel.text = model.nRatings
        self.descriptionText.setText(searchTerms: model.wikipediaSearchTerms) {
            self.setNeedsLayout()
        }
        
        let latitude = model.attraction.location.latitude
        let longitude = model.attraction.location.longitude
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15)
        self.mapView.animate(to: camera)
        
        let marker = GMSMarker(position: model.attraction.location)
        marker.map = self.mapView
        
        if model.favorite {
            self.favoriteButton.image = AttractionDetailView.isFavoriteImage
        } else {
            self.favoriteButton.image = AttractionDetailView.isNotFavoriteImage
        }
        
        self.setNeedsLayout()
    }
}
