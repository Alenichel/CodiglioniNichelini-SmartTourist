//
//  AttractionsViewController.swift
//  SmartTourist
//
//  Created on 25/11/2019
//

import UIKit
import Tempura


class AttractionsViewController: ViewController<AttractionsView> {
    override func viewDidLoad() {
        self.dispatch(Show(ScreenID.welcome))
    }
    
    override func setupInteraction() {
        
    }
}


extension AttractionsViewController: RoutableWithConfiguration {
    var routeIdentifier: RouteElementIdentifier {
        ScreenID.attractions.rawValue
    }
    
    var navigationConfiguration: [NavigationRequest : NavigationInstruction] {
        [
            .show(ScreenID.welcome): .presentModally({ [unowned self] context in
                let welcomeViewController = WelcomeViewController(store: self.store, localState: WelcomeLocalState())
                welcomeViewController.modalPresentationStyle = .overCurrentContext
                return welcomeViewController
            })
        ]
    }
}
