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
    var description: String
    
    init(state: AppState?, localState: AttractionDetailLocalState) {
        self.attraction = localState.attraction
        self.description = "Lorem ipsum dolor sit amet, consectetur adipisici elit, sed eiusmod tempor incidunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquid ex ea commodi consequat. Quis aute iure reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint obcaecat cupiditat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    }
}


class AttractionDetailView: UIView, ViewControllerModellableView {
    var nameLabel = UILabel()
    var descriptionText = UITextView()
    var cosmos = CosmosView(frame: .zero)
    
    func setup() {
        self.addSubview(self.nameLabel)
        self.addSubview(self.cosmos)
        self.addSubview(self.descriptionText)
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        self.descriptionText.font = UIFont.systemFont(ofSize: 18)
        self.descriptionText.textAlignment = NSTextAlignment.justified
        self.cosmos.settings.updateOnTouch = false
        self.cosmos.settings.starSize = Double(UIFont.systemFontSize) + 12
        self.cosmos.settings.starMargin = 5
        self.cosmos.settings.fillMode = .precise
        self.cosmos.settings.filledImage = UIImage(systemName: "star.fill")?.maskWithColor(color: .orange)
        self.cosmos.settings.emptyImage = UIImage(systemName: "star")?.maskWithColor(color: .orange)
        self.cosmos.settings.disablePanGestures = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.nameLabel.sizeToFit()
        self.nameLabel.pin.hCenter().top(100)
        self.cosmos.sizeToFit()
        self.cosmos.pin.below(of: self.nameLabel, aligned: .center).margin(20)
        self.descriptionText.sizeToFit()
        self.descriptionText.pin.horizontally(20).bottom().top(180)
    }
    
    func update(oldModel: AttractionDetailViewModel?) {
        guard let model = self.model else { return }
        self.nameLabel.text = model.attraction.name
        self.cosmos.rating = Double(model.attraction.rating)
        self.descriptionText.text = model.description
        self.setNeedsLayout()
    }
}
