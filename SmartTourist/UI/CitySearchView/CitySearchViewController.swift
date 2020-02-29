//
//  CitySearchViewController.swift
//  SmartTourist
//
//  Created on 21/02/2020
//

import CoreLocation
import Tempura
import GoogleMaps
import GooglePlaces
import UIKit


class CitySearchViewController: ViewController<CitySearchView> {
    var resultsViewController: GMSAutocompleteResultsViewController!
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        
        self.resultsViewController = GMSAutocompleteResultsViewController()
        self.resultsViewController.autocompleteFilter = filter
        self.resultsViewController.delegate = self
        self.searchController = UISearchController(searchResultsController: self.resultsViewController)
        self.searchController.searchResultsUpdater = self.resultsViewController
        
        self.rootView.subView.addSubview(self.searchController.searchBar)
        self.rootView.addSubview(self.rootView.subView)
        self.searchController.delegate = self
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.showsCancelButton = true
        self.searchController.searchBar.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false

        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.searchController.isActive = true
    }
    
    override func setupInteraction() {}
}


// Handle the user's selection.
extension CitySearchViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        print("resultController")
        searchController.isActive = false
        self.dispatch(SetCurrentCity(city: place.name))
        self.dispatch(SetMapLocation(location: place.coordinate))
        self.dispatch(SetMapCentered(value: false))
        self.dispatch(Hide(animated: true))
    }

    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }

    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        print("Selecting")
    }

    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        print("Selected")
    }
}


extension CitySearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dispatch(Hide(animated: true))
    }
}


extension CitySearchViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
}


extension CitySearchViewController: RoutableWithConfiguration {
    var routeIdentifier: RouteElementIdentifier {
        Screen.citySearch.rawValue
    }
    
    var navigationConfiguration: [NavigationRequest : NavigationInstruction] {
        [
            .hide(Screen.citySearch): .dismissModally(behaviour: .hard)
        ]
    }
}
