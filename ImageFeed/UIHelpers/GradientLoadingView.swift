//
//  GradientLoadingView.swift
//  ImageFeed
//
//  Created by Adilkhan on 25/9/26.
//

import UIKit

final class GradientLoadingView: UIView {
    private let gradientLayer = CAGradientLayer()
    private let animationKey = "locationsChange"

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    func startAnimating() {
        isHidden = false
        guard gradientLayer.animation(forKey: animationKey) == nil else { return }

        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 2.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradientLayer.add(gradientChangeAnimation, forKey: animationKey)
    }

    func stopAnimating() {
        gradientLayer.removeAnimation(forKey: animationKey)
        isHidden = true
    }

    private func setupGradient() {
        isUserInteractionEnabled = false
        isHidden = true
        gradientLayer.locations = [0, 0.1, 0.3]
        gradientLayer.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradientLayer)
    }
}
