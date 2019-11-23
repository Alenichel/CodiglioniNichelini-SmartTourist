//
//  LoginView.swift
//  SmartTourist
//
//  Created by Fabio Codiglioni on 23/11/2019.
//  Copyright © 2019 Fabio Codiglioni. All rights reserved.
//

import UIKit
import Tempura
import PinLayout


struct LoginViewModel: ViewModelWithState {
    let loginText: String
    
    init(state: AppState) {
        loginText = "Login"
    }
}


class LoginView: UIView, ViewControllerModellableView {
    var label = UILabel()
    
    func setup() {
        self.addSubview(self.label)
    }
    
    func style() {
        backgroundColor = .black
        label.font = UIFont.systemFont(ofSize: 32 + 16)
        label.textColor = .white
    }
    
    func update(oldModel: LoginViewModel?) {
        label.text = self.model?.loginText
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.sizeToFit()
        self.label.pin.center()
    }
}
