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
    let poorEntitiesEnabled: Bool
    let maxRadius: Double
    let maxNAttractions: Int
    let showDebug: Bool
    let averagePace: Double
    let littleCircleRadius: Double
    let bigCircleRadius: Double
    
    init?(state: AppState?, localState: SettingsViewLocalState) {
        guard let state = state else { return nil }
        self.notificationsEnabled = state.settings.notificationsEnabled
        self.poorEntitiesEnabled = state.settings.poorEntitiesEnabled
        self.maxRadius = state.settings.maxRadius
        self.maxNAttractions = state.settings.maxNAttractions
        self.showDebug = localState.showDebug
        self.averagePace = state.pedometerState.averageWalkingSpeed
        self.littleCircleRadius = state.pedometerState.littleCircleRadius
        self.bigCircleRadius = state.pedometerState.bigCircleRadius
    }
}


class SettingsView: UIView, ViewControllerModellableView {
    var notificationsCell = SettingBoolCell()
    var poorEntitiesCell = SettingBoolCell()
    var maxRadiusCell = SettingDistanceCell()
    var maxNAttractionsCell = SettingIntCell()
    var systemSettingsCell = SettingStringCell()
    var debugSubview = SettingsDebugSubview()
    var versionLabel = UILabel()
    
    var debugGestureRecognizer: UITapGestureRecognizer!
    var didTapDebug: Interaction?
    
    var systemSettingsGestureRecognizer: UITapGestureRecognizer!
    var didTapSystemSettings: Interaction?
    
    private let notificationsTitle = "Notifications"
    private let notificationsSubtitle = "Enable notifications for nearest top attractions"
    private let poorEntitiesTitle = "Undetailed entities"
    private let poorEntitiesSubtitle = "Enable undetailed entities on the map"
    
    func setup() {
        self.notificationsCell.setup()
        self.poorEntitiesCell.setup()
        self.maxRadiusCell.setup()
        self.maxNAttractionsCell.setup()
        self.systemSettingsCell.setup()
        self.debugSubview.setup()
        self.debugGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleDebugTap))
        self.debugGestureRecognizer.numberOfTapsRequired = 5
        self.addGestureRecognizer(self.debugGestureRecognizer)
        self.systemSettingsGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleSystemSettingsTap))
        self.systemSettingsCell.addGestureRecognizer(self.systemSettingsGestureRecognizer)
        self.addSubview(self.notificationsCell)
        self.addSubview(self.poorEntitiesCell)
        self.addSubview(self.maxRadiusCell)
        self.addSubview(self.maxNAttractionsCell)
        self.addSubview(self.systemSettingsCell)
        self.addSubview(self.versionLabel)
        if let version = Bundle.main.releaseVersionNumber, let build = Bundle.main.buildVersionNumber {
            self.versionLabel.text = "SmartTourist \(version) (\(build))"
        }
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.notificationsCell.style()
        self.poorEntitiesCell.style()
        self.maxRadiusCell.style()
        self.maxNAttractionsCell.style()
        self.systemSettingsCell.style()
        self.debugSubview.style()
        self.versionLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 0.85)
        self.versionLabel.textColor = .secondaryLabel
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.notificationsCell.pin.top(self.safeAreaInsets).marginTop(15).horizontally(10).height(SettingCell.preferredHeight)
        self.poorEntitiesCell.pin.below(of: self.notificationsCell).marginTop(15).horizontally(10).height(SettingCell.preferredHeight)
        self.maxRadiusCell.pin.below(of: self.poorEntitiesCell).marginTop(15).horizontally(10).height(SettingCell.preferredHeight)
        self.maxNAttractionsCell.pin.below(of: self.maxRadiusCell).marginTop(15).horizontally(10).height(SettingCell.preferredHeight)
        self.systemSettingsCell.pin.below(of: self.maxNAttractionsCell).marginTop(15).horizontally(10).height(SettingCell.preferredHeight)
        self.versionLabel.pin.below(of: self.systemSettingsCell).marginTop(30).hCenter().sizeToFit()
        self.debugSubview.pin.below(of: self.versionLabel).marginTop(30).horizontally()
    }
    
    func update(oldModel: SettingsViewModel?) {
        guard let model = self.model else { return }
        self.notificationsCell.model = SettingBoolCellViewModel(title: self.notificationsTitle, subtitle: self.notificationsSubtitle, value: model.notificationsEnabled)
        self.poorEntitiesCell.model = SettingBoolCellViewModel(title: self.poorEntitiesTitle, subtitle: self.poorEntitiesSubtitle, value: model.poorEntitiesEnabled)
        self.maxRadiusCell.model = SettingDoubleCellViewModel(title: "Maximum radius", subtitle: nil, value: model.maxRadius)
        self.maxNAttractionsCell.model = SettingDoubleCellViewModel(title: "Maximum attractions", subtitle: nil, value: Double(model.maxNAttractions))
        self.systemSettingsCell.model = SettingStringCellViewModel(title: "System settings", subtitle: nil, value: nil)
        if model.showDebug {
            self.addSubview(self.debugSubview)
            self.debugSubview.model = SettingsDebugViewModel(averagePace: model.averagePace, littleCircleRadius: model.littleCircleRadius, bigCircleRadius: model.bigCircleRadius)
        } else {
            self.debugSubview.removeFromSuperview()
        }
        self.setNeedsLayout()
    }
    
    @objc private func handleDebugTap(_ recognizer: UITapGestureRecognizer) {
        self.didTapDebug?()
    }
    
    @objc private func handleSystemSettingsTap(_ recognizer: UITapGestureRecognizer) {
        self.didTapSystemSettings?()
    }
}
