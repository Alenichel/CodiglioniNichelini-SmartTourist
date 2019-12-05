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
import GooglePlaces
import Cosmos

struct AttractionDetailViewModel: ViewModelWithLocalState {
    let attraction: GMSPlace
    let description: String
    let isOpen: String
    let mainPhotoMetadata: GMSPlacePhotoMetadata
    let nRating: String
    
    init?(state: AppState?, localState: AttractionDetailLocalState) {
        guard let state = state else { return nil }
        self.attraction = localState.attraction
        self.description = "Lorem ipsum dolor sit amet, consectetur adipisici elit, sed eiusmod tempor incidunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquid ex ea commodi consequat. Quis aute iure reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint obcaecat cupiditat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        self.mainPhotoMetadata = (self.attraction.photos?.first)!
        let openStatus = localState.attraction.isOpen()
        self.isOpen = openStatus == .open ? "Open" : (openStatus == .closed ? "Closed": "")
        let n = localState.attraction.userRatingsTotal
        if n > 1000 { self.nRating = "\(Int(localState.attraction.userRatingsTotal / 1000))k" }
        else { self.nRating = "\(n)" }
        //WikipediaAPI.shared.search(title: self.attraction.name!)
    }
}


class AttractionDetailView: UIView, ViewControllerModellableView {
    var descriptionText = UITextView()
    var openLabel = UILabel()
    var nRatingsLabel = UILabel()
    var cosmos = CosmosView(frame: .zero)
    var scrollView = UIScrollView()
    var imageView = UIImageView()
    var lineView = UIView()
    
    func setup() {
        self.addSubview(self.imageView)
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.descriptionText)
        self.scrollView.addSubview(self.cosmos)
        self.scrollView.addSubview(self.openLabel)
        self.scrollView.addSubview(self.lineView)
        self.scrollView.addSubview(self.nRatingsLabel)
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.imageView.contentMode = .scaleAspectFill
        self.descriptionText.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.3)
        self.descriptionText.textAlignment = NSTextAlignment.justified
        self.cosmos.settings.updateOnTouch = false
        self.cosmos.settings.starSize = Double(UIFont.systemFontSize) * 1.1
        self.cosmos.settings.starMargin = 5
        self.cosmos.settings.fillMode = .precise
        self.cosmos.settings.filledImage = UIImage(systemName: "star.fill")?.maskWithColor(color: .orange)
        self.cosmos.settings.emptyImage = UIImage(systemName: "star")?.maskWithColor(color: .orange)
        self.cosmos.settings.disablePanGestures = true
        self.scrollView.backgroundColor = .systemBackground
        self.scrollView.alwaysBounceVertical = true
        self.openLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.3)
        self.nRatingsLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .bold)
        self.nRatingsLabel.textColor = .systemOrange
        self.lineView.backgroundColor = .secondaryLabel
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.sizeToFit()
        self.imageView.pin.top(self.safeAreaInsets).bottom(50%).left().right()
        self.scrollView.pin.horizontally().bottom().below(of: self.imageView)
        self.cosmos.sizeToFit()
        self.cosmos.pin.topLeft().marginHorizontal(20).marginTop(15)
        //self.openLabel.sizeToFit()
        //self.openLabel.pin.after(of: self.cosmos, aligned: .center).marginLeft(20)
        self.nRatingsLabel.sizeToFit()
        self.nRatingsLabel.pin.after(of: self.cosmos, aligned: .center).marginLeft(5)
        self.lineView.pin.below(of: self.cosmos).horizontally(5).height(1).marginTop(15)
        self.descriptionText.sizeToFit()
        self.descriptionText.pin.bottom(20).horizontally(20).below(of: self.lineView)
    }
    
    func update(oldModel: AttractionDetailViewModel?) {
        guard let model = self.model else { return }
        self.cosmos.rating = Double(model.attraction.rating)
        self.descriptionText.text = model.description
        self.imageView.setImage(metadata: model.mainPhotoMetadata)
        self.openLabel.text = model.isOpen
        if self.openLabel.text == "Open" {
            self.openLabel.textColor = .systemGreen
        } else { self.openLabel.textColor = .systemRed}
        self.nRatingsLabel.text = model.nRating
        self.setNeedsLayout()
    }
}
