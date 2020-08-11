//
//  SearchViewController.swift
//  SmartTourist
//
//  Created on 21/04/2020
//

import UIKit
import Tempura
import MapKit


class SearchViewController: ViewControllerWithLocalState<SearchView> {
    var searchCompleter = MKLocalSearchCompleter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Search"
        self.searchCompleter.delegate = self
        self.rootView.searchBar.delegate = self
        self.rootView.searchBar.becomeFirstResponder()
    }
    
    override func setupInteraction() {
        self.rootView.didSelectItem = { [unowned self] result in
            self.search(for: result)
        }
    }
    
    private func search(for suggestedCompletion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
        search(using: searchRequest)
    }
    
    private func search(using searchRequest: MKLocalSearch.Request) {
        let localSearch = MKLocalSearch(request: searchRequest)
        localSearch.start { [unowned self] (response, error) in
            guard error == nil else { return }
            guard let place = response?.mapItems.first else { return }
            self.dispatch(SetMapLocation(location: place.placemark.coordinate))
            self.dispatch(SetMapCentered(value: false))
            self.dispatch(GetCurrentCity(throttle: false))   // Also calls GetPopularPlaces
            self.dispatch(GetNearestPlaces(throttle: false))
            self.dispatch(SetNeedToMoveMap(value: true))
            self.dispatch(Hide(animated: true))
        }
    }
}


extension SearchViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.localState.results = completer.results
    }
}


extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dispatch(Hide(animated: true))
    }
}


extension SearchViewController: RoutableWithConfiguration {
    var routeIdentifier: RouteElementIdentifier {
        Screen.search.rawValue
    }
    
    var navigationConfiguration: [NavigationRequest : NavigationInstruction] {
        [
            .hide(Screen.search): .dismissModally(behaviour: .hard),
        ]
    }
}


struct SearchViewLocalState: LocalState {
    var results = [MKLocalSearchCompletion]()
}
