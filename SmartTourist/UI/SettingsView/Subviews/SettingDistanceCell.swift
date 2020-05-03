//
//  SettingDistanceCell.swift
//  SmartTourist
//
//  Created on 03/05/2020
//

import Foundation


class SettingDistanceCell: SettingDoubleCell {
    override func stepperConfig() {
        self.stepper.minimumValue = 0
        self.stepper.maximumValue = 5
        self.stepper.stepValue = 1
        self.stepper.wraps = true
        self.stepper.on(.valueChanged) { stepper in
            let value = pow(2, stepper.value)
            self.didChange?(value)
        }
    }
    
    override func getValue() -> Double {
        guard let model = self.model else { return 0 }
        return log2(model.value)
    }
    
    override func getValueString() -> String {
        guard let model = self.model else { return "" }
        return "\(Int(model.value)) km"
    }
}
