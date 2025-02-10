//
//  ZFDouYinControlView.swift
// //
//
//  Created by YS on 2024/9/16.
//

import UIKit
import ZFPlayer

class LZFControlView: UIView,ZFPlayerMediaControl {
    private var playBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.isUserInteractionEnabled = false
        button.setImage(UIImage(named: "icon_play_pause"), for: .normal)
        return button
    }()
    
    private var sliderView: ZFSliderView = {
        let slider = ZFSliderView()
        slider.maximumTrackTintColor = UIColor(white: 1, alpha: 0.2)
        slider.minimumTrackTintColor = .white
        slider.bufferTrackTintColor = .clear
        slider.sliderHeight = 1
        slider.isHideSliderBlock = false
        return slider
    }()
    
    private var bgImgView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    var player: ZFPlayerController? {
        didSet {
            player?.currentPlayerManager.view.insertSubview(bgImgView, at: 0)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(playBtn)
        addSubview(sliderView)
        resetControlView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let minViewWidth = zf_width
        let minViewHeight = zf_height
        
        playBtn.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        playBtn.center = center
        
        sliderView.frame = CGRect(x: 0, y: minViewHeight - 2, width: minViewWidth, height: 1)
        
        bgImgView.frame = bounds
    }
    
    func resetControlView() {
        playBtn.isHidden = true
        sliderView.value = 0
        sliderView.bufferValue = 0
    }
    
    func playButtonAction() {
        playBtn.isHidden = false
    }
    
    func videoPlayer(_ videoPlayer: ZFPlayerController, loadStateChanged state: ZFPlayerLoadState) {
        
        if (state == .stalled || state == .prepare) && videoPlayer.currentPlayerManager.isPlaying {
            sliderView.startAnimating()
        } else {
            sliderView.stopAnimating()
        }
    }
    
    func videoPlayer(_ videoPlayer: ZFPlayerController, currentTime: TimeInterval, totalTime: TimeInterval) {
        sliderView.value = videoPlayer.progress
    }
    
    func gestureSingleTapped(_ gestureControl: ZFPlayerGestureControl) {
        guard let playerManager = player?.currentPlayerManager else {
            return
        }
        
        if playerManager.isPlaying {
            playerManager.pause()
            playBtn.isHidden = false
            playBtn.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
                self.playBtn.transform = .identity
            }
        } else {
            playerManager.play()
            playBtn.isHidden = true
        }
    }
    
    func gestureTriggerCondition(_ gestureControl: ZFPlayerGestureControl, gestureType: ZFPlayerGestureType, gestureRecognizer: UIGestureRecognizer, touch: UITouch) -> Bool {
        return gestureType != .pan
    }
    
    deinit {
        print("LZFControlView=====dinit")
    }
}
