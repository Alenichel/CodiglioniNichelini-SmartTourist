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

public protocol SizeableCell: ModellableView {
  static func size(for model: VM) -> CGSize
}

// MARK: View Model
struct AttractionCellViewModel: ViewModel {
    var attractionName: String
    var identifier: String
    
    static func == (l: AttractionCellViewModel, r: AttractionCellViewModel) -> Bool {
        if l.identifier != r.identifier {return false}
        if l.attractionName != r.attractionName {return false}
        return true
    }
    
    init(place: String) {
        self.identifier = "1234"
        self.attractionName = place
    }
    
}


// MARK: - View
class AttractionCell: UICollectionViewCell, ConfigurableCell, SizeableCell {
    static var identifierForReuse: String = "AttractionCell"
    static var font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 8)
    
    //MARK: Subviews
    var label = UILabel()
    var image = UIImageView(image: UIImage(systemName: "chevron.right"))
    
    // MARK: Interactions
    var didToggle: ((String) -> ())?
    var didTapEdit: ((String) -> ())?
    
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
        self.addSubview(self.label)
        self.addSubview(self.image)
    }
    
    //MARK: Style
    func style() {
        self.backgroundColor = .white
        self.label.font = AttractionCell.font
        self.image.tintColor = .secondaryLabel
    }
    
    // MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.pin.top().bottom().left().right().margin(15)
        self.image.pin.vCenter(to: self.label.edge.vCenter).right(15)
    }
    
    static var paddingHeight: CGFloat = 10
    static var maxTextWidth: CGFloat = 0.80
    static func size(for model: AttractionCellViewModel) -> CGSize {
        let textWidth = UIScreen.main.bounds.width * AttractionCell.maxTextWidth
        let textHeight = model.attractionName.height(constraintedWidth: textWidth, font: font)
        return CGSize(width: UIScreen.main.bounds.width,
                      height: textHeight + 2 * AttractionCell.paddingHeight)
    }
    
    //MARK: Update
    func update(oldModel: AttractionCellViewModel?) {
        guard let model = self.model else { return }
        self.label.text = model.attractionName
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
