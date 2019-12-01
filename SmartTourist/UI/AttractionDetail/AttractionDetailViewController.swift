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
    override func setupInteraction() {}
}


struct AttractionDetailLocalState: LocalState {
    var attraction: GMSPlace
}
