//
//  SFSafariViewController+RoutableWithConfiguration.swift
//  SmartTourist
//
//  Created on 16/04/2020
//

import Tempura
import SafariServices


extension SFSafariViewController: RoutableWithConfiguration {
    public var routeIdentifier: RouteElementIdentifier {
        Screen.safari.rawValue
    }
    
    public var navigationConfiguration: [NavigationRequest : NavigationInstruction] {
        [
            .hide(Screen.safari): .dismissModally(behaviour: .hard),
        ]
    }
}
