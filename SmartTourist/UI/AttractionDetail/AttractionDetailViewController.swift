//
//  AttractionDetailViewController.swift
//  SmartTourist
//
//  Created on 01/12/2019
//

import UIKit
import Katana
import Tempura
import GooglePlaces


class AttractionDetailViewController: ViewControllerWithLocalState<AttractionDetailView> {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.localState.attraction.name
        if let photoMetadata = self.localState.attraction.photos?.first {
            GoogleAPI.shared.getPlacePicture(photoMetadata: photoMetadata).then { image in
                self.localState.attractionImage = image
            }
        }
    }
    override func setupInteraction() {}
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
    var attraction: GMSPlace
    var attractionImage: UIImage?
}
