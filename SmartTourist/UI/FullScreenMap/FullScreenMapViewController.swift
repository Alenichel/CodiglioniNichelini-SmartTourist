//
//  FullScreenMapViewController.swift
//  SmartTourist
//
//  Created on 02/08/2020
//

import UIKit
import Katana
import Tempura


class FullScreenMapViewController: ViewControllerWithLocalState<FullScreenMapView> {
    override func viewDidLoad() {
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: nil, action: nil)
        closeButton.onTap { [unowned self] button in
            self.dispatch(Hide(Screen.fullScreenMap, animated: true))
        }
        self.navigationItem.rightBarButtonItem = closeButton
    }
}


extension FullScreenMapViewController: RoutableWithConfiguration {
    var routeIdentifier: RouteElementIdentifier {
        Screen.fullScreenMap.rawValue
    }
    
    var navigationConfiguration: [NavigationRequest : NavigationInstruction] {
        [
            .hide(Screen.fullScreenMap): .dismissModally(behaviour: .hard),
        ]
    }
}


struct FullScreenMapLocalState: LocalState {
    let attractions: [WDPlace]
}
