//
//  SettingCell.swift
//  SmartTourist
//
//  Created on 14/03/2020
//

import UIKit
import Tempura
import PinLayout


class SettingCell: UIView {
    static let preferredHeight: CGFloat = 50
    
    func style() {
        self.backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = 12
        self.layer.shadowColor = UIColor.label.cgColor
        self.layer.shadowOpacity = UITraitCollection.current.userInterfaceStyle == .dark ? 0.5 : 0.75
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 2
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.layer.shadowColor = UIColor.label.cgColor
        self.layer.shadowOpacity = UITraitCollection.current.userInterfaceStyle == .dark ? 0.5 : 0.75
    }
}
