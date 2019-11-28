//
//  MainViewController.swift
//  SmartTourist
//
//  Created on 28/11/2019
//

import UIKit
import Tempura
import PinLayout


class MainViewController: ViewControllerWithLocalState<MainView> {
    override func setupInteraction() {
        self.rootView.cardView.animate = { [unowned self] in
            if self.localState.cardPercentage == 70 {
                self.localState.cardPercentage = 30
            } else if self.localState.cardPercentage == 30 {
                self.localState.cardPercentage = 70
            } else {
                print("ERROR")
            }
        }
    }
}


struct MainLocalState: LocalState {
    var cardPercentage: Int
}
