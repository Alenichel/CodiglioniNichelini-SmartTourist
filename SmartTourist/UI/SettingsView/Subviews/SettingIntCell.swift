//
//  SettingIntCell.swift
//  SmartTourist
//
//  Created on 03/05/2020
//

import Foundation


class SettingIntCell: SettingDoubleCell {
    override func stepperConfig() {
        self.stepper.minimumValue = 100
        self.stepper.maximumValue = 200
        self.stepper.stepValue = 10
        self.stepper.wraps = true
        self.stepper.on(.valueChanged) { stepper in
            let value = stepper.value
            self.didChange?(value)
        }
    }
    
    override func getValue() -> Double {
        guard let model = self.model else { return 0 }
        return model.value
    }
    
    override func getValueString() -> String {
        guard let model = self.model else { return "" }
        return "\(Int(model.value))"
    }
}
