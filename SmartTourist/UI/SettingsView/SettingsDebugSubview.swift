//
//  SettingsDebugSubview.swift
//  SmartTourist
//
//  Created on 16/03/2020
//

import UIKit
import Tempura
import PinLayout


struct SettingsDebugViewModel: ViewModel {
    let averagePace: Double
    let littleCircleRadius: Double
    let bigCircleRadius: Double
}


class SettingsDebugSubview: UIView, ModellableView {
    var debugTitle = UILabel()
    var averagePaceCell = SettingStringCell()
    var littleCircleRadiusCell = SettingStringCell()
    var bigCircleRadiusCell = SettingStringCell()
    
    func setup() {
        self.debugTitle.text = "Debug"
        self.addSubview(self.debugTitle)
        self.averagePaceCell.setup()
        self.addSubview(self.averagePaceCell)
        self.littleCircleRadiusCell.setup()
        self.addSubview(self.littleCircleRadiusCell)
        self.bigCircleRadiusCell.setup()
        self.addSubview(self.bigCircleRadiusCell)
    }
    
    func style() {
        self.debugTitle.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 1.25, weight: .bold)
        self.averagePaceCell.style()
        self.littleCircleRadiusCell.style()
        self.bigCircleRadiusCell.style()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.debugTitle.pin.top(15).hCenter().sizeToFit()
        self.averagePaceCell.pin.below(of: self.debugTitle).marginTop(15).horizontally(10).height(SettingCell.preferredHeight)
        self.littleCircleRadiusCell.pin.below(of: self.averagePaceCell).marginTop(15).horizontally(10).height(SettingCell.preferredHeight)
        self.bigCircleRadiusCell.pin.below(of: self.littleCircleRadiusCell).marginTop(15).horizontally(10).height(SettingCell.preferredHeight)
    }
    
    func update(oldModel: SettingsDebugViewModel?) {
        guard let model = self.model else { return }
        self.averagePaceCell.model = SettingStringCellViewModel(title: "Average pace", subtitle: nil, value: "\(model.averagePace)")
        self.littleCircleRadiusCell.model = SettingStringCellViewModel(title: "Little circle", subtitle: nil, value: "\(model.littleCircleRadius)")
        self.bigCircleRadiusCell.model = SettingStringCellViewModel(title: "Big circle", subtitle: nil, value: "\(model.bigCircleRadius)")
        self.setNeedsLayout()
    }
}
