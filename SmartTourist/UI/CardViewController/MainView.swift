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
    let place: String
    let cardPercentage: Percent
    
    init(state: AppState?, localState: MainLocalState) {
        self.place = state?.locationState.currentPlace?.name ?? "NO PLACE"
        self.cardPercentage = localState.cardPercentage%
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
        if let model = self.model {
            self.cardView.pin.bottom().left().right().top(model.cardPercentage)
        } else {
            self.cardView.pin.bottom().top(50%).left().right()
        }
    }
    
    func update(oldModel: MainViewModel?) {
        if let model = self.model {
            let cardViewModel = CardViewModel(place: model.place)
            self.cardView.model = cardViewModel
        }
        self.setNeedsLayout()
    }
}
