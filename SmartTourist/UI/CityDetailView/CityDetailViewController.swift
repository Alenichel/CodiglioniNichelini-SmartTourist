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
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupInteraction() {
        self.rootView.didTapChangeCityButton = {[unowned self] in
            self.dispatch(Show(Screen.citySelection, animated: true, context: nil))
        }
        
    }
}


extension CityDetailViewController: RoutableWithConfiguration {
    var routeIdentifier: RouteElementIdentifier {
        Screen.cityDetail.rawValue
    }
    
    var navigationConfiguration: [NavigationRequest : NavigationInstruction] {
        [
            .hide(Screen.cityDetail): .pop,
            
            .show(Screen.citySelection): .push({ [unowned self] context in
                let vc = CityResearchViewController(store: self.store)
                return vc
            })
        ]
    }
}

