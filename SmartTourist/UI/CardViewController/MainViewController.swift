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
            self.localState.animate = true
            switch self.localState.cardState {
            case .expanded:
                self.localState.cardState = .collapsed
            case .collapsed:
                self.localState.cardState = .expanded
            }
        }
    }
}


struct MainLocalState: LocalState {
    enum CardState: Int {
        case expanded = 30
        case collapsed = 70
    }
    
    var cardState: CardState = .collapsed
    var animate: Bool = false
}
