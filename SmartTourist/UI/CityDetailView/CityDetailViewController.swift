//
//  CityDetailViewController.swift
//  SmartTourist
//
//  Created on 16/02/2020
//

import UIKit
import Katana
import Tempura


class CityDetailViewController: ViewController<CityDetailView> {
    var settingsButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingsButton.image = UIImage(systemName: "gear")
        self.settingsButton.onTap { button in
            self.dispatch(Show(Screen.settings, animated: true))
        }
        self.navigationItem.rightBarButtonItem = self.settingsButton
    }
    
    override func setupInteraction() {}
}


extension CityDetailViewController: RoutableWithConfiguration {
    var routeIdentifier: RouteElementIdentifier {
        Screen.cityDetail.rawValue
    }
    
    var navigationConfiguration: [NavigationRequest : NavigationInstruction] {
        [
            .hide(Screen.cityDetail): .pop,
            .show(Screen.settings): .push({ [unowned self] context in
                return SettingsViewController(store: self.store)
            })
        ]
    }
}
