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
    var settingsButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dispatch(GetCityDetails())
        self.settingsButton.image = UIImage(systemName: "gear")
        self.settingsButton.onTap { button in
            self.dispatch(Show(Screen.settings, animated: true))
        }
        self.navigationItem.rightBarButtonItem = self.settingsButton
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
            .show(Screen.settings): .push { [unowned self] context in
                SettingsViewController(store: self.store, localState: SettingsViewLocalState())
            },
        ]
    }
}


struct CityDetailLocalState: LocalState {
    var allLoaded: Bool = false
}
