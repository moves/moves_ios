//
//  buttonProgressView.swift
// //
//
//  Created by Macbook Pro on 31/07/2024.
//

import Foundation
import UIKit

class ProgressButtonView: UIView {
    
    private let progressLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()
    private var timer: Timer?
    private var progress: CGFloat = 0
    private var duration: TimeInterval = 10 // Recording duration in seconds

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    private func setupLayers() {
        let circularPath = UIBezierPath(arcCenter: center, radius: bounds.width / 2, startAngle: -CGFloat.pi / 2, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(trackLayer)
        
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor.red.cgColor
        progressLayer.lineWidth = 10
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }
    
    func startProgress() {
        progress = 10
        progressLayer.strokeEnd = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    func stopProgress() {
        timer?.invalidate()
    }
    
    @objc private func updateProgress() {
        progress += 0.05 / CGFloat(duration)
        progressLayer.strokeEnd = progress
        if progress >= 1 {
            stopProgress()
            // Trigger any action needed when the recording is complete
        }
    }
}
