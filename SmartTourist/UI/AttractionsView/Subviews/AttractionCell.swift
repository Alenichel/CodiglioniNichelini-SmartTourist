//
//  AttractionCell.swift
//  SmartTourist
//
//  Created on 30/11/2019
//

import UIKit
import Tempura
import PinLayout
import DeepDiff
import Cosmos
import CoreLocation


public protocol SizeableCell: ModellableView {
    static func size(for model: VM) -> CGSize
}


// MARK: View Model
struct AttractionCellViewModel: ViewModel {
    let attractionName: String
    let attractionCityName: String
    let identifier: String
    let rating: Double
    let currentLocation: CLLocationCoordinate2D
    let distance: Int
    let favorite: Bool
    let isInFavouriteTab: SelectedPlaceList
    
    static func == (l: AttractionCellViewModel, r: AttractionCellViewModel) -> Bool {
        return l.identifier == r.identifier
    }
    
    init(place: GPPlace, currentLocation: CLLocationCoordinate2D, favorite: Bool, isInFavouriteTab: SelectedPlaceList) {
        self.identifier = place.placeID
        self.attractionName = place.name
        self.attractionCityName = place.city ?? "Unknown city"
        if let rating = place.rating {
            self.rating = rating
        } else {
            self.rating = 0
        }
        self.currentLocation = currentLocation
        let current = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        let target = CLLocation(latitude: place.location.latitude, longitude: place.location.longitude)
        self.distance = Int(current.distance(from: target).rounded())
        self.favorite = favorite
        self.isInFavouriteTab = isInFavouriteTab
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
    var favoriteImage = UIImageView(image: UIImage(systemName: "heart.fill"))
    var cityNameLabel = UILabel()
    
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
        self.addSubview(self.favoriteImage)
        self.addSubview(self.cityNameLabel)
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
        self.favoriteImage.tintColor = .systemRed
        self.cityNameLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize - 3)
        self.cityNameLabel.textAlignment = .right
        self.cityNameLabel.textColor = .systemGray
    }
    
    // MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        self.nameLabel.sizeToFit()
        self.image.sizeToFit()
        self.cosmos.sizeToFit()
        self.distanceLabel.sizeToFit()
        //self.favoriteImage.sizeToFit()
        self.nameLabel.pin.top(10).bottom(50%).left(15).right(90)
        self.cosmos.pin.top(55%).bottom().left(15)
        self.image.pin.vCenter().right(15)
        self.distanceLabel.pin.vCenter().right(35)
        self.favoriteImage.pin.right(of: cosmos, aligned: .top).marginLeft(10).size(CGSize(width: Double(UIFont.systemFontSize) * 1.2, height: Double(UIFont.systemFontSize)))
        self.cityNameLabel.pin.after(of: self.favoriteImage, aligned: .center).size(200).marginLeft(10)
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
        if model.isInFavouriteTab == .favorites {
            self.cityNameLabel.text = model.attractionCityName
        }
        if model.favorite {
            self.favoriteImage.alpha = 1
        } else {
            self.favoriteImage.alpha = 0
        }
        self.cosmos.rating = Double(model.rating)
        if model.distance < 1000 {
            self.distanceLabel.text = "\(model.distance) m"
        }
        else if model.distance < 10000 {
            let km = model.distance / 1000
            let decimal = model.distance % 1000
            self.distanceLabel.text = "\(km).\(decimal) km"
        }
        else {
            self.distanceLabel.text = "\(model.distance / 1000) km"
        }
        self.setNeedsLayout()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.cosmos.settings.filledImage = UIImage(systemName: "star.fill")?.maskWithColor(color: .label)
        self.cosmos.settings.emptyImage = UIImage(systemName: "star")?.maskWithColor(color: .label)
    }
}


// MARK: - DiffAware conformance
extension AttractionCellViewModel: DiffAware {
    var diffId: Int { return self.identifier.hashValue }

    static func compareContent(_ a: AttractionCellViewModel, _ b: AttractionCellViewModel) -> Bool {
        return a.identifier == b.identifier && a.favorite == b.favorite && a.isInFavouriteTab == b.isInFavouriteTab
    }
}
