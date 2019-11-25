//
//  WelcomeView.swift
//  SmartTourist
//
//  Created on 25/11/2019
//

import UIKit
import Tempura
import PinLayout


struct WelcomeViewModel: ViewModelWithState {
    let text: String
    let buttonText: String
    
    init(state: AppState) {
        let index = state.welcomeState.screenIndex
        self.text = state.welcomeState.labels[index]
        self.buttonText = state.welcomeState.buttons[index]
    }
}


class WelcomeView: UIView, ViewControllerModellableView {
    // MARK: Subviews
    var label = UILabel()
    var button = UIButton(type: .roundedRect)
    
    // MARK: Interactions
    var didTapButton: Interaction?

    func setup() {
        self.button.on(.touchUpInside) { button in
            self.didTapButton?()
        }
        self.addSubview(self.label)
        self.addSubview(self.button)
    }
    
    func style() {
        self.label.numberOfLines = 4
        self.label.textAlignment = .center
        self.label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 8)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.sizeToFit()
        self.button.sizeToFit()
        self.label.pin.center()
        self.button.pin.below(of: self.label, aligned: .center).marginTop(100)
    }
    
    func update(oldModel: WelcomeViewModel?) {
        if let model = self.model {
            self.label.text = model.text
            self.button.setTitle(model.buttonText, for: .normal)
            self.setNeedsLayout()
        }
    }
}
