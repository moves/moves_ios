//
//  ProfileViewController.swift
// //
//
//  Created by Wasiq Tayyab on 13/06/2024.
//

import SkeletonView
import UIKit
import Lottie
import ZoomingTransition
import SDWebImage
class ProfileViewController: ZoomingPushVC, UIGestureRecognizerDelegate {
    // MARK: - VARIABLES
    var lastSelectedIndexPath: IndexPath? = nil
    var allArray: [HomeResponseMsg] = []
    var mainArr: ShowVideosAgainstUserIDResponse?
    var mainPrivateArr: ShowPrivateVideosAgainstUserIDResponse?
    var secondArr: HomeResponse?
    var thirdArr: HomeResponse?
    var viewModel = ProfileViewModel()
    var profileResponse: ProfileResponse?
    var userItem = [["Image": "Icons 1", "isSelected": "true"], ["Image": "music tok icon-3 1", "isSelected": "false"],
                    ["Image": "image-11 1", "isSelected": "false"]]
    var storeSelectedIP = IndexPath(item: 0, section: 0)
    var startPoint = 0
    var type = "Public"
    var isNextPageLoad = false
    var website = ""
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(named: "theme")!
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        
        return refreshControl
    }()

   
    private let footerView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    var isDataLoading: Bool = false
    var deleteIndex = 0
   
    private var objNotificaton: Any?
    
    private var animationView: LottieAnimationView!
    // MARK: - OUTLET
    @IBOutlet var lottieAnimation: UIView!
    @IBOutlet var scrollViewOutlet: UIScrollView!
    @IBOutlet var profileView: UIView!
    
    @IBOutlet var headerCollectionView: UICollectionView!
    @IBOutlet var videoCollectionView: UICollectionView!
    @IBOutlet var lblUsername: UILabel!
    @IBOutlet var lblProfileUsername: UILabel!
    @IBOutlet var profileImage: CustomImageView!
    
    @IBOutlet var lblLikeCount: UILabel!
    @IBOutlet var lblFollowersCount: UILabel!
    @IBOutlet var lblFollowingCount: UILabel!
    @IBOutlet var tickStack: UIStackView!
    @IBOutlet var lblDescription: UILabel!
    
    @IBOutlet var upperViewConstraint: NSLayoutConstraint!
    
    @IBOutlet var lblWebsite: UILabel!
    @IBOutlet var lblPostHeader: UILabel!
    @IBOutlet var lblPostVideo: UILabel!
    @IBOutlet var noDataStack: UIStackView!
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        self.animationPlay()
        if UserDefaultsManager.shared.business == "0" {
            self.setupUI()
        }
        
        self.showUserDetailApi()
        
        objNotificaton = NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("changeNumber"), object: nil)
        
        objNotificaton = NotificationCenter.default.addObserver(self, selector: #selector(self.reloadUI(_:)), name: NSNotification.Name("switchAccount"), object: nil)
    }

    // MARK: - viewWillAppear

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
        
        tabBarController?.tabBar.isTranslucent = false

        // animate the tab bar color
        // attempting to animate .tintBarColor doesn't work - it just changes immediately
        self.tabBarController?.tabBar.barTintColor = .clear
        if let tab = self.tabBarController?.tabBar {
            UIView.transition(with: tab, duration: 0.2) {
                tab.backgroundColor = .white
                tab.tintColor = .black
            }
        }
        tabBarController?.tabBar.unselectedItemTintColor = .black
    }
    
    deinit {
        print("Deinit")
        NotificationCenter.default.removeObserver(objNotificaton)
    }
    
    // MARK: - setupUI
    
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

    
    func showUserDetailApi(){
        if let fetchedData: ProfileResponse = DataPersistence.shared.fetchFromCoreData(withId: "profile") {
            self.login(msg: fetchedData.msg!)
        } else {
            self.profileView.showAnimatedGradientSkeleton()
            let showUserDetail = ShowUserDetailRequest(authToken: UserDefaultsManager.shared.authToken)
            viewModel.showUserDetail(parameters: showUserDetail)
            observeEvent()
        }
    }
   
    
    func setupUI() {
        configureUI()
        configureTabBar()
    }

    func updateUI() {
        DispatchQueue.main.async {
            self.videoCollectionView.reloadData()
            self.upperViewConstraint.constant = self.videoCollectionView.collectionViewLayout.collectionViewContentSize.height
            self.videoCollectionView.layoutIfNeeded()
            self.view.layoutIfNeeded()
        }
    }

    @objc func reloadUI(_ notify: NSNotification) {
        print("Notify Switch Account")
        self.startPoint = 0
        lblUsername.text = UserDefaultsManager.shared.username
        lblProfileUsername.text = "@" + UserDefaultsManager.shared.username
        self.configureUI()
    }

//    private func loadCachedVideoData() {
//        if let cachedResponse = loadCachedData() {
//            self.mainArr = cachedResponse
//
//            DispatchQueue.main.async {
//                self.videoCollectionView.reloadData()
//                self.updateUI()
//            }
//        } else {
//            print("Error loading cached data.")
//        }
//    }

    private func configureUI() {
        self.configuration()
    }

    private func configureTabBar() {
        tabBarController?.tabBar.isTranslucent = true
        tabBarController?.tabBar.barTintColor = .white
        tabBarController?.tabBar.tintColor = .black
        tabBarController?.tabBar.unselectedItemTintColor = .black
    }

    @objc private func handleNotification(_ notification: NSNotification) {
        self.type = "Public"
        
        let showUserDetail = ShowUserDetailRequest(authToken: UserDefaultsManager.shared.authToken)
        viewModel.showUserDetail(parameters: showUserDetail)
        
        let request = ShowVideosAgainstUserIDRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: 0, otherUserId: "")
        viewModel.showVideosAgainstUserID(parameters: request)
        
        let tagged = ShowVideosAgainstUserIDRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: 0, otherUserId: "")
        viewModel.showUserRepostedVideos(parameters: tagged)
        
        self.observeEvent()
    }

    private func login(msg: ProfileResponseMsg) {
        self.profileView.hideSkeleton()
        
        let user = msg.user
        
        if let profilePicURLString = user?.profilePic, let profilePicURL = URL(string: profilePicURLString) {
            profileImage.sd_setImage(with: profilePicURL, placeholderImage: UIImage(named: "profile1"))
        } else {
            profileImage.image = UIImage(named: "profile1")
        }
        
        UserDefaultsManager.shared.wallet = user?.wallet?.stringValue ?? ""
        lblUsername.text = user?.username ?? ""
        lblProfileUsername.text = "@\(user?.username ?? "")"
        
        if let bio = user?.bio, !bio.isEmpty {
            lblDescription.isHidden = false
            lblDescription.text = bio
        } else {
            lblDescription.isHidden = true
        }
        
        if let website = user?.website, !website.isEmpty {
            lblWebsite.isHidden = false
            lblWebsite.text = website
            self.website = website
        } else {
            lblWebsite.isHidden = true
            self.website = ""
        }
        
        if lblWebsite.gestureRecognizers?.isEmpty ?? true {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            lblWebsite.addGestureRecognizer(tapGesture)
            lblWebsite.isUserInteractionEnabled = true
        }
        
        let likeCount = Utility.shared.formatPoints(num: user?.likesCount?.toDouble() ?? 0.0)
        self.lblLikeCount.text = likeCount
        
        let followersCount = Utility.shared.formatPoints(num: user?.followersCount?.toDouble() ?? 0.0)
        self.lblFollowersCount.text = followersCount
        
        let followingCount = Utility.shared.formatPoints(num: user?.followingCount?.toDouble() ?? 0.0)
        self.lblFollowingCount.text = followingCount
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let myviewController = WebViewController(nibName: "WebViewController", bundle: nil)
        myviewController.myUrl = website
        myviewController.linkTitle = "Website"
        myviewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(myviewController, animated: true)
    }
    
    @objc
    func requestData() {
        print("requesting data")
        for i in 0..<self.userItem.count {
            var obj = self.userItem[i]
            obj.updateValue("false", forKey: "isSelected")
            self.userItem.remove(at: i)
            self.userItem.insert(obj, at: i)
        }
        
        var obj = self.userItem[0]
        obj.updateValue("true", forKey: "isSelected")
        self.userItem.remove(at: 0)
        self.userItem.insert(obj, at: 0)
        
        self.headerCollectionView.reloadData()
        self.type = "Public"
        startPoint = 0
        mainArr?.msg?.msgPublic.removeAll()
        mainArr?.msg?.msgPrivate.removeAll()
        secondArr?.msg?.removeAll()
        
        let showUserDetail = ShowUserDetailRequest(authToken: UserDefaultsManager.shared.authToken)
        viewModel.showUserDetail(parameters: showUserDetail)
        initViewModel(startingPoint: startPoint)
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    
    @objc func StoreSelectedIndex(index: Int) {
        // Update the selected item
        var obj = self.userItem[index]
        obj.updateValue("true", forKey: "isSelected")
        self.userItem.remove(at: index)
        self.userItem.insert(obj, at: index)
        
        // Handle the UI update
        self.noDataStack.isHidden = true
        self.headerCollectionView.reloadData()
        
        switch index {
        case 0:
            self.type = "Public"
            if let msgPublicCount = viewModel.showVideosAgainstUserID?.msg?.msgPublic.count, msgPublicCount != 0 {
                self.videoCollectionView.isHidden = false
                self.isNextPageLoad = msgPublicCount >= 10
                self.mainArr?.msg?.msgPublic.removeAll()
                self.mainArr = viewModel.showVideosAgainstUserID
                updateUI()
            }
//            else if let cachedData = loadCachedData(), cachedData.msg?.msgPublic.count ?? 0 > 0 {
//                self.videoCollectionView.isHidden = false
//                self.isNextPageLoad = (cachedData.msg?.msgPublic.count ?? 0) >= 10
//                self.mainArr?.msg?.msgPublic.removeAll()
//                self.mainArr = cachedData
//                updateUI()
//            }
            else {
                self.videoCollectionView.isHidden = true
                self.noDataStack.isHidden = false
                self.lblPostHeader.text = "No Data Found"
                self.lblPostVideo.text = "You have not posted any video yet"
            }
            
        case 1:
            self.type = "Liked"
            if let likedVideosCount = viewModel.showUserLikedVideos?.msg?.count, likedVideosCount != 0 {
                self.videoCollectionView.isHidden = false
                self.isNextPageLoad = likedVideosCount >= 10
                self.secondArr?.msg?.removeAll()
                self.secondArr = viewModel.showUserLikedVideos
                updateUI()
            } else {
                self.videoCollectionView.isHidden = true
                self.noDataStack.isHidden = false
                self.lblPostHeader.text = "No Data Found"
                self.lblPostVideo.text = "You have not liked any video yet"
            }
            
        default:
            self.type = "Private"
            if let privateVideosCount = viewModel.privateShowVideosAgainstUserID?.msg?.msgPrivate.count, privateVideosCount != 0 {
                self.isNextPageLoad = privateVideosCount >= 10
                self.mainPrivateArr?.msg?.msgPrivate.removeAll()
                self.mainPrivateArr = viewModel.privateShowVideosAgainstUserID
                updateUI()
            } else {
                self.videoCollectionView.isHidden = true
                self.noDataStack.isHidden = false
                self.lblPostHeader.text = "No Data Found"
                self.lblPostVideo.text = "You have not any private video yet"
            }
        }
    }
    
    // MARK: - BUTTON ACTION
    
    @IBAction func editProfileButtonPressed(_ sender: UIButton) {
        let myViewController = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
        myViewController.profileResponse = profileResponse
        myViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(myViewController, animated: true)
    }
   

    @IBAction func addFriendButtonPressed(_ sender: UIButton) {
        let myViewController = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
        myViewController.profileResponse = profileResponse
        myViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(myViewController, animated: true)
    }
    
    @IBAction func menuButtonPressed(_ sender: UIButton) {
        let myViewController = SettingViewController(nibName: "SettingViewController", bundle: nil)
        myViewController.profileResponse = self.profileResponse
        myViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(myViewController, animated: true)
    }
    
    @IBAction func profileViewButtonPressed(_ sender: UIButton) {
        let myViewController = ProfileViewViewController(nibName: "ProfileViewViewController", bundle: nil)
        myViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(myViewController, animated: true)
    }
    
    @IBAction func FollowingButtonPressed(_ sender: UIButton) {
        if sender.tag == 2 {
            let myViewController = LikesViewController(nibName: "LikesViewController", bundle: nil)
            myViewController.username = profileResponse?.msg?.user?.username ?? ""
            myViewController.likes_count = profileResponse?.msg?.user?.likesCount?.toString() ?? ""
            myViewController.modalPresentationStyle = .overFullScreen
            self.navigationController?.present(myViewController, animated: false, completion: nil)
        } else if sender.tag == 0 {
            
            
            let myViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FriendsViewController")as! FriendsViewController
            myViewController.hidesBottomBarWhenPushed = true
            myViewController.otherUserId = UserDefaultsManager.shared.user_id
            myViewController.username = profileResponse?.msg?.user?.username ?? ""
            myViewController.selectedMenu = "Following"
            self.navigationController?.pushViewController(myViewController, animated: true)
        } else {
            let myViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FriendsViewController")as! FriendsViewController
            myViewController.hidesBottomBarWhenPushed = true
            myViewController.otherUserId = UserDefaultsManager.shared.user_id
            myViewController.username = profileResponse?.msg?.user?.username ?? ""
            myViewController.selectedMenu = "Followers"
            self.navigationController?.pushViewController(myViewController, animated: true)
        }
    }
}

// MARK: - COLLECTION VIEW

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == headerCollectionView {
            return userItem.count
        } else {
            if type == "Public" {
                return mainArr?.msg?.msgPublic.count ?? 0
            } else if type == "Private" {
                return mainPrivateArr?.msg?.msgPrivate.count ?? 0
            } else if type == "Liked" {
                return secondArr?.msg?.count ?? 0
            } else {
                return thirdArr?.msg?.count ?? 0
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCollectionViewCell", for: indexPath) as! ProfileCollectionViewCell
            cell.imgIcon.image = UIImage(named: self.userItem[indexPath.row]["Image"] ?? "")
            if self.userItem[indexPath.row]["isSelected"] == "true" {
                cell.imgIcon.tintColor = .black
                cell.lineview.isHidden = false
            } else {
                cell.imgIcon.tintColor = UIColor.appColor(.darkGrey)
                cell.lineview.isHidden = true
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoProfileCollectionViewCell", for: indexPath) as! VideoProfileCollectionViewCell
            if type == "Public" {
                let video = mainArr?.msg?.msgPublic[indexPath.row].video
                let thum = video?.thum ?? ""
                cell.videoView.sd_setImage(with: URL(string: thum), placeholderImage: UIImage(named: ""), options: .continueInBackground, completed: { [weak cell] image, _, _, _ in
                    guard let cell = cell, let image = image else { return }
                    UIView.transition(with: cell.videoView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        cell.videoView.image = image
                    }, completion: nil)
                })
                
                cell.lblView.text = video?.view?.toString()
                if video?.pin == 0 {
                    cell.pinnedview.isHidden = true
                } else {
                    cell.pinnedview.isHidden = false
                }
            } else if type == "Private" {
                let video = mainPrivateArr?.msg?.msgPrivate[indexPath.row].video
                let thum = video?.thum ?? ""
                cell.videoView.sd_setImage(with: URL(string: thum), placeholderImage: UIImage(named: ""), options: .continueInBackground, completed: { [weak cell] image, _, _, _ in
                    guard let cell = cell, let image = image else { return }
                    UIView.transition(with: cell.videoView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        cell.videoView.image = image
                    }, completion: nil)
                })
                cell.lblView.text = video?.view?.toString()
                cell.pinnedview.isHidden = true
            }else {
                let video = secondArr?.msg?[indexPath.row].video
                let thum = video?.thum ?? ""
                cell.videoView.sd_setImage(with: URL(string: thum), placeholderImage: UIImage(named: ""), options: .continueInBackground, completed: { [weak cell] image, _, _, _ in
                    guard let cell = cell, let image = image else { return }
                    UIView.transition(with: cell.videoView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        cell.videoView.image = image
                    }, completion: nil)
                })
                cell.lblView.text = video?.view?.toString()
                cell.pinnedview.isHidden = true
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if type == "Public" {
            for indexPath in indexPaths {
                let video = mainArr?.msg?.msgPublic[indexPath.row].video
                if let thum = video?.thum, let url = URL(string: thum) {
                    SDWebImagePrefetcher.shared.prefetchURLs([url])
                }
            }
        }else if type == "Private"  {
            for indexPath in indexPaths {
                let video = mainArr?.msg?.msgPrivate[indexPath.row].video
                if let thum = video?.thum, let url = URL(string: thum) {
                    SDWebImagePrefetcher.shared.prefetchURLs([url])
                }
            }
        }else {
            for indexPath in indexPaths {
                let video = secondArr?.msg?[indexPath.row].video
                if let thum = video?.thum, let url = URL(string: thum) {
                    SDWebImagePrefetcher.shared.prefetchURLs([url])
                }
            }
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == headerCollectionView {
            return CGSize(width: collectionView.frame.width/3, height: 42)
        } else {
            return CGSize(width: collectionView.frame.width/3 - 1, height: 230)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == headerCollectionView {
            for i in 0..<self.userItem.count {
                var obj = self.userItem[i]
                obj.updateValue("false", forKey: "isSelected")
                self.userItem.remove(at: i)
                self.userItem.insert(obj, at: i)
            }
            
            self.StoreSelectedIndex(index: indexPath.row)
            self.storeSelectedIP = indexPath
        } else {
            self.deleteIndex = indexPath.row
            self.lastSelectedIndexPath = indexPath
            let videoDetail = VideoDetailController()
            
            if type == "Public" {
                allArray = (mainArr?.msg!.msgPublic)!
                videoDetail.ourVideo = true
            } else if type == "Private" {
                allArray = (mainPrivateArr?.msg!.msgPrivate)!
            } else {
                allArray = (secondArr?.msg)!
            }
            videoDetail.dataSource = allArray
            videoDetail.index = indexPath.row
            videoDetail.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(videoDetail, animated: true)
        }
    }
}

extension ProfileViewController {

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
       
       
        initViewModel(startingPoint: startPoint)
        
        videoCollectionView.register(CollectionViewFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        (videoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: videoCollectionView.bounds.width, height: 50)
        footerView.color = UIColor(named: "theme")
        footerView.hidesWhenStopped = true
    }
  
    func initViewModel(startingPoint: Int) {
        if startingPoint == 0 {
            let showVideosAgainstUserID = ShowVideosAgainstUserIDRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: startingPoint, otherUserId: "")
            viewModel.showVideosAgainstUserID(parameters: showVideosAgainstUserID)
            
            let private1 = ShowVideosAgainstUserIDRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: startingPoint, otherUserId: "")
            viewModel.newShowPrivateVideosAgainstUserID(parameters: private1)
         
            let liked = ShowVideosAgainstUserIDRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: startingPoint, otherUserId: "")
            viewModel.showUserLikedVideos(parameters: liked)
            
            let tagged = ShowVideosAgainstUserIDRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: startingPoint, otherUserId: "")
            viewModel.showUserRepostedVideos(parameters: tagged)
            
            
        } else {
            if type == "Public" {
                let showVideosAgainstUserID = ShowVideosAgainstUserIDRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: startingPoint, otherUserId: "")
                viewModel.showVideosAgainstUserID(parameters: showVideosAgainstUserID)
            } else if type == "Private" {
                let private1 = ShowVideosAgainstUserIDRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: startingPoint, otherUserId: "")
                viewModel.newShowPrivateVideosAgainstUserID(parameters: private1)
                print("private1", private1)
            } else if type == "Liked" {
                let liked = ShowVideosAgainstUserIDRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: startingPoint, otherUserId: "")
                viewModel.showUserLikedVideos(parameters: liked)
                print("liked", liked)
            } else {
                let tagged = ShowVideosAgainstUserIDRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: startingPoint, otherUserId: "")
                viewModel.showUserRepostedVideos(parameters: tagged)
                print("tagged", tagged)
            }
        }
      
        observeEvent()
    }
   
    func observeEvent() {
        viewModel.eventHandler = { [weak self] event in
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
                    self.profileView.hideSkeleton()
                }
            case .newShowUserDetail(showUserDetail: let showUserDetail):
                DispatchQueue.main.async {
                    UserDefaultsManager.shared.wallet = showUserDetail.msg?.user?.wallet?.stringValue ?? ""
                    DataPersistence.shared.saveOrUpdateCoreData(data: showUserDetail, withId: "profile")
                }
                if showUserDetail.code == 200 {
                    DispatchQueue.main.async {
                        self.profileResponse = showUserDetail
                        self.login(msg: showUserDetail.msg!)
                        UserObject.shared.updateProfilePic(profile: showUserDetail) // UPDATE PROFILE IN SWITCH ACCOUNT
                    }
                } else {
                    DispatchQueue.main.async {
                        self.profileView.hideSkeleton()
                    }
                }
            case .newShowVideosAgainstUserID(showVideosAgainstUserID: let showVideosAgainstUserID):
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.lottieAnimation.alpha = 0
                    }) { _ in
                        self.lottieAnimation.isHidden = true
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.headerCollectionView.isHidden = false
                    
                    if self.startPoint == 0 {
                        self.mainArr?.msg?.msgPublic.removeAll()
                        self.viewModel.showVideosAgainstUserID?.msg?.msgPublic.removeAll()
                        self.viewModel.showVideosAgainstUserID = showVideosAgainstUserID
                        self.mainArr = showVideosAgainstUserID
                    }
                    
                    guard showVideosAgainstUserID.code == 200 else {
                        return
                    }
                    
                    if let newVideos = showVideosAgainstUserID.msg?.msgPublic, !newVideos.isEmpty {
                        if self.startPoint != 0 {
                            self.viewModel.showVideosAgainstUserID?.msg?.msgPublic.append(contentsOf: newVideos)
                            self.mainArr?.msg?.msgPublic.append(contentsOf: newVideos)
                        }
                        
                        self.isNextPageLoad = (self.mainArr?.msg?.msgPublic.count ?? 0) >= 10
                        
                        self.videoCollectionView.reloadData()
                        let height = self.videoCollectionView.collectionViewLayout.collectionViewContentSize.height
                        self.upperViewConstraint.constant = height
                        self.videoCollectionView.layoutIfNeeded()
                        self.view.layoutIfNeeded()
                        
                    } else if self.startPoint == 0 {
                        self.viewModel.showVideosAgainstUserID?.msg?.msgPublic.removeAll()
                        self.mainArr?.msg?.msgPublic.removeAll()
                        self.noDataStack.isHidden = false
                        self.lblPostHeader.text = "No Data Found"
                        self.lblPostVideo.text = "You have not posted any video yet"
                        self.isNextPageLoad = false
                    }
                }

            case .newShowUserLikedVideos(showUserLikedVideos: let showUserLikedVideos):
              
                if showUserLikedVideos.code == 201 {
                    if startPoint == 0 {
                        self.viewModel.showUserLikedVideos?.msg?.removeAll()
                        self.secondArr?.msg?.removeAll()
                    } else {
                        DispatchQueue.main.async {
                            self.isNextPageLoad = false
                        }
                    }
                    
                } else {
                    if startPoint == 0 {
                        viewModel.showUserLikedVideos = showUserLikedVideos
                        self.secondArr?.msg?.removeAll()
                        self.secondArr = showUserLikedVideos
                        
                    } else {
                        let newMessages = showUserLikedVideos.msg
                        self.secondArr?.msg?.append(contentsOf: newMessages!)
                    }
                }
                
                DispatchQueue.main.async {
                    self.isNextPageLoad = (self.secondArr?.msg?.count ?? 0) >= 10
                }
            case .newShowFavouriteVideos(showFavouriteVideos: let showFavouriteVideos):
                print("showFavouriteVideos")
            case .newShowOtherUserDetail(showOtherUserDetail: let showOtherUserDetail):
                print("")
            case .newDeleteVideo(deleteVideo: let deleteVideo):
                DispatchQueue.main.async {
                    if deleteVideo.code == 200 {
                        self.mainArr?.msg?.msgPublic.remove(at: self.deleteIndex)
                        self.videoCollectionView.deleteItems(at: [IndexPath(item: self.deleteIndex, section: 0)])
                    }
                }
            case .newWithdrawRequest(withdrawRequest: let withdrawRequest):
                print("withdrawRequest")
            case .newShowPayout(showPayout: let showPayout):
                print("showPayout")
            case .newShowStoreTaggedVideos(showStoreTaggedVideos: let showStoreTaggedVideos):
                print("showStoreTaggedVideos")
            case .newShowPrivateVideosAgainstUserID(showPrivateVideosAgainstUserID: let showPrivateVideosAgainstUserID):
                if showPrivateVideosAgainstUserID.code == 200 {
                    guard let msg = showPrivateVideosAgainstUserID.msg else { return }

                    if !msg.msgPrivate.isEmpty {
                        if startPoint == 0 {
                            self.mainPrivateArr?.msg?.msgPrivate.removeAll()
                            self.viewModel.privateShowVideosAgainstUserID = showPrivateVideosAgainstUserID
                            self.mainPrivateArr = showPrivateVideosAgainstUserID
                        } else {
                            self.mainPrivateArr?.msg?.msgPrivate.append(contentsOf: msg.msgPrivate)
                        }

                        DispatchQueue.main.async {
                            self.isNextPageLoad = (self.mainPrivateArr?.msg?.msgPrivate.count ?? 0) >= 10
                        }
                    } else {
                        if startPoint == 0 {
                            self.viewModel.privateShowVideosAgainstUserID?.msg?.msgPrivate.removeAll()
                            self.mainPrivateArr?.msg?.msgPrivate.removeAll()

                        } else {
                            DispatchQueue.main.async {
                                self.isNextPageLoad = false
                            }
                        }
                    }
                }
            case .showUserRepostedVideos(showUserRepostedVideos: let showUserRepostedVideos):
                print("showUserRepostedVideos")
                if showUserRepostedVideos.code == 201 {
                    if startPoint == 0 {
                        self.viewModel.showTaggedVideosAgainstUserID?.msg?.removeAll()
                        self.thirdArr?.msg?.removeAll()

                    } else {
                        DispatchQueue.main.async {
                            self.isNextPageLoad = false
                        }
                    }
                 
                } else {
                    if startPoint == 0 {
                        self.thirdArr?.msg?.removeAll()
                        self.thirdArr = showUserRepostedVideos
                        viewModel.showTaggedVideosAgainstUserID = showUserRepostedVideos
                        
                    } else {
                        let newMessages = showUserRepostedVideos.msg
                        self.thirdArr?.msg?.append(contentsOf: newMessages!)
                    }
                }
                
                DispatchQueue.main.async {
                    self.isNextPageLoad = (self.thirdArr?.msg?.count ?? 0) >= 10
                }
            }
        }
    }
}

extension ProfileViewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging")
        if isNextPageLoad == true {
            self.footerView.stopAnimating()
            isDataLoading = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        if isNextPageLoad == true {
            self.footerView.stopAnimating()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
        if scrollView == self.scrollViewOutlet {
            if (scrollViewOutlet.contentOffset.y + scrollViewOutlet.frame.size.height) >= scrollViewOutlet.contentSize.height {
                if isNextPageLoad == true {
                    if !isDataLoading {
                        isDataLoading = true
                        footerView.startAnimating()
                        startPoint += 1
                        initViewModel(startingPoint: startPoint)
                    }
                }
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollViewOutlet.contentOffset.y + scrollViewOutlet.frame.size.height) >= scrollViewOutlet.contentSize.height {
            if isNextPageLoad == true {
                self.footerView.hidesWhenStopped = true
                self.footerView.stopAnimating()
            }
        }
    }
}

extension ProfileViewController: ZoomTransitionAnimatorDelegate {
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
        
        return FrameHelper.getTargerFrame(originalView: cell.videoView, targetView: self.view)  ?? self.view.frame



    }
}
