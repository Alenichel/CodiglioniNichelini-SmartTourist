//
//  MainView.swift
//  SmartTourist
//
//  Created on 28/11/2019
//

import UIKit
import Tempura
import PinLayout


struct MainViewModel: ViewModelWithLocalState {
    let cardPercentage: Percent
    let animate: Bool
    
    init(state: AppState?, localState: MainLocalState) {
        self.cardPercentage = localState.cardState.rawValue%
        self.animate = localState.animate
    }
}


class MainView: UIView, ViewControllerModellableView {
    var label = UILabel()
    var cardView = CardView()
    
    func setup() {
        self.label.text = "MainView"
        self.addSubview(self.label)
        self.addSubview(self.cardView)
        self.cardView.setup()
        self.cardView.style()
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 16)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.sizeToFit()
        self.label.pin.center()
        self.layoutCardView()
    }
    
    func layoutCardView() {
        if let model = self.model {
            self.cardView.pin.bottom().left().right().top(model.cardPercentage)
        } else {
            self.cardView.pin.bottom().top(50%).left().right()
        }
    }
    
    func update(oldModel: MainViewModel?) {
        if let model = self.model {
            let cardViewModel = CardViewModel(percent: model.cardPercentage)
            self.cardView.model = cardViewModel
            if model.animate {
                UIView.animate(withDuration: 0.5) {
                    self.layoutCardView()
                }
            } else {
                self.setNeedsLayout()
            }
        }
    }
}
