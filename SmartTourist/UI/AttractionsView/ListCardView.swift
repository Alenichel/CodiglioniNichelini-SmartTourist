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
    //var label = UILabel()
    var chooser = UISegmentedControl(items: ["TopPop","Nearest"])
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
        self.addSubview(self.handle)
        //self.addSubview(self.label)
        self.addSubview(self.chooser)
        
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
        
        self.addSubview(self.attractionListView)
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        //self.label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 8)
        //self.label.textAlignment = .center
        self.chooser.apportionsSegmentWidthsByContent = true
        self.chooser.setEnabled(true, forSegmentAt: 1)
        self.chooser.addTarget(self, action: #selector(self.segmentedValueChanged(_:)), for: .valueChanged)
        // ---> self.chooser.addTarget(self, action: "action:", for: .valueChanged)
        self.handle.tintColor = .secondaryLabel
        self.layer.cornerRadius = 30
        self.layer.shadowColor = UIColor.label.cgColor
        self.layer.shadowOpacity = UITraitCollection.current.userInterfaceStyle == .dark ? 0.25 : 0.75
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 10
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.handle.sizeToFit()
        //self.label.sizeToFit()
        self.handle.pin.top(20).left().right()
        //self.chooser.sizeToFit()
        self.chooser.pin.below(of: self.handle).marginTop(20).center()
        //self.label.pin.below(of: self.handle).marginTop(50).left(5%).right(5%)
        //self.label.pin.below(of: self.handle).marginTop(50).left(5%).right(5%)
        self.attractionListView.pin.below(of: self.chooser).left().right()
    }
    
    func update(oldModel: ListCardViewModel?) {
        if let model = self.model {
        //    self.label.text = model.currentPlace?.name ?? ""
            let attraction = AttractionCellViewModel(place: "Poli")
            self.attractionListView.source = SimpleSource<AttractionCellViewModel>([attraction])
        }
        self.setNeedsLayout()
    }
        
    @objc func segmentedValueChanged(_ sender:UISegmentedControl!)
    {
        print("Selected Segment Index is : \(sender.selectedSegmentIndex)")
    }

}

