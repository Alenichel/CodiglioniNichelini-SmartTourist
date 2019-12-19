//
//  AttractionCell.swift
//  SmartTourist
//
//  Created on 30/11/2019
//

import Foundation
import UIKit
import Tempura
import PinLayout
import DeepDiff
import GooglePlaces
import Cosmos

public protocol SizeableCell: ModellableView {
  static func size(for model: VM) -> CGSize
}

// MARK: View Model
struct AttractionCellViewModel: ViewModel {
    let attractionName: String
    let identifier: String
    let rating: Double
    let currentLocation: CLLocationCoordinate2D
    let distance: Int
    //let place: GMSPlace // what version to keep ?
    
    static func == (l: AttractionCellViewModel, r: AttractionCellViewModel) -> Bool {
        if l.identifier != r.identifier {return false}
        if l.attractionName != r.attractionName {return false}
        return true
    }
    
    init(place: GMSPlace, currentLocation: CLLocationCoordinate2D?) {
        //self.place = place
        self.identifier = place.placeID ?? UUID().description
        self.attractionName = place.name ?? "NoName"
        self.rating = Double(place.rating)
        self.currentLocation = currentLocation ?? CLLocationCoordinate2D()
        let current = CLLocation(latitude: self.currentLocation.latitude, longitude: self.currentLocation.longitude)
        let target = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        self.distance = Int(current.distance(from: target).rounded())
    }
    
    init(place: GPPlace, currentLocation: CLLocationCoordinate2D) {
        self.identifier = place.placeID ?? UUID().description
        self.attractionName = place.name ?? "NoName"
        self.rating = place.rating
        self.currentLocation = currentLocation
        let current = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        let target = CLLocation(latitude: place.geometry.location.latitude, longitude: place.geometry.location.longitude)
        self.distance = Int(current.distance(from: target).rounded())
    }
    
}


// MARK: - View
class AttractionCell: UICollectionViewCell, ConfigurableCell, SizeableCell {
    static var identifierForReuse: String = "AttractionCell"
    
    //MARK: Subviews
    var nameLabel = UILabel()
    var image = UIImageView(image: UIImage(systemName: "chevron.right"))
    var cosmos = CosmosView(frame: .zero)
    var distanceLabel = UILabel()
    
    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
        self.style()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    func setup() {
        self.distanceLabel.textAlignment = .right
        self.addSubview(self.nameLabel)
        self.addSubview(self.image)
        self.addSubview(self.cosmos)
        self.addSubview(self.distanceLabel)
    }
    
    //MARK: Style
    func style() {
        self.backgroundColor = .systemBackground
        self.nameLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 4)
        self.distanceLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        self.image.tintColor = .secondaryLabel
        self.cosmos.settings.updateOnTouch = false
        self.cosmos.settings.starSize = Double(UIFont.systemFontSize)
        self.cosmos.settings.starMargin = 5
        self.cosmos.settings.fillMode = .precise
        self.cosmos.settings.filledImage = UIImage(systemName: "star.fill")?.maskWithColor(color: .label)
        self.cosmos.settings.emptyImage = UIImage(systemName: "star")?.maskWithColor(color: .label)
        self.cosmos.settings.disablePanGestures = true
    }
    
    // MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        self.nameLabel.sizeToFit()
        self.image.sizeToFit()
        self.cosmos.sizeToFit()
        self.distanceLabel.sizeToFit()
        self.nameLabel.pin.top(10).bottom(50%).left(15).right(90)
        self.cosmos.pin.top(55%).bottom().left(15)
        self.image.pin.vCenter().right(15)
        self.distanceLabel.pin.vCenter().right(35)
    }

    static var paddingHeight: CGFloat = 10
    static var maxTextWidth: CGFloat = 0.80
    static func size(for model: AttractionCellViewModel) -> CGSize {
        //let textWidth = UIScreen.main.bounds.width * AttractionCell.maxTextWidth
        //let textHeight = model.attractionName.height(constraintedWidth: textWidth, font: font)
        let textHeight: CGFloat = 42
        return CGSize(width: UIScreen.main.bounds.width,
                      height: textHeight + 2 * AttractionCell.paddingHeight)
    }
    
    //MARK: Update
    func update(oldModel: AttractionCellViewModel?) {
        guard let model = self.model else {return}
        self.nameLabel.text = model.attractionName
        self.cosmos.rating = Double(model.rating)
        self.distanceLabel.text = "\(model.distance) m"
        self.setNeedsLayout()
    }
}


// MARK: - DiffAware conformance
extension AttractionCellViewModel: DiffAware {
    var diffId: Int { return self.identifier.hashValue }

    static func compareContent(_ a: AttractionCellViewModel, _ b: AttractionCellViewModel) -> Bool {
        return a.identifier == b.identifier
    }
}
