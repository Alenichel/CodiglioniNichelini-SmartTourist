//
//  CityResearchViewController.swift
//  SmartTourist
//
//  Created on 21/02/2020
//

import Foundation
import CoreLocation
import Tempura
import GoogleMaps
import GooglePlaces
import UIKit

class CityResearchViewController: ViewController<CityResearchView> {
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.autocompleteFilter = filter
        resultsViewController?.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        
        self.rootView.subView.addSubview((searchController?.searchBar)!)
        self.rootView.addSubview(self.rootView.subView)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false

        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
    }
    
    override func setupInteraction() {}
    
    
}

// Handle the user's selection.
extension CityResearchViewController: GMSAutocompleteResultsViewControllerDelegate {
  func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                         didAutocompleteWith place: GMSPlace) {
    searchController?.isActive = false
    self.dispatch(SetSelectedCity(selectedCity: place.name))
    self.dispatch(Hide(Screen.citySelection))
    }

  func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                         didFailAutocompleteWithError error: Error){
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

extension CityResearchViewController: RoutableWithConfiguration {
    
    var routeIdentifier: RouteElementIdentifier {
        Screen.citySelection.rawValue
    }
    
    var navigationConfiguration: [NavigationRequest : NavigationInstruction] {
        [
            .hide(Screen.citySelection): .pop
        ]
    }
}

struct CityResearchLocalState: LocalState {
    
}

