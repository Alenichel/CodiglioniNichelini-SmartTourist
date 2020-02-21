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

class CityResearchViewController: ViewController<CityResearchView> {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupInteraction() {}
    
    
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

