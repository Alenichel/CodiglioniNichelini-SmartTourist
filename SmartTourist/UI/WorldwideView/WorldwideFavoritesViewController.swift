//
//  WorldwideFavoritesViewController.swift
//  SmartTourist
//
//  Created on 14/03/2020
//

import UIKit
import Katana
import Tempura


class WorldwideFavoritesViewController: ViewController<WorldwideFavoritesView> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupInteraction() {}

}


extension WorldwideFavoritesViewController: RoutableWithConfiguration {
    var routeIdentifier: RouteElementIdentifier {
        Screen.worldwideFavorites.rawValue
    }
    
    var navigationConfiguration: [NavigationRequest : NavigationInstruction] {
        [
            .hide(Screen.worldwideFavorites): .pop
        ]
    }
}

