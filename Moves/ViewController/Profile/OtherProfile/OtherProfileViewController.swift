//
//  OtherProfileViewController.swift
// //
//
//  Created by Wasiq Tayyab on 23/06/2024.
//

import UIKit
import SkeletonView
import ZoomingTransition
import SDWebImage
class OtherProfileViewController: ZoomingPushVC {
    var lastSelectedIndexPath: IndexPath? = nil
    var allArray: [HomeResponseMsg] = []
    var mainArr: ShowVideosAgainstUserIDResponse?
    var thirdArr : HomeResponse?
    var showOrderPlacedVideos: HomeResponse?
    var showFavouriteVideos: HomeResponse?
    var viewModel = ProfileViewModel()
    var userResponse : HomeUser?
    
    private var blockViewModel = BlockUserViewModel()
    private var viewModel1 = NotificaitonViewModel()
    var userItem = [["Image":"Icons 1","isSelected":"true"],
                    ["Image":"Bookmark 1","isSelected":"false"]]
    private let footerView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    var otherUserId = ""
    var type = "Video"
    var website = ""
    var isDataLoading:Bool = false
    var callback: ((_ user: HomeUser) -> Void)?
    private var viewModel2 = OtherProfileViewModel()
    var storeSelectedIP = IndexPath(item: 0, section: 0)
    private var viewBlockModel = BlockUserViewModel()
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(named:"theme")!
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        
        return refreshControl
    }()
    
    var startVideoPoint = 0
    var startTaggedPoint = 0
    var startPageOrderPoint = 0
    var startPageFavoritePoint = 0
    
    var isNextPageVideoLoad = false
    var isNextPageTaggedLoad = false
    var isNextPageOrderPlaceLoad = false
    var isNextPageFavoriteLoad = false
    
    var isVideoTag = false
    var mention = ""
    
    @IBOutlet weak var scrollViewOutlet: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tickStackView: UIStackView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var imgProfile: CustomImageView!
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var lblFollowing: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lblLikes: UILabel!
    
    @IBOutlet weak var btnArroDown: CustomButton!
    @IBOutlet weak var btnMessage: CustomButton!
    @IBOutlet weak var btnFollow: CustomButton!
    
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var suggestionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewSuggestion: UIView!
    @IBOutlet weak var suggestedCollectionView: UICollectionView!
    
    
    @IBOutlet weak var privateVideoView: UIView!
    
    @IBOutlet weak var videoCollectionView: UICollectionView!
    @IBOutlet weak var headerCollectionView: UICollectionView!
    
    @IBOutlet weak var lblWebsite: UILabel!
    @IBOutlet weak var lblNoDataDescription: UILabel!
    @IBOutlet weak var lblNoData: UILabel!
    
    @IBOutlet weak var lblBlockContent: UILabel!
    @IBOutlet weak var lblBlock: UILabel!
    
    @IBOutlet weak var cvView: UIView!
    @IBOutlet weak var uperViewHeightConst: NSLayoutConstraint!
    
    
    @IBOutlet weak var profileView: UIView!
    
    @IBOutlet weak var lableStack: UIStackView!
    
    @IBOutlet var lottieAnimation: UIView!
    
    @IBOutlet weak var followStackView: UIStackView!
    @IBOutlet weak var buttonStack: UIStackView!
    
    @IBOutlet weak var lblBlockUser: UILabel!
    
    @IBOutlet weak var blockUserView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
    }
    
    
    func animationPlay() {
        if let jeremyGif = UIImage.gifImageWithName("animation") {
            let imageView = UIImageView(image: jeremyGif)
            imageView.contentMode = .scaleAspectFill
            lottieAnimation.addSubview(imageView)
            
            // Speed up the GIF by reducing animation duration
            imageView.animationImages = jeremyGif.images
            imageView.animationDuration = (jeremyGif.duration) / 4.0 // Double speed
            imageView.startAnimating()
            
            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        } else {
            print("GIF could not be loaded.")
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
    }
    
    //MARK: setupView
    func setupView(){
        if isVideoTag {
            self.view.showAnimatedGradientSkeleton()
            let showUserDetail = CheckUsernameRequest(username: mention)
            self.viewModel2.showOtherUserDetailForUsername(parameters: showUserDetail)
            observeEvent2()
        }else {
            self.login(msg: userResponse!)
            self.configuration()
        }
    }
    //MARK: LOGIN
    private func login(msg: HomeUser) {
        
        print("msg",msg.block)
        self.userResponse = msg
        let user = msg
        
        self.lblName.text = user.username
        self.lblUsername.text = "@" + (user.username ?? "")
        
        if let bio = user.bio, !bio.isEmpty {
            self.lblDescription.isHidden = false
            self.lblDescription.text = bio
        } else {
            self.lblDescription.isHidden = true
        }
        
        if let website = user.website, !website.isEmpty {
            self.lblWebsite.isHidden = false
            self.lblWebsite.text = website
            self.website = website
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            lblWebsite.addGestureRecognizer(tapGesture)
            lblWebsite.isUserInteractionEnabled = true
        } else {
            self.lblWebsite.isHidden = true
        }
        
        let likeCount = Utility.shared.formatPointsInt(num: user.likesCount ?? 0)
        self.lblLikes.text = likeCount
        
        let followersCount = Utility.shared.formatPointsInt(num: user.followersCount ?? 0)
        self.lblFollowers.text = followersCount
        
        let followingCount = Utility.shared.formatPointsInt(num: user.followingCount ?? 0)
        self.lblFollowing.text = followingCount
        
        self.imgProfile.sd_setImage(with: URL(string: user.profilePic ?? ""), placeholderImage: UIImage(named: "profile1"))
        
        
        if msg.block == 0 || msg.block == nil {
            self.animationPlay()
            enableUserInteraction(in: self.mainView)
            initViewModel(startingPoint: 0)
            self.blockUserView.isHidden = true
            if user.button == "follow" || user.button == "Follow" || user.button == nil {
                self.btnFollow.setTitle("Follow", for: .normal)
                self.btnMessage.isHidden = true
            } else {
                self.btnFollow.setTitle("Following", for: .normal)
                self.btnFollow.backgroundColor = UIColor.appColor(.buttonColor)
                self.btnFollow.setTitleColor(UIColor.appColor(.black), for: .normal)
                self.btnMessage.isHidden = false
            }
        }else {
            self.lblBlockUser.text = "You have blocked \(self.userResponse?.username ?? "")"
            self.headerCollectionView.isHidden = false
            self.btnFollow.setTitle("Unblock", for: .normal)
            self.btnFollow.backgroundColor = UIColor.appColor(.theme)
            self.btnFollow.setTitleColor(UIColor.appColor(.white), for: .normal)
            self.btnMessage.isHidden = true
            disableUserInteraction(in: self.mainView,except: headerCollectionView, and: followStackView)
            self.blockUserView.isHidden = false
        }
        
        
        
    }
    
    
    
    func disableUserInteraction(in view: UIView, except collectionView: UICollectionView?, and enabledStack: UIStackView?) {
        for subview in view.subviews {
            if subview === collectionView || subview === enabledStack {
                subview.isUserInteractionEnabled = false
            } else {
                subview.isUserInteractionEnabled = true
                disableUserInteraction(in: subview, except: collectionView, and: enabledStack)
            }
        }
    }
    
    
    func enableUserInteraction(in view: UIView) {
        for subview in view.subviews {
            subview.isUserInteractionEnabled = true
            enableUserInteraction(in: subview) // Recursively enable subviews
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let myviewController = WebViewController(nibName: "WebViewController", bundle: nil)
        myviewController.myUrl = website
        myviewController.linkTitle = "Website"
        myviewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(myviewController, animated: true)
    }
    
    @objc func requestData() {
        print("Requesting data")
        
        for index in self.userItem.indices {
            self.userItem[index]["isSelected"] = "false"
        }
        
        if let firstItem = self.userItem.first {
            var updatedItem = firstItem
            updatedItem["isSelected"] = "true"
            self.userItem[0] = updatedItem
        }
        
        self.headerCollectionView.reloadData()
        
        self.type = "Video"
        mainArr?.msg?.msgPublic.removeAll()
        mainArr?.msg?.msgPrivate.removeAll()
        showOrderPlacedVideos?.msg?.removeAll()
        
        let request = ShowUserOtherDetailRequest(userId: UserDefaultsManager.shared.user_id, otherUserId: self.otherUserId)
        viewModel.showOtherUserDetail(parameters: request)
        
        initViewModel(startingPoint: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
            self.refresher.endRefreshing()
        }
    }
    
    
    @objc func StoreSelectedIndex(index:Int){
        var obj  =  self.userItem[index]
        obj.updateValue("true", forKey: "isSelected")
        self.userItem.remove(at: index)
        self.userItem.insert(obj, at: index)
        print("index",index)
        self.privateVideoView.isHidden = true
        
        if index == 0{
            self.type = "Video"
            if let msgPublicCount = viewModel.showVideosAgainstUserID?.msg?.msgPublic.count, msgPublicCount != 0 {
                self.videoCollectionView.isHidden = false
                self.isNextPageVideoLoad = msgPublicCount >= 10
                self.privateVideoView.isHidden = true
                self.mainArr?.msg?.msgPublic.removeAll()
                self.mainArr = viewModel.showVideosAgainstUserID
                
                self.videoCollectionView.reloadData()
                let height = self.videoCollectionView.collectionViewLayout.collectionViewContentSize.height
                self.uperViewHeightConst.constant = height
                self.cvView.layoutIfNeeded()
                self.view.layoutIfNeeded()
                self.videoCollectionView.reloadData()
            }else {
                self.videoCollectionView.isHidden = true
                self.privateVideoView.isHidden = false
                self.lblNoData.text = "No Data Found"
                self.lblNoDataDescription.text = "You have not posted any video yet"
            }
            
        }
        //        else if index == 1{
        //            self.type = "Tagged"
        //
        //            if let taggedVideosCount = viewModel.showTaggedVideosAgainstUserID?.msg?.count, taggedVideosCount != 0 {
        //                self.videoCollectionView.isHidden = false
        //                self.isNextPageTaggedLoad = taggedVideosCount >= 10
        //                self.privateVideoView.isHidden = true
        //                self.thirdArr?.msg?.removeAll()
        //                self.thirdArr = viewModel.showTaggedVideosAgainstUserID
        //
        //                self.videoCollectionView.reloadData()
        //                let height = self.videoCollectionView.collectionViewLayout.collectionViewContentSize.height
        //                self.uperViewHeightConst.constant = height
        //                self.cvView.layoutIfNeeded()
        //                self.view.layoutIfNeeded()
        //                self.videoCollectionView.reloadData()
        //
        //            } else {
        //                self.videoCollectionView.isHidden = true
        //                self.privateVideoView.isHidden = false
        //                self.lblNoData.text = "No Data Found"
        //                self.lblNoDataDescription.text = "You have not tagged any video yet"
        //
        //            }
        //
        //        }else if index == 2{
        //            self.type = "OrderPlace"
        //
        //            if let orderPlace = viewModel.showOrderPlacedVideos?.msg?.count, orderPlace != 0 {
        //                self.videoCollectionView.isHidden = false
        //                self.isNextPageOrderPlaceLoad = orderPlace >= 10
        //                self.privateVideoView.isHidden = true
        //                self.showOrderPlacedVideos?.msg?.removeAll()
        //                self.showOrderPlacedVideos = viewModel.showOrderPlacedVideos
        //
        //                self.videoCollectionView.reloadData()
        //                let height = self.videoCollectionView.collectionViewLayout.collectionViewContentSize.height
        //                self.uperViewHeightConst.constant = height
        //                self.cvView.layoutIfNeeded()
        //                self.view.layoutIfNeeded()
        //                self.videoCollectionView.reloadData()
        //            }else {
        //                self.videoCollectionView.isHidden = true
        //                self.privateVideoView.isHidden = false
        //                self.lblNoData.text = "No Data Found"
        //                self.lblNoDataDescription.text = "You have not any order yet"
        //            }
        
        else {
            self.type = "Favorite"
            if let favorite = viewModel.showFavouriteVideos?.msg?.count, favorite != 0 {
                self.videoCollectionView.isHidden = false
                self.isNextPageFavoriteLoad = favorite >= 10
                self.privateVideoView.isHidden = true
                self.showFavouriteVideos?.msg?.removeAll()
                self.showFavouriteVideos = viewModel.showFavouriteVideos
                
                self.videoCollectionView.reloadData()
                let height = self.videoCollectionView.collectionViewLayout.collectionViewContentSize.height
                self.uperViewHeightConst.constant = height
                self.cvView.layoutIfNeeded()
                self.view.layoutIfNeeded()
                self.videoCollectionView.reloadData()
            }else {
                self.videoCollectionView.isHidden = true
                self.privateVideoView.isHidden = false
                self.lblNoData.text = "No Data Found"
                self.lblNoDataDescription.text = "You have not any video favourite yet"
            }
            
            
        }
        self.headerCollectionView.reloadData()
    }
    
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        guard let user = self.userResponse else { return }
        callback?(user)
        
    }
    
    @IBAction func viewAllButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        let myViewController = VideoShareViewController(nibName: "VideoShareViewController", bundle: nil)
        myViewController.profileId = userResponse?.id ?? 0
        myViewController.block = userResponse?.block ?? 0
        myViewController.blockUser = { [self] block -> Void in
            print("callback")
            if block == 0 {
                self.enableUserInteraction(in: self.mainView)
                self.blockUserView.isHidden = true
                self.userResponse?.block = 0
                self.userResponse = self.userResponse
                
                self.login(msg: self.userResponse!)
            }else {
                disableUserInteraction(in: self.mainView,except: self.headerCollectionView, and: self.followStackView)
                self.blockUserView.isHidden = false
                self.lblBlockUser.text = "You have blocked \(self.userResponse?.username ?? "")"
                self.userResponse?.block = 1
                self.userResponse = self.userResponse
                
                self.login(msg: self.userResponse!)
            }
            
            let blockUser = BlockUserRequest(userId: UserDefaultsManager.shared.user_id, blockUserId: self.userResponse?.id?.toString() ?? "")
            self.blockViewModel.blockUser(parameters: blockUser)
            print("blockUser",blockUser)
            self.privateObserveEvent()
        }
        myViewController.hidesBottomBarWhenPushed = true
        let nav = UINavigationController.init(rootViewController: myViewController)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(nav, animated: true)
    }
    
    @IBAction func followingButtonPressed(_ sender: UIButton) {
        if sender.tag == 0 {
            
            let myViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FriendsViewController")as! FriendsViewController
            myViewController.hidesBottomBarWhenPushed = true
            myViewController.username = userResponse?.username ?? ""
            myViewController.otherUserId = otherUserId
            myViewController.selectedMenu = "Following"
            self.navigationController?.pushViewController(myViewController, animated: true)
            
        }else if sender.tag == 1 {
            
            let myViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FriendsViewController")as! FriendsViewController
            myViewController.hidesBottomBarWhenPushed = true
            myViewController.otherUserId = otherUserId
            myViewController.username = userResponse?.username ?? ""
            myViewController.selectedMenu = "Followers"
            self.navigationController?.pushViewController(myViewController, animated: true)
            
        }else {
            let myViewController = LikesViewController(nibName: "LikesViewController", bundle: nil)
            myViewController.username = userResponse?.username ?? ""
            myViewController.likes_count = userResponse?.likesCount?.toString() ?? ""
            myViewController.modalPresentationStyle = .overFullScreen
            self.navigationController?.present(myViewController, animated: false, completion: nil)
        }
    }
    
    @IBAction func followButtonPressed(_ sender: UIButton) {
        if sender.titleLabel?.text == "Unblock" {
            
            let blockUser = BlockUserRequest(userId: UserDefaultsManager.shared.user_id, blockUserId: self.otherUserId)
            viewBlockModel.blockUser(parameters: blockUser)
            print("blockUser", blockUser)
            observeEvent3()
            
            self.userResponse?.block = 0
            self.login(msg: userResponse!)
            
            return
        }
        if sender.tag == 0 {
            if otherUserId == nil || otherUserId == "0" {
                Utility.showMessage(message: "Something went wrong. Please try later", on: self.view)
                return
            }
            DispatchQueue.global(qos: .userInitiated).async {
                let followUser = FollowUserRequest(senderId: UserDefaultsManager.shared.user_id.toInt() ?? 0, receiverId: self.otherUserId.toInt() ?? 0)
                self.viewModel1.followUser(parameters: followUser)
                print("followUserRequest", followUser)
                DispatchQueue.main.async {
                    self.observeEvent1()
                }
            }
            var butt = ""
            if self.btnFollow.titleLabel?.text == "Follow" {
                butt = "Following"
                self.btnFollow.setTitle("Following", for: .normal)
                self.btnFollow.backgroundColor = UIColor.appColor(.buttonColor)
                self.btnFollow.setTitleColor(UIColor.appColor(.black), for: .normal)
                
                self.btnMessage.isHidden = false
            }else if self.btnFollow.titleLabel?.text == "Following" {
                butt = "Follow"
                self.btnFollow.setTitle("Follow", for: .normal)
                self.btnFollow.backgroundColor = UIColor.appColor(.theme)
                self.btnFollow.setTitleColor(UIColor.appColor(.white), for: .normal)
                
                self.btnMessage.isHidden = true
            }else {
                butt = "Follow"
                self.btnMessage.isHidden = true
                self.btnFollow.setTitle("Follow", for: .normal)
                self.btnFollow.backgroundColor = UIColor.appColor(.theme)
                self.btnFollow.setTitleColor(UIColor.appColor(.white), for: .normal)
            }
            
            userResponse?.button = butt
        }else {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationController = storyboard.instantiateViewController(withIdentifier: "newChatViewController") as! newChatViewController
            
            destinationController.modalPresentationStyle = .fullScreen
            destinationController.senderName = UserDefaultsManager.shared.username
            destinationController.senderID =  UserDefaultsManager.shared.user_id
            destinationController.profile_url = UserDefaultsManager.shared.profileUser
            destinationController.receiverID =  userResponse?.id?.toString() ?? ""
            destinationController.receiverName = userResponse?.username ?? ""
            destinationController.receiver_profile_url = userResponse?.profilePic ?? ""
            self.navigationController?.pushViewController(destinationController, animated: true)
        }
    }
    
}

//MARK: - COLLECTION VIEW
extension OtherProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == headerCollectionView {
            return userItem.count
        }else {
            if type == "Video" {
                return mainArr?.msg?.msgPublic.count ?? 0
            }else if type == "Tagged"{
                return thirdArr?.msg?.count ?? 0
                
            }else if type == "OrderPlace" {
                return showOrderPlacedVideos?.msg?.count ?? 0
            }else {
                return showFavouriteVideos?.msg?.count ?? 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath) as! CollectionViewFooterView
            footer.addSubview(footerView)
            footerView.frame = footer.bounds
            return footer
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == headerCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCollectionViewCell", for: indexPath)as! ProfileCollectionViewCell
            cell.imgIcon.image = UIImage(named: self.userItem[indexPath.row]["Image"] ?? "")
            if self.userItem[indexPath.row]["isSelected"] == "true" {
                cell.imgIcon.tintColor = .black
                cell.lineview.isHidden = false
            }else {
                cell.imgIcon.tintColor = UIColor.appColor(.darkGrey)
                cell.lineview.isHidden = true
            }
            
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoProfileCollectionViewCell", for: indexPath)as! VideoProfileCollectionViewCell
            if type == "Video"{
                let video = mainArr?.msg?.msgPublic[indexPath.row].video
                let thum = video?.thum ?? ""
                cell.videoView.sd_setImage(with: URL(string: thum), placeholderImage: UIImage(named: ""), options: .continueInBackground, completed: { [weak cell] image, _, _, _ in
                    guard let cell = cell, let image = image else { return }
                    UIView.transition(with: cell.videoView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        cell.videoView.image = image
                    }, completion: nil)
                })
                cell.lblView.text = video?.view?.toString()
                cell.pinnedview.isHidden = true
            }else  if type == "Tagged"{
                let video = thirdArr?.msg?[indexPath.row].video
                let thum = video?.thum ?? ""
                cell.videoView.sd_setImage(with: URL(string: thum), placeholderImage: UIImage(named: ""), options: .continueInBackground, completed: { [weak cell] image, _, _, _ in
                    guard let cell = cell, let image = image else { return }
                    UIView.transition(with: cell.videoView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        cell.videoView.image = image
                    }, completion: nil)
                })
                cell.lblView.text = video?.view?.toString()
            }else if type == "OrderPlace"{
                let video = showOrderPlacedVideos?.msg?[indexPath.row].video
                let thum = video?.thum ?? ""
                cell.videoView.sd_setImage(with: URL(string: thum), placeholderImage: UIImage(named: ""), options: .continueInBackground, completed: { [weak cell] image, _, _, _ in
                    guard let cell = cell, let image = image else { return }
                    UIView.transition(with: cell.videoView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        cell.videoView.image = image
                    }, completion: nil)
                })
                cell.lblView.text = video?.view?.toString()
            }else {
                let video = showFavouriteVideos?.msg?[indexPath.row].video
                let thum = video?.thum ?? ""
                cell.videoView.sd_setImage(with: URL(string: thum), placeholderImage: UIImage(named: ""), options: .continueInBackground, completed: { [weak cell] image, _, _, _ in
                    guard let cell = cell, let image = image else { return }
                    UIView.transition(with: cell.videoView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        cell.videoView.image = image
                    }, completion: nil)
                })
                cell.lblView.text = video?.view?.toString()
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if type == "Video"{
            for indexPath in indexPaths {
                let video = mainArr?.msg?.msgPublic[indexPath.row].video
                if let thum = video?.thum, let url = URL(string: thum) {
                    SDWebImagePrefetcher.shared.prefetchURLs([url])
                }
            }
        }else if type == "Tagged"{
            for indexPath in indexPaths {
                let video = thirdArr?.msg?[indexPath.row].video
                if let thum = video?.thum, let url = URL(string: thum) {
                    SDWebImagePrefetcher.shared.prefetchURLs([url])
                }
            }
        }else if type == "OrderPlace"{
            for indexPath in indexPaths {
                let video = showOrderPlacedVideos?.msg?[indexPath.row].video
                if let thum = video?.thum, let url = URL(string: thum) {
                    SDWebImagePrefetcher.shared.prefetchURLs([url])
                }
            }
        }else {
            for indexPath in indexPaths {
                let video = showFavouriteVideos?.msg?[indexPath.row].video
                if let thum = video?.thum, let url = URL(string: thum) {
                    SDWebImagePrefetcher.shared.prefetchURLs([url])
                }
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == headerCollectionView {
            return CGSize(width: collectionView.frame.width/2, height: 42)
        }else {
            return CGSize(width: collectionView.frame.width/3-1, height: 230)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == headerCollectionView{
            
            for i in 0..<self.userItem.count {
                var obj  = self.userItem[i]
                obj.updateValue("false", forKey: "isSelected")
                self.userItem.remove(at: i)
                self.userItem.insert(obj, at: i)
                
            }
            
            self.StoreSelectedIndex(index: indexPath.row)
            self.storeSelectedIP = indexPath
        }else {
            self.lastSelectedIndexPath = indexPath
            let videoDetail = VideoDetailController()
            if type == "Video"{
                allArray = (mainArr?.msg!.msgPublic)!
            }else {
                allArray = (showFavouriteVideos?.msg)!
            }
            videoDetail.dataSource = allArray
            videoDetail.index = indexPath.row
            videoDetail.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(videoDetail, animated: true)
        }
        
    }
    
}

extension OtherProfileViewController {
    
    func configuration() {
        self.scrollViewOutlet.delegate = self
        if #available(iOS 10.0, *) {
            scrollViewOutlet.refreshControl = refresher
        } else {
            scrollViewOutlet.addSubview(refresher)
        }
        
        headerCollectionView.delegate = self
        headerCollectionView.dataSource = self
        videoCollectionView.delegate = self
        videoCollectionView.dataSource = self
        
        videoCollectionView.register(UINib(nibName: "VideoProfileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VideoProfileCollectionViewCell")
        
        videoCollectionView.register(CollectionViewFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        (videoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: videoCollectionView.bounds.width, height: 50)
        footerView.color = UIColor(named: "theme")
        footerView.hidesWhenStopped = true
        
        
    }
    
    func initViewModel(startingPoint: Int) {
        let dispatchGroup = DispatchGroup()
        if startingPoint == 0 {
            dispatchGroup.enter()
            let showVideosAgainstUserID = ShowVideosAgainstUserIDRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: startingPoint, otherUserId: self.otherUserId)
            viewModel.showVideosAgainstUserID(parameters: showVideosAgainstUserID)
            dispatchGroup.leave()
            
            dispatchGroup.enter()
            let favourite = FriendsRequest(userId: self.otherUserId, startingPoint: startingPoint, otherUserId: "")
            viewModel.showFavouriteVideos(parameters: favourite)
            dispatchGroup.leave()
        }else {
            if type == "Video" {
                let showVideosAgainstUserID = ShowVideosAgainstUserIDRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: startingPoint, otherUserId: self.otherUserId)
                viewModel.showVideosAgainstUserID(parameters: showVideosAgainstUserID)
            }else {
                let favourite = FriendsRequest(userId: self.otherUserId, startingPoint: startingPoint, otherUserId: "")
                viewModel.showFavouriteVideos(parameters: favourite)
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.observeEvent()
        }
    }
    
    func observeEvent() {
        viewModel.eventHandler = { [weak self] event in
            guard let self else { return }
            
            switch event {
            case .error(let error):
                print("error",error)
                DispatchQueue.main.async {
                    if let error = error {
                        if let dataError = error as? Moves.DataError {
                            switch dataError {
                            case .invalidResponse:
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .invalidURL:
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .network(_):
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .invalidData:
                                print("invalidData")
                            case .decoding(_):
                                print("decoding")
                            }
                        } else {
                            if isDebug {
                                Utility.showMessage(message: "Something went wrong. Please try again", on: self.view)
                            }
                        }
                    }
                }
            case .newShowUserDetail(showUserDetail: _):
                print("showUserDetail.msg")
                
                
            case .newShowVideosAgainstUserID(showVideosAgainstUserID: let showVideosAgainstUserID):
                if showVideosAgainstUserID.code == 200 {
                    DispatchQueue.main.async {
                        // Animate the hiding of lottieAnimation
                        UIView.animate(withDuration: 0.3, animations: {
                            self.lottieAnimation.alpha = 0
                        }) { _ in
                            self.lottieAnimation.isHidden = true
                            
                            self.headerCollectionView.isHidden = false
                            
                            if let newVideos = showVideosAgainstUserID.msg?.msgPublic, !newVideos.isEmpty {
                                if self.startVideoPoint == 0 {
                                    self.mainArr?.msg?.msgPublic.removeAll()
                                    self.viewModel.showVideosAgainstUserID = showVideosAgainstUserID
                                    self.mainArr = showVideosAgainstUserID
                                } else {
                                    self.viewModel.showVideosAgainstUserID?.msg?.msgPublic.append(contentsOf: newVideos)
                                    self.mainArr?.msg?.msgPublic.append(contentsOf: newVideos)
                                }
                                
                                self.isNextPageVideoLoad = (self.mainArr?.msg?.msgPublic.count ?? 0) >= 10
                                self.videoCollectionView.reloadData()
                                
                                let height = self.videoCollectionView.collectionViewLayout.collectionViewContentSize.height
                                self.uperViewHeightConst.constant = height
                                self.videoCollectionView.layoutIfNeeded()
                                self.view.layoutIfNeeded()
                                
                            } else {
                                // Display message if no videos are found
                                if self.startVideoPoint == 0 {
                                    self.viewModel.showVideosAgainstUserID?.msg?.msgPublic.removeAll()
                                    self.mainArr?.msg?.msgPublic.removeAll()
                                    self.privateVideoView.isHidden = false
                                    self.lblNoData.text = "No Data Found"
                                    self.lblNoDataDescription.text = "You have not posted any video yet"
                                }
                                self.isNextPageVideoLoad = false
                            }
                        }
                    }
                }
                
            case .newShowUserLikedVideos(showUserLikedVideos: _):
                print("showUserLikedVideos")
                
            case .newShowFavouriteVideos(showFavouriteVideos: let showFavouriteVideos):
                if showFavouriteVideos.code == 200 {
                    if startPageFavoritePoint == 0 {
                        self.showFavouriteVideos?.msg?.removeAll()
                        self.showFavouriteVideos = showFavouriteVideos
                        viewModel.showFavouriteVideos = showFavouriteVideos
                    } else {
                        if let newMessages = showFavouriteVideos.msg {
                            self.showFavouriteVideos?.msg?.append(contentsOf: newMessages)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.isNextPageFavoriteLoad = (self.showFavouriteVideos?.msg?.count ?? 0) >= 10
                    }
                    
                } else {
                    if startPageFavoritePoint == 0 {
                        self.viewModel.showFavouriteVideos?.msg?.removeAll()
                        self.showFavouriteVideos?.msg?.removeAll()
                    }
                    self.isNextPageFavoriteLoad = false
                }
            case .newShowOtherUserDetail(showOtherUserDetail: let showOtherUserDetail):
                
                print("showOtherUserDetail")
            case .newDeleteVideo(deleteVideo: _):
                print("deleteVideo")
            case .newWithdrawRequest(withdrawRequest: _):
                print("withdrawRequest")
            case .newShowPayout(showPayout: _):
                print("showPayout")
            case .newShowStoreTaggedVideos(showStoreTaggedVideos: _):
                print("showStoreTaggedVideos")
            case .newShowPrivateVideosAgainstUserID(showPrivateVideosAgainstUserID: _):
                print("showPrivateVideosAgainstUserID")
                
            case .showUserRepostedVideos(showUserRepostedVideos: let showUserRepostedVideos):
                print("showUserRepostedVideos")
            }
        }
        
    }
    
    func observeEvent3() {
        viewBlockModel.eventHandler = { [weak self] event in
            guard let self else { return }
            
            switch event {
            case .error(let error):
                print("error", error)
                DispatchQueue.main.async {
                    if let error = error {
                        if let dataError = error as? Moves.DataError {
                            switch dataError {
                            case .invalidResponse:
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .invalidURL:
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .network:
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .invalidData:
                                print("invalidData")
                            case .decoding:
                                print("decoding")
                            }
                        } else {
                            if isDebug {
                                Utility.showMessage(message: "Something went wrong. Please try again", on: self.view)
                            }
                        }
                    }
                }
            case .newShowBlockedUsers(_):
                break
            case .newBlockUser(_):
                break
            case .newShowFavouriteVideos(showFavouriteVideos: let showFavouriteVideos):
                print("showFavouriteVideos")
            }
        }
    }
    
    
    
    
    func observeEvent1() {
        viewModel1.eventHandler = { [weak self] event in
            guard let self else { return }
            
            switch event {
            case .error(let error):
                print("error",error)
                DispatchQueue.main.async {
                    if let error = error {
                        if let dataError = error as? Moves.DataError {
                            switch dataError {
                            case .invalidResponse:
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .invalidURL:
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .network(_):
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .invalidData:
                                print("invalidData")
                            case .decoding(_):
                                print("decoding")
                            }
                        } else {
                            if isDebug {
                                Utility.showMessage(message: "Something went wrong. Please try again", on: self.view)
                            }
                        }
                    }
                }
            case .newShowAllNotifications(showAllNotifications: _):
                print("showAllNotifications")
            case .newFollowUser(followUser: let followUser):
                print("follow user",followUser)
                DispatchQueue.main.async {
                    let likeCount = Utility.shared.formatPointsInt(num: followUser.msg?.user.likesCount ?? 0)
                    self.lblLikes.text = likeCount
                    
                    let followersCount = Utility.shared.formatPointsInt(num: followUser.msg?.user.followersCount ?? 0)
                    self.lblFollowers.text = followersCount
                    
                    let followingCount = Utility.shared.formatPointsInt(num: followUser.msg?.user.followingCount ?? 0)
                    self.lblFollowing.text = followingCount
                    
                    self.userResponse?.followersCount = followUser.msg?.user.followersCount
                    self.userResponse?.followingCount = followUser.msg?.user.followingCount
                    self.userResponse?.likesCount = followUser.msg?.user.likesCount
                    
                    NotificationCenter.default.post(name: .switchAccount, object: nil)
                }
            case .newReadNotification(readNotification: _):
                print("readNotification")
            }
        }
    }
    
    
    func privateObserveEvent() {
        blockViewModel.eventHandler = { [weak self] event in
            guard let self else { return }
            
            switch event {
            case .error(let error):
                print("error",error)
                DispatchQueue.main.async {
                    if let error = error {
                        if let dataError = error as? Moves.DataError {
                            switch dataError {
                            case .invalidResponse:
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .invalidURL:
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .network(_):
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .invalidData:
                                print("invalidData")
                            case .decoding(_):
                                print("decoding")
                            }
                        } else {
                            if isDebug {
                                Utility.showMessage(message: "Something went wrong. Please try again", on: self.view)
                            }
                        }
                    }
                }
                
            case .newShowBlockedUsers(showBlockedUsers: let showBlockedUsers):
                break
            case .newBlockUser(blockUser: let blockUser):
                print("blockUser",blockUser)
            case .newShowFavouriteVideos(showFavouriteVideos: let showFavouriteVideos):
                break
            }
        }
    }
    
    func observeEvent2() {
        viewModel2.eventHandler = { [weak self] event in
            guard let self else { return }
            
            switch event {
            case .error(let error):
                print("error",error)
                DispatchQueue.main.async {
                    if let error = error {
                        if let dataError = error as? Moves.DataError {
                            switch dataError {
                            case .invalidResponse:
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .invalidURL:
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .network(_):
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .invalidData:
                                print("invalidData")
                            case .decoding(_):
                                print("decoding")
                            }
                        } else {
                            if isDebug {
                                Utility.showMessage(message: "Something went wrong. Please try again", on: self.view)
                            }
                        }
                    }
                }
                
            case .showOtherUserDetailForUsername(showOtherUserDetailForUsername: let showOtherUserDetailForUsername):
                DispatchQueue.main.async {
                    self.otherUserId = "\(showOtherUserDetailForUsername.msg?.user?.id ?? 0)"
                    print("self.otherUserId",self.otherUserId)
                    self.login(msg: (showOtherUserDetailForUsername.msg?.user)!)
                    self.configuration()
                }
            }
        }
    }
}

extension OtherProfileViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging")
        if type == "Video" || type == "Favorite" {
            if !isNextPageVideoLoad || !isNextPageOrderPlaceLoad {
                self.footerView.stopAnimating()
                isDataLoading = false
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        if type == "Video" || type == "Favorite" {
            if !isNextPageVideoLoad || !isNextPageOrderPlaceLoad {
                self.footerView.stopAnimating()
                isDataLoading = false
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - 100 {
            if type == "Video" {
                if isNextPageVideoLoad && !isDataLoading {
                    isDataLoading = true
                    footerView.startAnimating()
                    
                    startVideoPoint += 1
                    initViewModel(startingPoint: startVideoPoint)
                }
            }else {
                if isNextPageFavoriteLoad && !isDataLoading {
                    isDataLoading = true
                    footerView.startAnimating()
                    
                    startPageFavoritePoint += 1
                    initViewModel(startingPoint: startPageFavoritePoint)
                }
                
            }
            
        }
    }
}

extension OtherProfileViewController: ZoomTransitionAnimatorDelegate {
    func transitionWillStart() {
        guard let lastSelected = self.lastSelectedIndexPath else { return }
        self.videoCollectionView.cellForItem(at: lastSelected)?.isHidden = true
    }
    
    func transitionDidEnd() {
        guard let lastSelected = self.lastSelectedIndexPath else { return }
        self.videoCollectionView.cellForItem(at: lastSelected)?.isHidden = false
    }
    
    func referenceImage() -> UIImage? {
        guard
            let lastSelected = self.lastSelectedIndexPath,
            let cell = self.videoCollectionView.cellForItem(at: lastSelected) as? VideoProfileCollectionViewCell
        else {
            return nil
        }
        
        return cell.videoView.image
    }
    
    func imageFrame() -> CGRect? {
        guard
            let lastSelected = self.lastSelectedIndexPath,
            let cell = self.videoCollectionView.cellForItem(at: lastSelected) as? VideoProfileCollectionViewCell
                
        else {
            return self.view.frame
        }
        
        return FrameHelper.getTargerFrame(originalView: cell.videoView, targetView: self.view) ?? self.view.frame
    }
}
