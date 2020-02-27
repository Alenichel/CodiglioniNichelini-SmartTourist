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
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self as? GMSAutocompleteResultsViewControllerDelegate
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        let subView = UIView(frame: CGRect(x: 0, y: 65.0, width: 350.0, height: 45.0))
        subView.addSubview((searchController?.searchBar)!)
        self.rootView.addSubview(subView)
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
    // Do something with the selected place.
    print("Place name: \(String(describing: place.name))")
  }

  func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                         didFailAutocompleteWithError error: Error){
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
    print("True")
  }

  func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
    print("False: -> QYUUUU")
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

