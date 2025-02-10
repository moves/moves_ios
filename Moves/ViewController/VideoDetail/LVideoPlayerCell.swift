//
//  ZFDouYinCell.swift
// //
//
//  Created by YS on 2024/9/16.
//

import UIKit
import ZFPlayer
import SnapKit
import SDWebImage

class LVideoPlayerCell: UITableViewCell {
    private var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.tag = 10086
        imageView.clipsToBounds = true
        return imageView
    }()
    
    
    var indexPath =  IndexPath(row: 0, section: 0)
    var model:HomeResponseMsg?
    let profileImageView = UIImageView()
    let likeButton = UIButton()
    let commentButton = UIButton()
    let shareButton = UIButton()
    let markButton = UIButton()
    let descriptionTextView = UITextView()
    let productButton = UIButton()
    let storeButton = UIButton()
    let locationButton = UIButton()
    let likeNumsLabel = UILabel()
    let commentNumsLabel = UILabel()
    let shareNumsLabel = UILabel()
    let markNumsLabel = UILabel()
    let soundButton = UIButton()
    let attentionButton = UIButton()
    let usernameButton = UIButton()
    let verifiedImage = UIImageView()
    
    let containerView = UIView()
    let iconImageView = UIImageView()
    let label = UILabel()
    let smallIconImageView = UIImageView()
    
    var profileClickHandler: ((IndexPath)->())?
    var commentClickHandler: ((IndexPath)->())?
    var shareClickHandler: ((IndexPath)->())?
    
    var likeClickHandler: ((IndexPath)->())?
    var markClickHandler: ((IndexPath)->())?
    
    //    private var placeholderImage: UIImage? = {
    //        return ZFUtilities.image(with: UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1), size: CGSize(width: 1, height: 1))
    //    }()
    
    private var bgImgView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(bgImgView)
        contentView.addSubview(coverImageView)
        setupUI()
    }
    
    func setupUI() {
        profileImageView.image = UIImage(named: "profile_placeholder")
        profileImageView.isUserInteractionEnabled = true
        profileImageView.backgroundColor = .lightGray
        profileImageView.layer.borderWidth = 1.5
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        contentView.addSubview(profileImageView)
        
        let profileButton = UIButton(type: .custom)
        profileButton.addTarget(self, action: #selector(profileClick(_:)), for: .touchUpInside)
        profileImageView.addSubview(profileButton)
        profileButton.snp.makeConstraints {
            $0.left.top.bottom.trailing.equalTo(0)
        }
        
        verifiedImage.image = UIImage(named: "Tick")
        likeButton.setImage(UIImage(named: "Heart Icon"), for: .normal)
        likeButton.setImage(UIImage(named: "Heart Icon"), for: .highlighted)
        contentView.addSubview(likeButton)
        likeButton.addTarget(self, action: #selector(likeClick(_:)), for: .touchUpInside)
        
        contentView.addSubview(likeNumsLabel)
        likeNumsLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        likeNumsLabel.textColor = .white
        
        usernameButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        usernameButton.titleLabel?.textColor = .white
        
        commentButton.setImage(UIImage(named: "Message Icon"), for: .normal)
        contentView.addSubview(commentButton)
        commentButton.addTarget(self, action: #selector(commentClick(_:)), for: .touchUpInside)
        
        contentView.addSubview(commentNumsLabel)
        commentNumsLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        commentNumsLabel.textColor = .white
        
        shareButton.setImage(UIImage(named: "Share Icon"), for: .normal)
        contentView.addSubview(shareButton)
        shareButton.addTarget(self, action: #selector(shareClick(_:)), for: .touchUpInside)
        
        contentView.addSubview(shareNumsLabel)
        shareNumsLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        shareNumsLabel.textColor = .white
        
        markButton.tintColor = .white
        markButton.setImage(UIImage(named: "icons8-bookmark-25"), for: .normal)
        markButton.addTarget(self, action: #selector(bookClick(_:)), for: .touchUpInside)
        contentView.addSubview(markButton)
        
        contentView.addSubview(markNumsLabel)
        markNumsLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        markNumsLabel.textColor = .white
        
        //        productButton.backgroundColor = .black.withAlphaComponent(0.5)
        //        productButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        //        productButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -5)
        //        productButton.setImage(UIImage(named: "video_product"), for: .normal)
        //        storeButton.setTitleColor(.white, for: .normal)
        //        productButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        //        productButton.layer.cornerRadius = 4
        //        productButton.addTarget(self, action: #selector(productClick(_:)), for: .touchUpInside)
        //        contentView.addSubview(productButton)
        
        //        storeButton.backgroundColor = .black.withAlphaComponent(0.5)
        //        storeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        //        storeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -5)
        //        storeButton.setImage(UIImage(named: "video_store"), for: .normal)
        //        storeButton.setTitleColor(.white, for: .normal)
        //        storeButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        //        storeButton.layer.cornerRadius = 4
        //        storeButton.addTarget(self, action: #selector(storeClick(_:)), for: .touchUpInside)
        //        contentView.addSubview(storeButton)
        
        containerView.backgroundColor = .clear
        contentView.addSubview(containerView)
        
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.image = UIImage(named: "videoPlaceholder")
        iconImageView.layer.cornerRadius = 20
        iconImageView.layer.masksToBounds = true
        iconImageView.layer.borderWidth = 1.0
        iconImageView.layer.borderColor = UIColor.appColor(.white)?.cgColor
        
        label.text = "You reposted"
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
        
        smallIconImageView.contentMode = .scaleAspectFill
        smallIconImageView.tintColor = .white
        smallIconImageView.image = UIImage(systemName: "chevron.right")
        
        containerView.addSubview(smallIconImageView)
        containerView.addSubview(label)
        containerView.addSubview(iconImageView)
        containerView.isHidden = true
        
        descriptionTextView.textColor = .white
        descriptionTextView.delegate = self
        descriptionTextView.backgroundColor = .clear
        contentView.addSubview(descriptionTextView)
        
        usernameButton.addTarget(self, action: #selector(profileClick(_:)), for: .touchUpInside)
        contentView.addSubview(usernameButton)
        
        verifiedImage.contentMode = .scaleAspectFill
        contentView.addSubview(verifiedImage)
        
        
        //        locationButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        //        locationButton.setTitleColor(.white, for: .normal)
        //        storeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        //        locationButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -5)
        //        locationButton.setImage(UIImage(named: "vodeo_location"), for: .normal)
        //        locationButton.setImage(UIImage(named: "vodeo_location"), for: .highlighted)
        //        contentView.addSubview(locationButton)
        //        locationButton.addTarget(self, action: #selector(locationClick(_:)), for: .touchUpInside)
        //
        
        soundButton.clipsToBounds = true
        soundButton.layer.cornerRadius = 20
        //        soundButton.layer.borderWidth = 1
        soundButton.layer.borderColor = UIColor.appColor(.white)?.cgColor
        soundButton.setImage(UIImage(named: "soundButton"), for: .normal)
        contentView.addSubview(soundButton)
        soundButton.imageView?.contentMode = .scaleAspectFill
        soundButton.addTarget(self, action: #selector(soundClick(_:)), for: .touchUpInside)
        soundButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        soundButton.backgroundColor = .black
        if let imageView = soundButton.imageView {
            imageView.layer.cornerRadius = 11
            imageView.clipsToBounds = true
        }
        contentView.addSubview(attentionButton)
        attentionButton.setImage(UIImage(named: "Subscribe button"), for: .normal)
        attentionButton.clipsToBounds = true
        attentionButton.addTarget(self, action: #selector(attentionClick(_:)), for: .touchUpInside)
        
        setupConstraints()
    }
    
    func soundRotate() {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateAnimation.fromValue = 0
        rotateAnimation.toValue = 2 * Double.pi
        rotateAnimation.duration = 6
        rotateAnimation.repeatCount = .infinity
        
        // 可选：设置动画的填充模式，kCAFillModeForwards和isRemovedOnCompletion=false一起使用，可以让动画效果在结束时保持
        rotateAnimation.fillMode = CAMediaTimingFillMode.forwards
        rotateAnimation.isRemovedOnCompletion = false
        
        soundButton.layer.add(rotateAnimation, forKey: "rotateAnimation")
    }
    
    func setupConstraints() {
        
        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.centerX.equalTo(attentionButton)
            make.bottom.equalTo(attentionButton.snp.top).offset(9)
        }
        
        attentionButton.snp.makeConstraints { make in
            make.centerX.equalTo(soundButton)
            make.size.equalTo(18)
            make.bottom.equalTo(likeButton.snp.top).offset(-10)
        }
        
        likeButton.snp.makeConstraints { make in
            make.size.equalTo(CGSizeMake(35, 33.23))
            make.trailing.equalToSuperview().offset(-12.67)
            make.bottom.equalTo(likeNumsLabel.snp.top).offset(0)
        }
        
        likeNumsLabel.snp.makeConstraints { make in
            make.bottom.equalTo(commentButton.snp.top).offset(-10)
            make.centerX.equalTo(markButton)
        }
        
        commentButton.snp.makeConstraints { make in
            make.size.equalTo(CGSizeMake(35, 33.23))
            make.trailing.equalToSuperview().offset(-12.67)
            make.bottom.equalTo(commentNumsLabel.snp.top).offset(0)
        }
        
        commentNumsLabel.snp.makeConstraints { make in
            make.bottom.equalTo(markButton.snp.top).offset(-10)
            make.centerX.equalTo(markButton)
        }
        
        markButton.snp.makeConstraints { make in
            make.size.equalTo(CGSizeMake(35, 33.23))
            make.trailing.equalToSuperview().offset(-12.67)
            make.bottom.equalTo(markNumsLabel.snp.top).offset(0)
        }
        
        markNumsLabel.snp.makeConstraints { make in
            make.bottom.equalTo(shareButton.snp.top).offset(-10)
            make.centerX.equalTo(markButton)
        }
        
        shareButton.snp.makeConstraints { make in
            make.size.equalTo(CGSizeMake(34.08, 26.84))
            make.trailing.equalToSuperview().offset(-12.67)
            make.bottom.equalTo(shareNumsLabel.snp.top).offset(0)
        }
        
        shareNumsLabel.snp.makeConstraints { make in
            make.bottom.equalTo(soundButton.snp.top).offset(-10)
            make.centerX.equalTo(shareButton)
        }
        
        soundButton.snp.makeConstraints { make in
            make.centerX.equalTo(shareButton)
            make.width.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        //        productButton.snp.makeConstraints { make in
        //            make.leading.equalToSuperview().offset(16)
        //            make.height.equalTo(23)
        //            make.width.lessThanOrEqualTo(UIDevice.ex.screenWidth - 16.0 - 60.0)
        //            make.bottom.equalTo(storeButton.snp.top).offset(-8)
        //        }
        //
        //        storeButton.snp.makeConstraints { make in
        //            make.leading.equalToSuperview().offset(16)
        //            make.height.equalTo(23)
        //            make.width.lessThanOrEqualTo(UIDevice.ex.screenWidth - 16.0 - 60.0)
        //            make.bottom.equalTo(containerView.snp.top).offset(-8)
        //        }
        
        usernameButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(11)
            make.bottom.equalTo(descriptionTextView.snp.top).offset(-8)
        }
        
        verifiedImage.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.centerY.equalTo(usernameButton)
            make.leading.equalTo(usernameButton.snp.trailing).offset(4)
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(11)
            make.bottom.equalToSuperview().offset(-12)
            make.trailing.equalToSuperview().offset(-110)
            make.height.equalTo(0)
        }
        
        //        locationButton.snp.makeConstraints { make in
        //            make.leading.equalToSuperview().offset(12)
        //            make.width.lessThanOrEqualTo(UIDevice.ex.screenWidth - 12.0 - 60.0)
        //            make.bottom.equalToSuperview().offset(-16)
        //            make.height.equalTo(15)
        //        }
        
        containerView.snp.makeConstraints { make in
            make.bottom.equalTo(usernameButton.snp.top).offset(-8)
            make.leading.equalToSuperview().offset(11)
            make.height.equalTo(0)
        }
        
        
        smallIconImageView.snp.makeConstraints { make in
            make.width.equalTo(17)
            make.height.equalTo(17)
            make.leading.equalTo(label.snp.trailing).offset(8)
            make.centerY.equalTo(containerView)
        }
        
        label.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(8)
            make.centerY.equalTo(containerView)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.leading.equalTo(containerView.snp.leading).offset(0)
            make.centerY.equalTo(containerView)
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        coverImageView.frame = contentView.bounds
        bgImgView.frame = contentView.bounds
    }
    
    @objc func commentClick(_ sender: UIButton) {
        commentClickHandler?(indexPath)
    }
    
    @objc func profileClick(_ sender: UIButton) {
        profileClickHandler?(indexPath)
    }
    
    @objc func productClick(_ sender: UIButton) {
        
    }
    
    @objc func shareClick(_ sender: UIButton) {
        shareClickHandler?(indexPath)
    }
    
    @objc func storeClick(_ sender: UIButton) {
        
    }
    
    @objc func attentionClick(_ sender: UIButton) {
        
    }
    
    @objc func likeClick(_ sender: UIButton) {
        sender.isSelected =  !sender.isSelected
        if UserDefaultsManager.shared.user_id == "0" {
            self.likeClickHandler?(indexPath)
            if  let appdelegate = UIApplication.shared.delegate as? AppDelegate {
                appdelegate.presentLogin()
            }
        } else {
            
            if sender.isSelected {
                likeButton.setImage(UIImage(named: "Heart Icon 1"), for: .normal)
            } else {
                likeButton.setImage(UIImage(named: "Heart Icon"), for: .normal)
            }
            let likeNums = likeNumsLabel.text?.toInt() ?? 0
            likeNumsLabel.text = sender.isSelected ? "\(likeNums + 1)" : "\(likeNums - 1)"
            //            likeButton.setImage(UIImage(named: "Heart Icon 1"), for: .normal)
            likeClickHandler?(indexPath)
            
            
            
            
            //            let parameters =  [
            //                "user_id":UserDefaultsManager.shared.user_id,
            //                "video_id":"\(model?.video?.id ?? 0)"
            //            ]
            //
            //
            //            NetworkManager.shared.post(endpoint: "likeVideo", parameters: parameters) {(result: Result<LikeVideoResponse, Error>) in
            //                switch result {
            //                case .success(let response):
            //                    print("\(response)")
            //                case .failure(let error):
            //                    print("Error: \(error)")
            //                }
            //            }
        }
        
    }
    @objc func bookClick(_ sender: UIButton) {
        sender.isSelected =  !sender.isSelected
        
        if UserDefaultsManager.shared.user_id == "0" {
            self.markClickHandler?(indexPath)
            if  let appdelegate = UIApplication.shared.delegate as? AppDelegate {
                appdelegate.presentLogin()
            }
        } else {
            if sender.isSelected {
                markButton.setImage(UIImage(named: "State=Active"), for: .normal)
            } else {
                markButton.setImage(UIImage(named: "icons8-bookmark-25"), for: .normal)
            }
            
            let parameters = [
                "user_id":UserDefaultsManager.shared.user_id,
                "video_id":"\(model?.video?.id ?? 0)"
            ]
            
            let markNums = markNumsLabel.text?.toInt() ?? 0
            markNumsLabel.text = sender.isSelected ? "\(markNums + 1)" : "\(markNums - 1)"
            NetworkManager.shared.post(endpoint: "addVideoFavourite", parameters: parameters) {(result: Result<AddVideoFavouriteResponse, Error>) in
                switch result {
                case .success(let response):
                    print("\(response)")
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
    
    @objc func locationClick(_ sender: UIButton) {
        let video = model?.location
        let vc = LocationDetailViewController(nibName: "LocationDetailViewController", bundle: nil)
        
        vc.location_string = video?.string ?? ""
        vc.location_title = video?.name ?? ""
        vc.id = video?.id ?? 0
        vc.lat = video?.lat ?? ""
        vc.long = video?.long ?? ""
        vc.hidesBottomBarWhenPushed = true
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func soundClick(_ sender: UIButton) {
        if UserDefaultsManager.shared.user_id == "0" {
            if  let appdelegate = UIApplication.shared.delegate as? AppDelegate {
                appdelegate.presentLogin()
            }
        }else {
            let sound = model?.sound
            let vc = SoundDetailViewController(nibName: "SoundDetailViewController", bundle: nil)
            vc.soundUrl = sound?.audio ?? ""
            vc.soundName = sound?.name ?? ""
            vc.createdBy = sound?.description ?? ""
            vc.thum = sound?.thum ?? ""
            vc.sound_section_id = sound?.id ?? 0
            vc.hidesBottomBarWhenPushed = true
            UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func updataViewModel(data: HomeResponseMsg) {
        model = data
        if data.video?.width == 0 || data.video?.height == 0 {
            coverImageView.contentMode = .scaleAspectFill
        }else if data.video?.width ?? 0 >= data.video?.height ?? 0 {
            coverImageView.contentMode = .scaleAspectFit
        } else {
            coverImageView.contentMode = .scaleAspectFill
        }
        
        let thumbnailURLString = data.video?.thum ?? ""
        
        DataPersistence.shared.cacheLoad(urlString: thumbnailURLString) { result in
            switch(result) {
            case .success(let imageData):
                self.coverImageView.image = UIImage(data: imageData)
            case .failure(let error):
                print(error)
            }
        }
        
        if data.video?.like == 1 {
            likeButton.setImage(UIImage(named: "Heart Icon 1"), for: .normal)
        } else {
            likeButton.setImage(UIImage(named: "Heart Icon"), for: .normal)
        }
        
        if data.video?.favourite == 1 {
            markButton.setImage(UIImage(named: "State=Active"), for: .normal)
        } else {
            markButton.setImage(UIImage(named: "icons8-bookmark-25"), for: .normal)
        }
        
        likeNumsLabel.text = "\(data.video?.likeCount ?? 0)"
        commentNumsLabel.text = "\(data.video?.commentCount ?? 0)"
        markNumsLabel.text = "\(data.video?.favouriteCount ?? 0)"
        shareNumsLabel.text = "\(data.video?.share ?? 0)"
        profileImageView.sd_setImage(with: URL(string: data.user?.profilePic ?? ""))
        soundButton.sd_setImage(with: URL(string: data.sound?.thum ?? ""), for: .normal)
        
        //        if let locationName = data.location?.name,!locationName.isEmpty {
        //            locationButton.setTitle(locationName, for: .normal)
        //            locationButton.isHidden = false
        //        } else {
        //            locationButton.isHidden = true
        //        }
        
        if let button = data.user?.button {
            if button == "Follow" || button == "follow" {
                attentionButton.isHidden = false
            }else {
                attentionButton.isHidden = true
            }
        }
        
        let attributedString = detectHashTagsAndMentions(in: data.video?.description ?? "")
        descriptionTextView.attributedText = attributedString
        descriptionTextView.font = UIFont.systemFont(ofSize: 12)
        descriptionTextView.isEditable = false
        descriptionTextView.tintColor = .white
        descriptionTextView.isSelectable = true
        descriptionTextView.dataDetectorTypes = .link
        descriptionTextView.textColor = .white
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        descriptionTextView.textContainer.lineFragmentPadding = 0
        updateTextViewHeight()
        soundRotate()
        
        //        if let name = model?.store?.name {
        //            storeButton.isHidden = false
        //            storeButton.setTitle(name, for: .normal)
        //            storeButton.snp.updateConstraints { make in
        //                make.height.equalTo(23.0)
        //            }
        //        } else {
        //            storeButton.isHidden = true
        //            storeButton.snp.updateConstraints { make in
        //                make.height.equalTo(0)
        //            }
        //        }
        
        if let username = data.user?.username {
            usernameButton.setTitle(username, for: .normal)
        }
        
        if let verified = data.user?.verified {
            verifiedImage.isHidden = verified == 0
        }
        
        if let repost = model?.video?.repost {
            if repost == 0 {
                containerView.isHidden = true
                containerView.snp.updateConstraints { make in
                    make.height.equalTo(0)
                }
            }else {
                containerView.isHidden = false
                iconImageView.sd_setImage(with: URL(string:(UserDefaultsManager.shared.profileUser)), placeholderImage: UIImage(named: "videoPlaceholder"))
                containerView.snp.updateConstraints { make in
                    make.height.equalTo(40.0)
                }
            }
        }else {
            containerView.isHidden = true
            containerView.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
        }
        
        //        if let title = model?.product?.title {
        //            productButton.isHidden = false
        //            productButton.setTitle(title, for: .normal)
        //            productButton.snp.updateConstraints { make in
        //                make.height.equalTo(23.0)
        //            }
        //        } else {
        //            productButton.isHidden = true
        //            productButton.snp.updateConstraints { make in
        //                make.height.equalTo(0)
        //            }
        //        }
        
        //        coverImageView.setImageWithURLString(data.video?.thum, placeholder: UIImage(named: "loading_bgView"))
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
    
    func updateTextViewHeight() {
        if descriptionTextView.attributedText.string.isEmpty {
            descriptionTextView.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
        } else {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
            ]
            let attributedString = NSAttributedString(string: descriptionTextView.attributedText.string, attributes: attributes)
            let height = calculateAttributedTextHeight(for: attributedString, width: UIDevice.ex.screenWidth - 16 - 60)
            //            let height = calculateTextHeight(for: attributedString, in: UIDevice.ex.screenWidth - 16 - 60)
            descriptionTextView.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
        }
    }
    
    func calculateAttributedTextHeight(for attributedText: NSAttributedString, width: CGFloat) -> CGFloat {
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        
        let boundingRect = attributedText.boundingRect(with: size, options: options, context: nil)
        
        return ceil(boundingRect.height)
    }
}

extension LVideoPlayerCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateTextViewHeight()
    }
    
    
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if let urlComponents = URLComponents(url: URL, resolvingAgainstBaseURL: false),
           let scheme = urlComponents.scheme,
           let path = urlComponents.path.removingPercentEncoding {
            
            if scheme == "hashtag" {
                let hashtag = String(path.dropFirst())
                print("Hashtag tapped: \(hashtag)")
                if UserDefaultsManager.shared.user_id == "0" {
                    if  let appdelegate = UIApplication.shared.delegate as? AppDelegate {
                        appdelegate.presentLogin()
                    }
                }else {
                    let myViewController = HashtagViewController(nibName: "HashtagViewController", bundle: nil)
                    myViewController.hashtag = hashtag
                    myViewController.hidesBottomBarWhenPushed = true
                    UIApplication.topViewController()?.navigationController?.pushViewController(myViewController, animated: true)
                }
                
                // Handle hashtag tap
            } else if scheme == "mention" {
                let mention = String(path.dropFirst())
                print("Mention tapped: \(mention)")
                
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myViewController = storyboard.instantiateViewController(withIdentifier: "OtherProfileViewController")as! OtherProfileViewController
                myViewController.mention = mention
                myViewController.isVideoTag = true
                myViewController.hidesBottomBarWhenPushed = true
                UIApplication.topViewController()?.navigationController?.pushViewController(myViewController, animated: true)
                
            }
        }
        
        return false
    }
}
