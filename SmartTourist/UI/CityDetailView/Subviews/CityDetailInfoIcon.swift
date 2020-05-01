//
//  CityDetailInfoIcon.swift
//  SmartTourist
//
//  Created on 01/05/2020
//

import UIKit
import Tempura
import PinLayout


struct CityDetailInfoIconViewModel: ViewModel {
    let label: String
    let icon: UIImage
}


class CityDetailInfoIcon: UIView, ModellableView {
    static let preferredHeight: CGFloat = 100
    
    var imageView = UIImageView()
    var label = UILabel()
    
    func setup() {
        self.addSubview(self.imageView)
        self.addSubview(self.label)
    }
    
    func style() {
        self.backgroundColor = .systemBackground
        self.label.textColor = .label
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.sizeToFit()
        self.label.sizeToFit()
        self.imageView.pin.top().hCenter()
        self.label.pin.below(of: self.imageView, aligned: .center)
    }
    
    func update(oldModel: CityDetailInfoIconViewModel?) {
        guard let model = self.model else { return }
        self.imageView.image = model.icon
        self.label.text = model.label
        self.setNeedsLayout()
    }
    
    func getHeight() -> CGFloat {
        return self.imageView.frame.height + self.label.frame.height + 4
    }
}
