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
        self.rootView.didLoadEverything = { [unowned self] in
            self.localState.allLoaded = true
        }
        self.rootView.didTapDirectionButton = { [unowned self] location, place in
            let url = GoogleAPI.shared.buildDirectionURL(origin: location!, destination: place!.location, destinationPlaceId: place!.placeID)
            UIApplication.shared.open(url)
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
    var allLoaded: Bool = false
}
