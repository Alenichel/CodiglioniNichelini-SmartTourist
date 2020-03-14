//
//  ListCardView.swift
//  SmartTourist
//
//  Created on 28/11/2019
//

import UIKit
import Tempura
import PinLayout
import CoreLocation


struct ListCardViewModel: ViewModel {
    let currentLocation: CLLocationCoordinate2D?
    let places: [GPPlace]
    let favorites: [GPPlace]
    let selectedSegmentedIndex: SelectedPlaceList
}


class ListCardView: UIView, ModellableView {
    var handle = UIImageView(image: UIImage(systemName: "line.horizontal.3"))
    var chooser = UISegmentedControl(items: ["Nearest", "Popular", "Favorites"])
    var scrollView = UIScrollView()
    var attractionListView: CollectionView<AttractionCell, SimpleSource<AttractionCellViewModel>>!
    var emptyLabel = UILabel()
    var mapButton = UIButton()
    
    // MARK: - Interactions
    var didTapItem: ((GPPlace) -> Void)?
    var didChangeSegmentedValue: ((Int) -> Void)?
        
    func setup() {
        self.chooser.selectedSegmentIndex = 0
        self.chooser.on(.valueChanged) { control in
            self.didChangeSegmentedValue?(control.selectedSegmentIndex)
        }
        self.scrollView.isPagingEnabled = true
        self.scrollView.isScrollEnabled = false
        let attractionsLayout = AttractionFlowLayout()
        self.attractionListView = CollectionView<AttractionCell, SimpleSource<AttractionCellViewModel>>(frame: .zero, layout: attractionsLayout)
        self.attractionListView.useDiffs = true
        self.attractionListView.didSelectItem = { [unowned self] indexPath in
            guard let model = self.model,
                let cell = self.attractionListView.cellForItem(at: indexPath) as? AttractionCell,
                let cellPlaceID = cell.model?.identifier,
                let cellPlace = model.places.first(where: {$0.placeID == cellPlaceID}) else { return }
            self.didTapItem?(cellPlace)
        }
        self.attractionListView.didHighlightItem = { [unowned self] indexPath in
            guard let cell = self.attractionListView.cellForItem(at: indexPath) else { return }
            cell.backgroundColor = .secondarySystemBackground
        }
        self.attractionListView.didUnhighlightItem = { [unowned self] indexPath in
            guard let cell = self.attractionListView.cellForItem(at: indexPath) else { return }
            UIView.animate(withDuration: 0.5) {
                cell.backgroundColor = .systemBackground
            }
        }
        self.emptyLabel.text = "No attraction to show"
        self.scrollView.addSubview(self.attractionListView)
        self.addSubview(self.handle)
        self.addSubview(self.chooser)
        self.addSubview(self.scrollView)
        self.addSubview(self.emptyLabel)
        self.addSubview(self.mapButton)
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.chooser.apportionsSegmentWidthsByContent = true
        self.handle.tintColor = .secondaryLabel
        self.layer.cornerRadius = 30
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = UITraitCollection.current.userInterfaceStyle == .dark ? 1 : 0.75
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 10
        self.attractionListView.backgroundColor = .systemBackground
        self.scrollView.backgroundColor = .systemBackground
        self.emptyLabel.textColor = .secondaryLabel
        self.emptyLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 0.9)
        self.mapButton.setImage(UIImage(systemName: "map"), for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.handle.sizeToFit()
        self.emptyLabel.sizeToFit()
        self.handle.pin.topCenter(20)
        self.chooser.pin.below(of: self.handle).marginTop(20).hCenter()
        self.mapButton.pin.after(of: self.chooser, aligned: .center).size(50).marginLeft(10)
        self.scrollView.pin.below(of: self.chooser).marginTop(15).left().right().bottom()
        self.attractionListView.frame = self.scrollView.frame.bounds
        self.emptyLabel.pin.below(of: self.chooser, aligned: .center).marginTop(30)
    }
    
    func update(oldModel: ListCardViewModel?) {
        guard let model = self.model, let currentLocation = model.currentLocation else { return }
        let attractions = model.places.map { AttractionCellViewModel(place: $0, currentLocation: currentLocation, favorite: model.favorites.contains($0), isInFavoriteTab: model.selectedSegmentedIndex == .favorites) }
        self.attractionListView.source = SimpleSource<AttractionCellViewModel>(attractions)
        UIView.animate(withDuration: 0.3) {
            self.emptyLabel.layer.opacity = Float(attractions.isEmpty ? 1.0 : 0.0)
        }
        if model.selectedSegmentedIndex == .favorites {
            self.mapButton.isHidden = false
        } else {
            self.mapButton.isHidden = true
        }
        self.setNeedsLayout()
    }
}
