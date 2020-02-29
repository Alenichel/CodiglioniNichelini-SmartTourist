//
//  AnimationTestView.swift
//  SmartTourist
//
//  Created on 29/02/2020
//

import UIKit
import Tempura
import PinLayout


struct AnimationTestViewModel: ViewModelWithState {
    let string: String
    let cardString: String
    
    init(state: AppState) {
        self.string = "AnimationTestView"
        self.cardString = "CardView"
    }
}


enum PlayerState {
    case thumbnail
    case fullscreen
}


class AnimationTestView: UIView, ViewControllerModellableView {
    var label = UILabel()
    var cardView = CardView()
    
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var cardState: PlayerState = .thumbnail
    private var originalCardViewFrame = CGRect.zero
    private var animator: UIViewPropertyAnimator?
    private var firstLayout = true
    
    func setup() {
        self.cardView.setup()
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan))
        self.addGestureRecognizer(self.panGestureRecognizer)
        self.addSubview(self.label)
        self.addSubview(self.cardView)
    }
    
    func style() {
        self.cardView.style()
        self.backgroundColor = .systemBackground
        self.label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.sizeToFit()
        self.label.pin.topCenter(42)
        if self.firstLayout {
            self.cardView.pin.bottom().left().right().top(70%)
            self.firstLayout = false
        }
    }
    
    func update(oldModel: AnimationTestViewModel?) {
        guard let model = self.model else { return }
        self.cardView.model = CardViewModel(string: model.cardString)
        self.label.text = model.string
        self.setNeedsLayout()
    }
    
    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            self.panningBegan()
        case .changed:
            let translation = recognizer.translation(in: self.superview)
            self.panningChanged(withTranslation: translation)
        case .ended:
            let translation = recognizer.translation(in: self.superview)
            let velocity = recognizer.velocity(in: self)
            self.panningEnded(withTranslation: translation, velocity: velocity)
        default:
            break
        }
    }
    
    private func panningBeganOld() {
        var targetFrame: CGRect
        switch self.cardState {
        case .thumbnail:
            self.originalCardViewFrame = self.cardView.frame
            targetFrame = self.frame
        case .fullscreen:
            targetFrame = self.originalCardViewFrame
        }
        self.animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.8, animations: {
            self.cardView.frame = targetFrame
        })
    }
    
    private func panningBegan() {
        var targetPercent: Percent
        switch self.cardState {
        case .thumbnail:
            targetPercent = 30%
        case .fullscreen:
            targetPercent = 70%
        }
        self.animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.8, animations: {
            self.cardView.pin.bottom().left().right().top(targetPercent)
        })
    }
    
    private func panningChanged(withTranslation translation: CGPoint) {
        guard let animator = self.animator else { return }
        let translatedY = self.center.y + translation.y
        var progress: CGFloat
        switch self.cardState {
        case .thumbnail:
            progress = 1 - (translatedY / self.center.y)
        case .fullscreen:
            progress = (translatedY / self.center.y) - 1
        }
        progress = max(0.001, min(0.999, progress))
        animator.fractionComplete = progress
    }
    
    private func panningEnded(withTranslation translation: CGPoint, velocity: CGPoint) {
        self.panGestureRecognizer.isEnabled = false
        let screenHeight = UIScreen.main.bounds.size.height
        switch self.cardState {
        case .thumbnail:
            if translation.y <= -screenHeight / 3 || velocity.y <= -100 {
                self.animator?.isReversed = false
                self.animator?.addCompletion { [weak self] _ in
                    self?.cardState = .fullscreen
                    self?.panGestureRecognizer.isEnabled = true
                }
            } else {
                self.animator?.isReversed = true
                self.animator?.addCompletion { [weak self] _ in
                    self?.cardState = .thumbnail
                    self?.panGestureRecognizer.isEnabled = true
                }
            }
        case .fullscreen:
            if translation.y >= screenHeight / 3 || velocity.y >= 100 {
                self.animator?.isReversed = false
                self.animator?.addCompletion { [weak self] _ in
                    self?.cardState = .thumbnail
                    self?.panGestureRecognizer.isEnabled = true
                }
            } else {
                self.animator?.isReversed = true
                self.animator?.addCompletion { [weak self] _ in
                    self?.cardState = .fullscreen
                    self?.panGestureRecognizer.isEnabled = true
                }
            }
        }
        let velocityVector = CGVector(dx: velocity.x / 100, dy: velocity.y / 100)
        let springParameters = UISpringTimingParameters(dampingRatio: 0.8, initialVelocity: velocityVector)
        self.animator?.continueAnimation(withTimingParameters: springParameters, durationFactor: 1.0)
    }
}
