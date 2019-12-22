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
    var description: String
    let photo: GPPhoto?
    let nRatings: String
    let wikipediaSearchTerms: String
    let currentLocation: CLLocationCoordinate2D
    
    init?(state: AppState?, localState: AttractionDetailLocalState) {
        guard let state = state else { return nil }
        self.attraction = localState.attraction
        self.description = ""
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
    }
}


class AttractionDetailView: UIView, ViewControllerModellableView {
    var descriptionText = UITextView()
    var nRatingsLabel = UILabel()
    var cosmos = CosmosView(frame: .zero)
    var containerView = UIView()
    var imageView = UIImageView()
    var lineView = UIView()
    var scrollView = UIScrollView()
    var mapView = GMSMapView()
    
    func setup() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.imageView)
        self.scrollView.addSubview(self.containerView)
        self.scrollView.addSubview(self.mapView)
        self.containerView.addSubview(self.descriptionText)
        self.containerView.addSubview(self.cosmos)
        self.containerView.addSubview(self.lineView)
        self.containerView.addSubview(self.nRatingsLabel)
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.imageView.contentMode = .scaleAspectFill
        self.descriptionText.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.15)
        self.descriptionText.textAlignment = NSTextAlignment.justified
        self.descriptionText.contentInset = UIEdgeInsets(top: 5, left: 20, bottom: 20, right: 20)
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
        self.mapView.settings.tiltGestures = false
        self.mapView.isUserInteractionEnabled = false
        self.mapView.loadCustomStyle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.pin.top(self.safeAreaInsets).bottom().horizontally()
        let h = self.frame.height + 300 - 50
        self.scrollView.contentSize = CGSize(width: self.frame.width, height: h)
        self.imageView.sizeToFit()
        self.imageView.pin.top().bottom(50%).left().right()
        self.containerView.pin.horizontally().bottom(10).below(of: self.imageView)
        self.cosmos.sizeToFit()
        self.cosmos.pin.topLeft().marginHorizontal(20).marginTop(15)
        self.nRatingsLabel.sizeToFit()
        self.nRatingsLabel.pin.after(of: self.cosmos, aligned: .center).marginLeft(5)
        self.lineView.pin.below(of: self.cosmos).horizontally(5).height(1).marginTop(15)
        self.descriptionText.sizeToFit()
        self.descriptionText.pin.bottom().horizontally().below(of: self.lineView)
        self.mapView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 300)
        self.mapView.pin.horizontally(20).below(of: containerView).marginTop(5)
 
    }
    
    func update(oldModel: AttractionDetailViewModel?) {
        guard let model = self.model else { return }
        if let rating = model.attraction.rating {
            self.cosmos.rating = rating
        } else {
            self.cosmos.rating = 0
        }
        self.descriptionText.text = model.description
        self.imageView.setImage(model.photo)
        self.nRatingsLabel.text = model.nRatings
        self.descriptionText.setText(coordinates: model.currentLocation, searchTerms: model.wikipediaSearchTerms)
        
        let latitude = (model.attraction.location.latitude)
        let longitude = (model.attraction.location.longitude)
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15)
        self.mapView.animate(to: camera)
        
        let marker = GMSMarker(position: model.attraction.location)
        marker.map = self.mapView
        
        self.setNeedsLayout()
    }
}
