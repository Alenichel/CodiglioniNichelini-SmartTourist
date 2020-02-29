//
//  CardView.swift
//  SmartTourist
//
//  Created on 29/02/2020
//

import UIKit
import Tempura


struct CardViewModel: ViewModel {
    let string: String
}


class CardView: UIView, ModellableView {
    var label = UILabel()
    
    func setup() {
        self.addSubview(self.label)
    }
    
    func style() {
        self.backgroundColor = .systemGray3
        self.label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.sizeToFit()
        self.label.pin.topCenter(24)
    }
    
    func update(oldModel: CardViewModel?) {
        guard let model = self.model else { return }
        self.label.text = model.string
        self.setNeedsLayout()
    }
}
