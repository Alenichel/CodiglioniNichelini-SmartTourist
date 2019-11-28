//
//  CardView.swift
//  SmartTourist
//
//  Created on 28/11/2019
//

import UIKit
import Tempura
import GooglePlaces
import PinLayout


struct CardViewModel: ViewModel {
    let place: String
}


class CardView: UIView, ModellableView {
    var handle = UIButton(type: .system)
    var label = UILabel()
    
    var animate: Interaction?
    
    func setup() {
        self.handle.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        self.handle.on(.touchUpInside) { button in
            print(button)
            self.animate?()
        }
        self.addSubview(self.handle)
        self.addSubview(self.label)
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 8)
        self.label.textAlignment = .center
        self.handle.tintColor = .systemGray
        self.layer.cornerRadius = 30
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 10
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.handle.sizeToFit()
        self.label.sizeToFit()
        self.handle.pin.top(5%).left().right()
        self.label.pin.top(20%).left(5%).right(5%)
    }
    
    func update(oldModel: CardViewModel?) {
        if let model = self.model {
            self.label.text = model.place
        }
        self.setNeedsLayout()
    }
}
