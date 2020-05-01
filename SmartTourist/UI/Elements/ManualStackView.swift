//
//  ManualStackView.swift
//  SmartTourist
//
//  Created on 01/05/2020
//

import UIKit
import Tempura
import PinLayout


struct ManualStackViewModel: ViewModel {
    let views: [UIView]
}


class ManualStackView: UIView, ModellableView {
    var stackedSubviews = [UIView]()
    
    func setup() {
        guard !self.stackedSubviews.isEmpty else { return }
        for view in self.stackedSubviews {
            self.addSubview(view)
        }
    }
    
    func style() {
        self.backgroundColor = .systemBackground
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard !self.stackedSubviews.isEmpty else { return }
        self.setup()
        if self.stackedSubviews.count == 1 {
            self.stackedSubviews[0].pin.center()
        } else if self.stackedSubviews.count == 2 {
            self.stackedSubviews[0].pin.top().left(30%)
            self.stackedSubviews[1].pin.top().right(30%)
        } else if self.stackedSubviews.count == 3 {
            self.stackedSubviews[0].pin.top().left(15%)
            self.stackedSubviews[1].pin.top().hCenter()
            self.stackedSubviews[2].pin.top().right(15%)
        } else if self.stackedSubviews.count == 4 {
            self.stackedSubviews[0].pin.top().left(10%)
            self.stackedSubviews[1].pin.top().left(33%)
            self.stackedSubviews[2].pin.top().right(33%)
            self.stackedSubviews[3].pin.top().right(10%)
        } else {
            fatalError("The requested number of views is not supported in this ManualStackView")
        }
    }
    
    func update(oldModel: ManualStackViewModel?) {
        guard let model = self.model else { return }
        if !self.stackedSubviews.isEmpty {
            self.stackedSubviews.forEach { view in
                view.removeFromSuperview()
            }
            self.stackedSubviews.removeAll()
        }
        self.stackedSubviews.append(contentsOf: model.views)
        self.setNeedsLayout()
    }
}
