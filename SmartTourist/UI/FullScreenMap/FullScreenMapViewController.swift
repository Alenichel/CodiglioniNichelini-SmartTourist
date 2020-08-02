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
    override func setupInteraction() {
        self.rootView.didTapCloseButton = {[unowned self] in
            self.dispatch(Hide(animated: true))
        }
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
    let attraction: WDPlace
}
