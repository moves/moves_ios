//
//  VideoPlayerCollectionViewCell.swift
// //
//
//  Created by Wasiq Tayyab on 16/06/2024.
//

import UIKit
import GSPlayer

class VideoPlayerCollectionViewCell: UICollectionViewCell {

    
    private var url: URL!
    
    @IBOutlet weak var lblLike: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblSave: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imgDisk: CustomImageView!
    @IBOutlet weak var lblShare: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgProfile: CustomImageView!
    
    @IBOutlet weak var locationStack: UIStackView!
    @IBOutlet weak var gradientView: DSGradientProgressView!
    @IBOutlet weak var btnProfile: UIButton!
    
    @IBOutlet weak var diskImage: CustomView!
    @IBOutlet weak var btnTitle: UIButton!
    @IBOutlet weak var btnSound: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnHashtag: UIButton!
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var btnPlus: CustomButton!
    @IBOutlet weak var pauseView: UIImageView!
    @IBOutlet weak var videoView: VideoPlayerView!
    
    
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var viewShop: CustomView!
    @IBOutlet weak var viewShopHeight: NSLayoutConstraint!
    @IBOutlet weak var btnShop: UIButton!
    @IBOutlet weak var btnLocation: UIButton!
    
    @IBOutlet weak var commentStack: UIStackView!
    
    @IBOutlet weak var orderHeight: NSLayoutConstraint!
    @IBOutlet weak var lblOrderName: UILabel!
    @IBOutlet weak var orderView: CustomView!
    @IBOutlet weak var btnOrder: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.textContainer.lineFragmentPadding = 0
        self.diskImage.startRotating()
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        self.diskImage.addSubview(blurView)
        blurView.fillSuperview()
        videoView.replay(resetCount: true)
      
        setUpPausePlayTapGesture()
        
        videoView.stateDidChanged = { state in
            switch state {
            case .none:
                print("none")
            case .error(let error):
                print("error - \(error.localizedDescription)")
            case .loading:
                print("loading")
            case .paused(let playing, let buffering):
                print("paused - progress \(Int(playing * 100))% buffering \(Int(buffering * 100))%")
                self.pauseView.alpha = 1
                self.gradientView.signal()
                self.diskImage.stopRotating()
            case .playing:
                print("playing")
                self.pauseView.alpha = 0
                self.diskImage.startRotating()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    func set(url: URL) {
        self.url = url
    }
    
  
    func detectHashTagsAndMentions(in string: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string)
        
        // Define the regular expressions
        let hashtagRegex = try! NSRegularExpression(pattern: "#(\\w+)", options: .caseInsensitive)
        let mentionRegex = try! NSRegularExpression(pattern: "@(\\w+)", options: .caseInsensitive)
        
        // Hashtags
        hashtagRegex.enumerateMatches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count)) { match, _, _ in
            if let matchRange = match?.range(at: 0) {
                let hashtag = (string as NSString).substring(with: matchRange)
                let hashtagLink = "hashtag:\(hashtag)"
                attributedString.addAttribute(.link, value: hashtagLink, range: matchRange)
            }
        }
        
        // Mentions
        mentionRegex.enumerateMatches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count)) { match, _, _ in
            if let matchRange = match?.range(at: 0) {
                let mention = (string as NSString).substring(with: matchRange)
                let mentionLink = "mention:\(mention)"
                attributedString.addAttribute(.link, value: mentionLink, range: matchRange)
            }
        }
        
        return attributedString
    }

    
    func setCellText(text: String) {
        if text.isEmpty {
            textView.isHidden = true
            return
        }
        
        textView.isHidden = false
        
        // Apply attributed string with hashtags and mentions
        let attributedString = detectHashTagsAndMentions(in: text)
        textView.attributedText = attributedString
        textView.font = AppFont.font(type: .Regular, size: 12.0)
        // Enable interaction and adjust appearance
        textView.isEditable = false
        textView.isSelectable = true
        textView.dataDetectorTypes = .link
        textView.textColor = .white
    }
    
    func play() {
        
        gradientView.wait()
        pauseView.alpha = 0
        initializeVideoPlayer(url: url)
    }
    
    fileprivate func initializeVideoPlayer(url: URL) {
        videoView.play(for: url)
    }

    
    func setUpPausePlayTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDidTapPausePlayButton))
        videoView.isUserInteractionEnabled = true
        videoView.addGestureRecognizer(tapGesture)
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(handleDidTapPausePlayButton))
        pauseView.isUserInteractionEnabled = true
        pauseView.addGestureRecognizer(tapGesture1)
     }

    @objc fileprivate func handleDidTapPausePlayButton() {
        if pauseView.alpha == 0 {
            pauseView.alpha = 1
            self.pause()
        } else {
            pauseView.alpha = 0
            videoView.resume()
        }
    }

    func pause() {
        videoView.pause(reason: .hidden)
    }

}
