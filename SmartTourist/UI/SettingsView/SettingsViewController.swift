//
//  SettingsViewController.swift
//  SmartTourist
//
//  Created on 14/03/2020
//

import UIKit
import Tempura


class SettingsViewController: ViewControllerWithLocalState<SettingsView> {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Settings"
    }
    
    override func setupInteraction() {
        self.rootView.notificationsCell.didToggle = { [unowned self] value in
            self.dispatch(SetNotificationsEnabled(value: value))
        }
        self.rootView.poorEntitiesCell.didToggle = { [unowned self] value in
            self.dispatch(SetPoorEntitiesEnabled(value: value)).then {
                self.dispatch(GetNearestPlaces(throttle: false))
            }
        }
        self.rootView.didTapSystemSettings = {
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsURL)
        }
        self.rootView.didTapDebug = { [unowned self] in
            self.localState.showDebug.toggle()
            self.dispatch(ClearPopularPlacesCache())
        }
        self.rootView.maxRadiusCell.didChange = { [unowned self] value in
            self.dispatch(SetMaxRadius(value: value))
        }
        self.rootView.maxNAttractionsCell.didChange = { [unowned self] value in
            self.dispatch(SetMaxNAttractions(value: Int(value)))
        }
    }
}


extension SettingsViewController: RoutableWithConfiguration {
    var routeIdentifier: RouteElementIdentifier {
        Screen.settings.rawValue
    }
    
    var navigationConfiguration: [NavigationRequest : NavigationInstruction] {
        [
            .hide(Screen.settings): .pop,
        ]
    }
}


struct SettingsViewLocalState: LocalState {
    var showDebug: Bool = false
}
