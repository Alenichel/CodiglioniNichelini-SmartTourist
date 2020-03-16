//
//  SettingStringCell.swift
//  SmartTourist
//
//  Created on 16/03/2020
//

import UIKit
import Tempura
import PinLayout


struct SettingStringCellViewModel: ViewModel {
    let title: String
    let subtitle: String?
    let value: String?
}


class SettingStringCell: SettingCell, ModellableView {
    var title = UILabel()
    var subtitle = UILabel()
    var value = UILabel()
    
    func setup() {
        self.addSubview(self.title)
        self.addSubview(self.subtitle)
        self.addSubview(self.value)
    }
    
    override func style() {
        super.style()
        self.subtitle.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 0.85)
        self.subtitle.textColor = .secondaryLabel
        self.value.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 0.95)
        self.value.textColor = .secondaryLabel
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let _ = self.subtitle.text {
            self.title.pin.top(7).left(10).sizeToFit()
            self.subtitle.pin.below(of: self.title, aligned: .left).bottom(5).sizeToFit()
        } else {
            self.title.pin.vCenter().left(10).sizeToFit()
        }
        self.value.pin.vCenter().right(10).sizeToFit()
    }
    
    func update(oldModel: SettingStringCellViewModel?) {
        guard let model = self.model else { return }
        self.title.text = model.title
        self.subtitle.text = model.subtitle
        self.value.text = model.value
    }
}
