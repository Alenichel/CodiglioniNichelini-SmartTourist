//
//  CityDetailViewController.swift
//  SmartTourist
//
//  Created on 16/02/2020
//

import UIKit
import Katana
import Tempura


class CityDetailViewController: ViewControllerWithLocalState<CityDetailView> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dispatch(GetCityDetails())
    }
    
    override func setupInteraction() {
        /*self.rootView.didLoadEverything = { [unowned self ] in
            self.localState.allLoaded = true
        }*/
    }
}


extension CityDetailViewController: RoutableWithConfiguration {
    var routeIdentifier: RouteElementIdentifier {
        Screen.cityDetail.rawValue
    }
    
    var navigationConfiguration: [NavigationRequest : NavigationInstruction] {
        [
            .hide(Screen.cityDetail): .pop,
        ]
    }
}


struct CityDetailLocalState: LocalState {
    var allLoaded: Bool = false
}
