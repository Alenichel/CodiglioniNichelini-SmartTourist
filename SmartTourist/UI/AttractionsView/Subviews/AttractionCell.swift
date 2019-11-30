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


class AttractionCell: UICollectionViewCell, ConfigurableCell, SizeableCell {
    static var identifierForReuse: String = "AttractionCell"
    
    //MARK: - Subviews
    var attractionNameLabel: UILabel = UILabel()
    
    // MARK: Interactions
    var didToggle: ((String) -> ())?
    var didTapEdit: ((String) -> ())?
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
        self.style()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    func setup() {
        self.addSubview(self.attractionNameLabel)
    }
    
    //MARK: - Style
    func style() {
        self.backgroundColor = .white
    }
    
    //MARK: - Layout
    func update(oldModel: AttractionCellViewModel?) {
        guard let model = self.model else { return }
        self.attractionNameLabel.text = model.attractionName
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.attractionNameLabel.pin.top().bottom().left().right()
    }
    
    // MARK: - Layout
    static var paddingHeight: CGFloat = 10
    static var maxTextWidth: CGFloat = 0.80
    static func size(for model: AttractionCellViewModel) -> CGSize {
        let textWidth = UIScreen.main.bounds.width * AttractionCell.maxTextWidth
        let textHeight = model.attractionName.height(constraintedWidth: textWidth, font: UIFont.systemFont(ofSize: 17))
        return CGSize(width: UIScreen.main.bounds.width,
                      height: textHeight + 2 * AttractionCell.paddingHeight)
    }
}

// MARK: - DiffAware conformance
extension AttractionCellViewModel: DiffAware {
  var diffId: Int { return self.identifier.hashValue }
  
  static func compareContent(_ a: AttractionCellViewModel, _ b: AttractionCellViewModel) -> Bool {
    if a.attractionName != b.attractionName {return false}
    return true
  }
}
