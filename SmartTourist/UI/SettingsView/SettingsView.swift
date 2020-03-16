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
    var systemSettingsCell = SettingStringCell()
    
    var systemSettingsGestureRecognizer: UITapGestureRecognizer!
    var didTapSystemSettings: Interaction?
    
    let notificationsTitle = "Notifications"
    let notificationsSubtitle = "Enable notifications for nearest top attractions"
        
    func setup() {
        self.notificationsCell.setup()
        self.systemSettingsCell.setup()
        self.systemSettingsGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleSystemSettingsTap))
        self.systemSettingsCell.addGestureRecognizer(self.systemSettingsGestureRecognizer)
        self.addSubview(self.notificationsCell)
        self.addSubview(self.systemSettingsCell)
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.notificationsCell.style()
        self.systemSettingsCell.style()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.notificationsCell.pin.top(self.safeAreaInsets).marginTop(15).horizontally(10).height(SettingCell.preferredHeight)
        self.systemSettingsCell.pin.below(of: self.notificationsCell).marginTop(15).horizontally(10).height(SettingCell.preferredHeight)
    }
    
    func update(oldModel: SettingsViewModel?) {
        guard let model = self.model else { return }
        self.notificationsCell.model = SettingBoolCellViewModel(title: self.notificationsTitle, subtitle: self.notificationsSubtitle, value: model.notificationsEnabled)
        self.systemSettingsCell.model = SettingStringCellViewModel(title: "System settings", subtitle: nil, value: nil)
        self.setNeedsLayout()
    }
    
    @objc private func handleSystemSettingsTap(_ recognizer: UITapGestureRecognizer) {
        self.didTapSystemSettings?()
    }
}
