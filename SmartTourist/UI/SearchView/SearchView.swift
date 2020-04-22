//
//  SearchView.swift
//  SmartTourist
//
//  Created on 21/04/2020
//

import UIKit
import Tempura
import MapKit


struct SearchViewModel: ViewModelWithLocalState {
    let results: [MKLocalSearchCompletion]
    
    init?(state: AppState?, localState: SearchViewLocalState) {
        self.results = localState.results
    }
}


class SearchView: UIView, ViewControllerModellableView {
    var collectionView: CollectionView<SearchResultCell, SimpleSource<SearchResultCellViewModel>>!
    var searchBar = UISearchBar()
    var blurEffect = UIVisualEffectView(effect: UIBlurEffect(style: UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light))
    
    var didSelectItem: ((MKLocalSearchCompletion) -> Void)?
    
    func setup() {
        let layout = SearchFlowLayout()
        self.collectionView = CollectionView<SearchResultCell, SimpleSource<SearchResultCellViewModel>>(frame: .zero, layout: layout)
        self.collectionView.useDiffs = true
        self.collectionView.didSelectItem = { [unowned self] indexPath in
            guard let model = self.model,
                let cell = self.collectionView.cellForItem(at: indexPath) as? SearchResultCell,
                let cellId = cell.model?.diffId,
                let result = model.results.first(where: {
                    let id = $0.title.hashValue ^ $0.subtitle.hashValue
                    return id == cellId
                }) else { return }
            print(result.title)
            self.didSelectItem?(result)
        }
        self.collectionView.didHighlightItem = { [unowned self] indexPath in
            guard let cell = self.collectionView.cellForItem(at: indexPath) else { return }
            cell.backgroundColor = .secondarySystemBackground
        }
        self.collectionView.didUnhighlightItem = { [unowned self] indexPath in
            guard let cell = self.collectionView.cellForItem(at: indexPath) else { return }
            UIView.animate(withDuration: 0.5) {
                cell.backgroundColor = .clear
            }
        }
        self.addSubview(self.blurEffect)
        self.addSubview(self.searchBar)
        self.addSubview(self.collectionView)
    }
    
    func style() {
        self.backgroundColor = .clear
        self.collectionView.backgroundColor = .clear
        self.searchBar.showsCancelButton = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.blurEffect.pin.top(self.safeAreaInsets.top).horizontally().bottom()
        self.searchBar.pin.top(self.safeAreaInsets.top).horizontally().sizeToFit()
        self.collectionView.pin.below(of: self.searchBar).horizontally().bottom()
    }
    
    func update(oldModel: SearchViewModel?) {
        guard let model = self.model else { return }
        let results = model.results.map { SearchResultCellViewModel(completion: $0)}
        self.collectionView.source = SimpleSource<SearchResultCellViewModel>(results)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.blurEffect.effect = UIBlurEffect(style: UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light)
    }
}
