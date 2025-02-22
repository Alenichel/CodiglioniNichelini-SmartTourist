//
//  SettingDoubleCell.swift
//  SmartTourist
//
//  Created on 02/05/2020
//

import UIKit
import Tempura
import PinLayout


struct SettingDoubleCellViewModel: ViewModel {
    let title: String
    let subtitle: String?
    let value: Double
}


class SettingDoubleCell: SettingCell, ModellableView {
    var title = UILabel()
    var subtitle = UILabel()
    var stepper = UIStepper()
    var valueLabel = UILabel()
    var didChange: ((Double) -> Void)?
    
    func setup() {
        self.stepperConfig()
        self.addSubview(self.title)
        self.addSubview(self.subtitle)
        self.addSubview(self.stepper)
        self.addSubview(self.valueLabel)
    }
    
    override func style() {
        super.style()
        self.subtitle.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 0.85)
        self.subtitle.textColor = .secondaryLabel
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let _ = self.subtitle.text {
            self.title.pin.top(7).left(10).sizeToFit()
            self.subtitle.pin.below(of: self.title, aligned: .left).bottom(5).sizeToFit()
        } else {
            self.title.pin.vCenter().left(10).sizeToFit()
        }
        self.stepper.pin.vCenter().right(10).sizeToFit()
        self.valueLabel.pin.left(of: self.stepper, aligned: .center).marginRight(10).sizeToFit()
    }
    
    func update(oldModel: SettingDoubleCellViewModel?) {
        guard let model = self.model else { return }
        self.title.text = model.title
        self.subtitle.text = model.subtitle
        self.stepper.value = self.getValue()
        self.valueLabel.text = self.getValueString()
        self.setNeedsLayout()
    }
    
    func getValue() -> Double {
        guard let model = self.model else { return 0 }
        return model.value
    }
    
    func getValueString() -> String {
        guard let model = self.model else { return "" }
        return "\(model.value)"
    }
    
    func stepperConfig() {
        self.stepper.minimumValue = 0
        self.stepper.maximumValue = 10
        self.stepper.stepValue = 1
        self.stepper.wraps = true
        self.stepper.on(.valueChanged) { stepper in
            let value = stepper.value
            self.didChange?(value)
        }
    }
}

