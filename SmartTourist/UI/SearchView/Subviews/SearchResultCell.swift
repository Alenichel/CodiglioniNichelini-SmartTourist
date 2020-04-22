//
//  SearchResultCell.swift
//  SmartTourist
//
//  Created on 21/04/2020
//

import UIKit
import Tempura
import PinLayout
import DeepDiff
import MapKit
import MarqueeLabel


// MARK: View Model
struct SearchResultCellViewModel: ViewModel, Equatable {
    let title: String
    let subtitle: String
    let titleHighlightRanges: [NSValue]
    let subtitleHighlightRanges: [NSValue]
    
    init(completion: MKLocalSearchCompletion) {
        self.title = completion.title
        self.subtitle = completion.subtitle
        self.titleHighlightRanges = completion.titleHighlightRanges
        self.subtitleHighlightRanges = completion.subtitleHighlightRanges
    }
}


extension SearchResultCellViewModel: DiffAware {
    var diffId: Int {
        return self.title.hashValue ^ self.subtitle.hashValue
    }
    
    static func compareContent(_ a: SearchResultCellViewModel, _ b: SearchResultCellViewModel) -> Bool {
        return a == b
    }
}


// MARK: - View
class SearchResultCell: UICollectionViewCell, ConfigurableCell, SizeableCell {
    static let identifierForReuse: String = "SearchResultCell"
    static let titleFontSize: CGFloat = UIFont.systemFontSize * 1.25
    static let subtitleFontSize: CGFloat = UIFont.systemFontSize
    
    //MARK: Subviews
    var titleLabel = MarqueeLabel()
    var subtitleLabel = MarqueeLabel()
    var lineView = UIView()
    
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
        self.titleLabel.trailingBuffer = 50
        self.subtitleLabel.trailingBuffer = 50
        self.addSubview(self.titleLabel)
        self.addSubview(self.subtitleLabel)
        self.addSubview(self.lineView)
    }
    
    //MARK: Style
    func style() {
        self.backgroundColor = .clear
        self.titleLabel.font = UIFont.systemFont(ofSize: SearchResultCell.titleFontSize)
        self.subtitleLabel.font = UIFont.systemFont(ofSize: SearchResultCell.subtitleFontSize)
        self.lineView.backgroundColor = .secondaryLabel
    }
    
    // MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel.sizeToFit()
        self.subtitleLabel.sizeToFit()
        self.titleLabel.pin.top(5).left(10).right(10)
        self.subtitleLabel.pin.below(of: self.titleLabel).left(10).right(10)
        self.lineView.pin.below(of: self.subtitleLabel).left(20).right().height(1).marginTop(5)
    }

    static var paddingHeight: CGFloat = 5
    static var maxTextWidth: CGFloat = 0.80
    static func size(for model: SearchResultCellViewModel) -> CGSize {
        //let textWidth = UIScreen.main.bounds.width * AttractionCell.maxTextWidth
        //let textHeight = model.attractionName.height(constraintedWidth: textWidth, font: font)
        let textHeight: CGFloat = 42
        return CGSize(width: UIScreen.main.bounds.width,
                      height: textHeight + 2 * SearchResultCell.paddingHeight)
    }
    
    //MARK: Update
    func update(oldModel: SearchResultCellViewModel?) {
        guard let model = self.model else {return}
        self.titleLabel.attributedText = self.createHighlightedString(text: model.title, rangeValues: model.titleHighlightRanges, fontSize: SearchResultCell.titleFontSize)
        self.subtitleLabel.attributedText = self.createHighlightedString(text: model.subtitle, rangeValues: model.subtitleHighlightRanges, fontSize: SearchResultCell.subtitleFontSize)
        self.setNeedsLayout()
    }
    
    private func createHighlightedString(text: String, rangeValues: [NSValue], fontSize: CGFloat) -> NSAttributedString {
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize, weight: .bold)]
        let highlightedString = NSMutableAttributedString(string: text)
        let ranges = rangeValues.map { $0.rangeValue }
        ranges.forEach { highlightedString.addAttributes(attributes, range: $0) }
        return highlightedString
    }
}
