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
        self.stepper.on(.valueChanged) { stepper in
            self.didChange?(stepper.value)
        }
        self.addSubview(self.title)
        self.addSubview(self.subtitle)
        self.addSubview(self.stepper)
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
    }
    
    func update(oldModel: SettingBoolCellViewModel?) {
        guard let model = self.model else { return }
        self.title.text = model.title
        self.subtitle.text = model.subtitle
        self.stepper.value = model.value
    }
}

