//
//  AttractionDetailViewController.swift
//  SmartTourist
//
//  Created on 01/12/2019
//

import UIKit
import Katana
import Tempura
import SafariServices

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
        self.rootView.didLoadEverything = { [weak self] in
            guard let instance = self else { return }
            instance.localState.allLoaded = true
        }
        self.rootView.didTapDirectionButton = { location, place in
            let url = GoogleAPI.shared.buildDirectionURL(origin: location!, destination: place!.location, destinationPlaceId: place!.placeID)
            UIApplication.shared.open(url)
        }
        
        self.rootView.didTapLinkButton = { [unowned self] attractionUrl in
            guard let stringUrl = attractionUrl else { return }
            guard let url = URL(string: stringUrl) else { return }
            //UIApplication.shared.open(url)
            let vc = SFSafariViewController(url: url)
            vc.delegate = self
            self.present(vc, animated: true)
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

extension AttractionDetailViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
}

struct AttractionDetailLocalState: LocalState {
    var attraction: GPPlace
    var allLoaded: Bool = false
}
