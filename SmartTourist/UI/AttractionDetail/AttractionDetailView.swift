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
    let image: UIImage?
    //let mainPhotoMetadata: GMSPlacePhotoMetadata
    
    init(state: AppState?, localState: AttractionDetailLocalState) {
        self.attraction = localState.attraction
        self.description = "Lorem ipsum dolor sit amet, consectetur adipisici elit, sed eiusmod tempor incidunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquid ex ea commodi consequat. Quis aute iure reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint obcaecat cupiditat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        self.image = localState.attractionImage
    }
}


class AttractionDetailView: UIView, ViewControllerModellableView {
    var descriptionText = UITextView()
    var cosmos = CosmosView(frame: .zero)
    var scrollView = UIScrollView()
    var imageView = UIImageView()
    
    func setup() {
        self.addSubview(self.imageView)
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.descriptionText)
        self.addSubview(self.cosmos)
    }
    
    func style() {
        self.backgroundColor = .systemBackground
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.cosmos.sizeToFit()
        self.cosmos.pin.below(of: self.imageView, aligned: .center).margin(20)
        self.descriptionText.sizeToFit()
        self.scrollView.pin.horizontally().bottom().top(280)
        self.descriptionText.pin.all(20)
        self.imageView.sizeToFit()
        self.imageView.pin.top(self.safeAreaInsets).bottom(50%).left().right()
    }
    
    func update(oldModel: AttractionDetailViewModel?) {
        guard let model = self.model else { return }
        SceneDelegate.navigationController.navigationBar.topItem?.title = model.attraction.name
        self.cosmos.rating = Double(model.attraction.rating)
        self.descriptionText.text = model.description
        self.imageView.image = model.image
        self.setNeedsLayout()
    }
}
