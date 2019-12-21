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


struct AttractionDetailViewModel: ViewModelWithLocalState {
    let attraction: GPPlace
    var description: String
    let photo: GPPhoto
    let nRating: String
    let wikipediaSearchTerms: String
    let currentLocation: CLLocationCoordinate2D
    
    init?(state: AppState?, localState: AttractionDetailLocalState) {
        guard let state = state else { return nil }
        self.attraction = localState.attraction
        self.description = ""
        self.photo = (self.attraction.photos.first)!
        let n = localState.attraction.userRatingsTotal
        if n > 1000 { self.nRating = "\(Int(localState.attraction.userRatingsTotal / 1000))k" }
        else { self.nRating = "\(n)" }
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
    
    func setup() {
        self.addSubview(self.imageView)
        self.addSubview(self.containerView)
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
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.sizeToFit()
        self.imageView.pin.top(self.safeAreaInsets).bottom(50%).left().right()
        self.containerView.pin.horizontally().bottom().below(of: self.imageView)
        self.cosmos.sizeToFit()
        self.cosmos.pin.topLeft().marginHorizontal(20).marginTop(15)
        self.nRatingsLabel.sizeToFit()
        self.nRatingsLabel.pin.after(of: self.cosmos, aligned: .center).marginLeft(5)
        self.lineView.pin.below(of: self.cosmos).horizontally(5).height(1).marginTop(15)
        self.descriptionText.sizeToFit()
        self.descriptionText.pin.bottom().horizontally().below(of: self.lineView)
    }
    
    func update(oldModel: AttractionDetailViewModel?) {
        guard let model = self.model else { return }
        self.cosmos.rating = Double(model.attraction.rating)
        self.descriptionText.text = model.description
        self.imageView.setImage(model.photo)
        self.nRatingsLabel.text = model.nRating
        self.descriptionText.setText(coordinates: model.currentLocation, searchTerms: model.wikipediaSearchTerms)
        self.setNeedsLayout()
    }
}
