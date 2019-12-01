//
//  AttractionDetailView.swift
//  SmartTourist
//
//  Created on 01/12/2019
//

import UIKit
import Katana
import Tempura
import PinLayout
import GooglePlaces


struct AttractionDetailViewModel: ViewModelWithLocalState {
    let attraction: String
    
    init(state: AppState?, localState: AttractionDetailLocalState) {
        self.attraction = localState.attraction
    }
}


class AttractionDetailView: UIView, ViewControllerModellableView {
    var label = UILabel()
    
    func setup() {
        self.addSubview(self.label)
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.label.font = UIFont.systemFont(ofSize: 18)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.sizeToFit()
        self.label.pin.center()
    }
    
    func update(oldModel: AttractionDetailViewModel?) {
        guard let model = self.model else { return }
        self.label.text = model.attraction
        self.setNeedsLayout()
    }
}
