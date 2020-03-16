//
//  SettingBoolCell.swift
//  SmartTourist
//
//  Created on 14/03/2020
//

import UIKit
import Tempura
import PinLayout


struct SettingBoolCellViewModel: ViewModel {
    let title: String
    let subtitle: String?
    let value: Bool
}


class SettingBoolCell: SettingCell, ModellableView {
    var title = UILabel()
    var subtitle = UILabel()
    var toggle = UISwitch()
    var didToggle: ((Bool) -> Void)?
    
    func setup() {
        self.toggle.on(.valueChanged) { toggle in
            self.didToggle?(toggle.isOn)
        }
        self.addSubview(self.title)
        self.addSubview(self.subtitle)
        self.addSubview(self.toggle)
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
        self.toggle.pin.vCenter().right(10).sizeToFit()
    }
    
    func update(oldModel: SettingBoolCellViewModel?) {
        guard let model = self.model else { return }
        self.title.text = model.title
        self.subtitle.text = model.subtitle
        self.toggle.setOn(model.value, animated: false)
    }
}
