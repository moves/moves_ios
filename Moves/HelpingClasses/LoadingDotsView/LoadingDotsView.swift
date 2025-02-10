//
//  LoadingDotsView.swift
// //
//
//  Created by Wasiq Tayyab on 29/08/2024.
//

import Foundation
import UIKit
class LoadingDotsView: UIView {
    
    private let dotCount = 3
    private let dotSize: CGFloat = 10.0
    private let dotSpacing: CGFloat = 5.0
    private var dots = [UIView]()
    private var animationDuration: TimeInterval = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        for i in 0..<dotCount {
            let dot = UIView()
            dot.backgroundColor = .gray
            dot.layer.cornerRadius = dotSize / 2
            dot.frame = CGRect(x: CGFloat(i) * (dotSize + dotSpacing), y: 0, width: dotSize, height: dotSize)
            addSubview(dot)
            dots.append(dot)
        }
        startAnimating()
    }
    
    func startAnimating() {
        for (index, dot) in dots.enumerated() {
            let animation = CAKeyframeAnimation(keyPath: "opacity")
            animation.values = [0.2, 1.0, 0.2]
            animation.keyTimes = [0, 0.5, 1]
            animation.duration = animationDuration
            animation.repeatCount = .infinity
            animation.beginTime = CACurrentMediaTime() + Double(index) * (animationDuration / Double(dotCount))
            dot.layer.add(animation, forKey: "loadingDotsAnimation")
        }
    }
    
    func stopAnimating() {
        for dot in dots {
            dot.layer.removeAllAnimations()
        }
    }
}
