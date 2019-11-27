//
//  WelcomeView.swift
//  SmartTourist
//
//  Created on 25/11/2019
//

import UIKit
import Tempura
import PinLayout


struct WelcomeViewModel: ViewModelWithLocalState {
    let locationButtonEnabled: Bool
    let notificationsButtonEnabled: Bool
    
    init(state: AppState?, localState: WelcomeLocalState) {
        self.locationButtonEnabled = localState.locationButtonEnabled
        self.notificationsButtonEnabled = localState.notificationsButtonEnabled
    }
}


class WelcomeView: UIView, ViewControllerModellableView {
    // MARK: Subviews
    var title = UILabel()
    var locationLabel = UILabel()
    var notificationsLabel = UILabel()
    var locationButton = UIButton(type: .system)
    var notificationsButton = UIButton(type: .system)
    var closeButton = UIButton(type: .system)
    
    // MARK: Interactions
    var didTapLocation: Interaction?
    var didTapNotifications: Interaction?
    var didTapClose: Interaction?

    func setup() {
        self.title.text = "In order to provide a better user experience, Smart Tourist needs the following permissions."
        self.locationLabel.text = "Location"
        self.notificationsLabel.text = "Notifications"
        self.locationButton.setTitle("Enable", for: .normal)
        self.locationButton.on(.touchUpInside) { button in
            self.didTapLocation?()
        }
        self.notificationsButton.setTitle("Enable", for: .normal)
        self.notificationsButton.on(.touchUpInside) { button in
            self.didTapNotifications?()
        }
        self.closeButton.setTitle("Close", for: .normal)
        self.closeButton.on(.touchUpInside) { button in
            self.didTapClose?()
        }
        self.addSubview(self.title)
        self.addSubview(self.locationLabel)
        self.addSubview(self.notificationsLabel)
        self.addSubview(self.locationButton)
        self.addSubview(self.notificationsButton)
        self.addSubview(self.closeButton)
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.title.numberOfLines = 5
        self.title.textAlignment = .center
        self.title.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 8)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.title.sizeToFit()
        self.locationLabel.sizeToFit()
        self.notificationsLabel.sizeToFit()
        self.locationButton.sizeToFit()
        self.notificationsButton.sizeToFit()
        self.closeButton.sizeToFit()
        self.title.pin.top(10%).left(5%).right(5%)
        self.locationLabel.pin.below(of: self.title).marginTop(10%).left(5%)
        self.locationButton.pin.below(of: self.title).marginTop(10%).right(10%)
        self.notificationsLabel.pin.below(of: self.locationLabel).marginTop(5%).left(5%)
        self.notificationsButton.pin.below(of: self.locationLabel).marginTop(5%).right(10%)
        self.closeButton.pin.bottom(15%).hCenter()
    }
    
    func update(oldModel: WelcomeViewModel?) {
        if let model = self.model {
            self.updateButton(self.locationButton, enabled: model.locationButtonEnabled)
            self.updateButton(self.notificationsButton, enabled: model.notificationsButtonEnabled)
        }
        self.setNeedsLayout()
    }
    
    private func updateButton(_ button: UIButton, enabled: Bool) {
        button.setTitle(enabled ? "Enabled" : "Enable", for: .normal)
        button.isEnabled = !enabled
    }
}
