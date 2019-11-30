//
//  ListCardView.swift
//  SmartTourist
//
//  Created on 28/11/2019
//

import UIKit
import Tempura
import GooglePlaces
import PinLayout

struct ListCardViewModel: ViewModel, Equatable {
    let currentPlaces: GMSPlace?
    
    static func == (l: ListCardViewModel, r: ListCardViewModel) -> Bool {
        if l.currentPlaces == r.currentPlaces {return false}
        return true
    }
}


class ListCardView: UIView, ModellableView {
    var handle = UIButton(type: .system)
    var chooser = UISegmentedControl(items: ["Popular", "Nearest"])
    var scrollView = UIScrollView()
    var attractionListView: CollectionView<AttractionCell, SimpleSource<AttractionCellViewModel>>!
    
    
    // MARK: - Interactions
    var animate: Interaction?
    var didTapEditItem: ((String) -> ())?
    var didToggleItem: ((String) -> ())?
    
    func setup() {
        self.handle.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        self.handle.on(.touchUpInside) { button in
            self.animate?()
        }
        self.chooser.selectedSegmentIndex = 0
        self.scrollView.isPagingEnabled = true
        self.scrollView.isScrollEnabled = false
        let attractionsLayout = AttractionFlowLayout()
        self.attractionListView = CollectionView<AttractionCell, SimpleSource<AttractionCellViewModel>>(frame: .zero, layout: attractionsLayout)
        self.attractionListView.useDiffs = true
        self.attractionListView.configureInteractions = { [unowned self] cell, indexPath in
            cell.didTapEdit = { [unowned self] id in
                self.didTapEditItem?(id)
            }
            cell.didToggle = { [unowned self] itemID in
                self.didToggleItem?(itemID)
            }
        }
        self.scrollView.addSubview(self.attractionListView)
        self.addSubview(self.handle)
        self.addSubview(self.chooser)
        self.addSubview(self.scrollView)
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.chooser.apportionsSegmentWidthsByContent = true
        //self.chooser.setEnabled(true, forSegmentAt: 1)
        self.chooser.addTarget(self, action: #selector(self.segmentedValueChanged(_:)), for: .valueChanged)
        // ---> self.chooser.addTarget(self, action: "action:", for: .valueChanged)
        self.handle.tintColor = .secondaryLabel
        self.layer.cornerRadius = 30
        self.layer.shadowColor = UIColor.label.cgColor
        self.layer.shadowOpacity = UITraitCollection.current.userInterfaceStyle == .dark ? 0.25 : 0.75
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 10
        self.attractionListView.backgroundColor = .systemBackground
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.handle.sizeToFit()
        //self.label.sizeToFit()
        self.handle.pin.top(20).left().right()
        //self.chooser.sizeToFit()
        self.chooser.pin.below(of: self.handle).marginTop(20).hCenter()
        //self.label.pin.below(of: self.handle).marginTop(50).left(5%).right(5%)
        //self.label.pin.below(of: self.handle).marginTop(50).left(5%).right(5%)
        self.scrollView.pin.below(of: self.chooser).marginTop(10).left().right().bottom()
        self.attractionListView.frame = self.scrollView.frame.bounds
    }
    
    func update(oldModel: ListCardViewModel?) {
        if let model = self.model {
        //    self.label.text = model.currentPlace?.name ?? ""
            let attraction = AttractionCellViewModel(place: "Poli")
            self.attractionListView.source = SimpleSource<AttractionCellViewModel>([attraction])
        }
        self.setNeedsLayout()
    }
        
    @objc func segmentedValueChanged(_ sender:UISegmentedControl!) {
        print("Selected Segment Index is : \(sender.selectedSegmentIndex)")
    }

}

