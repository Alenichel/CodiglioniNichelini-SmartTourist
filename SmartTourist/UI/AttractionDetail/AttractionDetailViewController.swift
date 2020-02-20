//
//  AttractionDetailViewController.swift
//  SmartTourist
//
//  Created on 01/12/2019
//

import UIKit
import Katana
import Tempura


class AttractionDetailViewController: ViewControllerWithLocalState<AttractionDetailView> {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.localState.attraction.name
    }
    
    override func setupInteraction() {
        self.rootView.didTapFavoriteButton = { [unowned self] place in
            if self.state.favorites.contains(place) {
                self.dispatch(RemoveFavorite(place: place))
            } else {
                self.dispatch(AddFavorite(place: place))
            }
        }
    }
}


extension AttractionDetailViewController: RoutableWithConfiguration {
    var routeIdentifier: RouteElementIdentifier {
        Screen.detail.rawValue
    }
    
    var navigationConfiguration: [NavigationRequest : NavigationInstruction] {
        [
            .hide(Screen.detail): .pop
        ]
    }
}


struct AttractionDetailLocalState: LocalState {
    var attraction: GPPlace
}
