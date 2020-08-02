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
        self.rootView.didLoadEverything = { [unowned self] in
            self.localState.allLoaded = true
        }
        self.rootView.didTapDirectionButton = { location, place in
            guard let place = place else { return }
            MapsAPI.shared.openDirectionsInMapsApp(to: place)
        }
        self.rootView.didTapLinkButton = { [unowned self] attractionUrl in
            guard let stringUrl = attractionUrl, let url = URL(string: stringUrl) else { return }
            self.dispatch(Show(Screen.safari, animated: true, context: url))
        }
        self.rootView.didTapWikipediaButton = { [unowned self] wikipediaUrl in
            guard let wikipediaUrl = wikipediaUrl, let url = URL(string: wikipediaUrl) else { return }
            self.dispatch(Show(Screen.safari, animated: true, context: url))
        }
        self.rootView.didTapContributeButton = {
            UIApplication.shared.open(URL(string: "https://en.wikipedia.org/wiki/Wikipedia:Contributing_to_Wikipedia")!)
        }
        self.rootView.didTapMap = { [unowned self] attraction in
            self.dispatch(Show(Screen.fullScreenMap, animated: true, context: attraction))
        }
    }
}


extension AttractionDetailViewController: RoutableWithConfiguration {
    var routeIdentifier: RouteElementIdentifier {
        Screen.detail.rawValue
    }
    
    var navigationConfiguration: [NavigationRequest : NavigationInstruction] {
        [
            .hide(Screen.detail): .pop,
            .show(Screen.safari): .presentModally { [unowned self] context in
                let vc = SFSafariViewController(url: context as! URL)
                vc.delegate = self
                vc.dismissButtonStyle = .close
                return vc
            },
            .show(Screen.fullScreenMap): .presentModally { [unowned self] context in
                let attraction = context as! WDPlace
                let vc = FullScreenMapViewController(store: self.store, localState: FullScreenMapLocalState(attraction: attraction))
                vc.modalPresentationStyle = .pageSheet
                return vc
            }
        ]
    }
}


extension AttractionDetailViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.dispatch(Hide(animated: true))
    }
}


struct AttractionDetailLocalState: LocalState {
    var attraction: WDPlace
    var allLoaded: Bool = false
}
