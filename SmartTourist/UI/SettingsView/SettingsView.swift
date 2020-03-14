//
//  SettingsView.swift
//  SmartTourist
//
//  Created on 14/03/2020
//

import UIKit
import Tempura
import PinLayout


struct SettingsViewModel: ViewModelWithState {
    let notificationsEnabled: Bool
    
    init(state: AppState) {
        self.notificationsEnabled = state.settings.notificationsEnabled
    }
}


class SettingsView: UIView, ViewControllerModellableView {
    var notificationsCell = SettingBoolCell()
    
    let notificationsTitle = "Notifications"
    let notificationsSubtitle = "Enable notifications for nearest top attractions"
        
    func setup() {
        self.notificationsCell.setup()
        self.addSubview(self.notificationsCell)
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.notificationsCell.style()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.notificationsCell.pin.top(self.safeAreaInsets).marginTop(15).horizontally(10).height(SettingCell.preferredHeight)
    }
    
    func update(oldModel: SettingsViewModel?) {
        guard let model = self.model else { return }
        self.notificationsCell.model = SettingBoolCellViewModel(title: self.notificationsTitle, subtitle: self.notificationsSubtitle, value: model.notificationsEnabled)
        self.setNeedsLayout()
    }
}
