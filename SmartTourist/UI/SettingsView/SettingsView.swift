//
//  SettingsView.swift
//  SmartTourist
//
//  Created on 14/03/2020
//

import UIKit
import Tempura
import PinLayout


struct SettingsViewModel: ViewModelWithLocalState {
    let notificationsEnabled: Bool
    let showDebug: Bool
    
    init?(state: AppState?, localState: SettingsViewLocalState) {
        guard let state = state else { return nil }
        self.notificationsEnabled = state.settings.notificationsEnabled
        self.showDebug = localState.showDebug
    }
}


class SettingsView: UIView, ViewControllerModellableView {
    var notificationsCell = SettingBoolCell()
    var systemSettingsCell = SettingStringCell()
    var versionLabel = UILabel()
    
    var debugGestureRecognizer: UITapGestureRecognizer!
    var didTapDebug: Interaction?
    
    var systemSettingsGestureRecognizer: UITapGestureRecognizer!
    var didTapSystemSettings: Interaction?
    
    private let notificationsTitle = "Notifications"
    private let notificationsSubtitle = "Enable notifications for nearest top attractions"
        
    func setup() {
        self.notificationsCell.setup()
        self.systemSettingsCell.setup()
        self.debugGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleDebugTap))
        self.debugGestureRecognizer.numberOfTapsRequired = 5
        self.addGestureRecognizer(self.debugGestureRecognizer)
        self.systemSettingsGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleSystemSettingsTap))
        self.systemSettingsCell.addGestureRecognizer(self.systemSettingsGestureRecognizer)
        self.addSubview(self.notificationsCell)
        self.addSubview(self.systemSettingsCell)
        self.addSubview(self.versionLabel)
        if let version = Bundle.main.releaseVersionNumber, let build = Bundle.main.buildVersionNumber {
            self.versionLabel.text = "SmartTourist \(version) (\(build))"
        }
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.notificationsCell.style()
        self.systemSettingsCell.style()
        self.versionLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 0.85)
        self.versionLabel.textColor = .secondaryLabel
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.notificationsCell.pin.top(self.safeAreaInsets).marginTop(15).horizontally(10).height(SettingCell.preferredHeight)
        self.systemSettingsCell.pin.below(of: self.notificationsCell).marginTop(15).horizontally(10).height(SettingCell.preferredHeight)
        self.versionLabel.pin.below(of: self.systemSettingsCell).marginTop(30).hCenter().sizeToFit()
    }
    
    func update(oldModel: SettingsViewModel?) {
        guard let model = self.model else { return }
        self.notificationsCell.model = SettingBoolCellViewModel(title: self.notificationsTitle, subtitle: self.notificationsSubtitle, value: model.notificationsEnabled)
        self.systemSettingsCell.model = SettingStringCellViewModel(title: "System settings", subtitle: nil, value: nil)
        self.setNeedsLayout()
    }
    
    @objc private func handleDebugTap(_ recognizer: UITapGestureRecognizer) {
        self.didTapDebug?()
    }
    
    @objc private func handleSystemSettingsTap(_ recognizer: UITapGestureRecognizer) {
        self.didTapSystemSettings?()
    }
}
