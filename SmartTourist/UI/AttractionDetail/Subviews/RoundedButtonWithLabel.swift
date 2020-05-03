//
//  RoundedButtonWithLabel.swift
//  SmartTourist
//
//  Created on 03/05/2020
//

import UIKit
import Tempura
import PinLayout


struct RoundedButtonWithLabelViewModel: ViewModel {
    let label: String
    let button: UIButton
}


class RoundedButtonWithLabel: UIView, ModellableView {
    static let preferredHeight: CGFloat = 100
    
    var label = UILabel()
    
    func setup() {
        self.addSubview(self.label)
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.label.textColor = .label
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.model?.button.sizeToFit()
        self.model?.button.pin.top().hCenter()
        self.label.sizeToFit()
        self.label.pin.below(of: self.model!.button, aligned: .center)
    }
    
    func update(oldModel: RoundedButtonWithLabelViewModel?) {
        guard let model = self.model else { return }
        self.addSubview(model.button)
        self.label.text = model.label
        self.setNeedsLayout()
    }
    
    func getHeight() -> CGFloat {
        return (self.model?.button.frame.height)! + self.label.frame.height + 4
    }
}

