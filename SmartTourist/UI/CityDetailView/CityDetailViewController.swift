//
//  CityDetailViewController.swift
//  SmartTourist
//
//  Created on 16/02/2020
//

import UIKit
import Katana
import Tempura
import SafariServices


class CityDetailViewController: ViewControllerWithLocalState<CityDetailView> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dispatch(GetCityDetails())
    }
    
    override func setupInteraction() {
        self.rootView.didTapButton = { url in
            self.dispatch(Show(Screen.safari, animated: true, context: url))
        }
        self.rootView.didLoadEverything = { [unowned self] in
            self.localState.allLoaded = true
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
            .show(Screen.safari): .presentModally { [unowned self] context in
                let vc = SFSafariViewController(url: context as! URL)
                vc.delegate = self
                vc.dismissButtonStyle = .close
                return vc
            },
        ]
    }
}


extension CityDetailViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.dispatch(Hide(animated: true))
    }
}


struct CityDetailLocalState: LocalState {
    var allLoaded: Bool = false
}
