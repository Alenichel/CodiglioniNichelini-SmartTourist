//
//  WelcomeViewController.swift
//  SmartTourist
//
//  Created on 25/11/2019
//

import UIKit
import Tempura


class WelcomeViewController: ViewController<WelcomeView> {
    override func setupInteraction() {
        self.rootView.didTapButton = { [unowned self] in
            self.dispatch(IncrementWelcomeScreenIndex())
        }
    }
}
