//
//  RoundedButton.swift
//  SmartTourist
//
//  Created on 30/11/2019
//

import UIKit


class RoundedButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.style()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.style()
    }
    
    func style() {
        self.layer.cornerRadius = 16
    }
    
    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                self.layer.opacity = 0.6
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.layer.opacity = 1
                }
            }
        }
    }
}
