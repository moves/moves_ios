//
//  NotificationsViewController.swift
// //
//
//  Created by Wasiq Tayyab on 10/06/2024.
//

import UIKit
import SkeletonView
import ZoomingTransition
class NotificationsViewController: ZoomingPushVC {
    
    //MARK: - VARS
    var lastSelectedIndexPath: IndexPath? = nil
    let viewModel = NotificaitonViewModel()
    var startPoint = 0
    var currentIndexPath = IndexPath(item: 0, section: 0)
    var day = ""
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.appColor(.theme)
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        
        return refreshControl
    }()
    var isNextPageLoad = false
    var isDataLoading:Bool = true
    let spinner = UIActivityIndicatorView(style: .white)
    //MARK: - OUTLET

    @IBOutlet weak var lblNoNotification: UILabel!
    @IBOutlet weak var notificationsTableView: UITableView!
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ConstantManager.isNotification == true {
            let showNotification = SettingRequest(userId: UserDefaultsManager.shared.user_id)
            DispatchQueue.global(qos: .userInitiated).async {
                self.viewModel.readNotification(parameters: showNotification)
                self.observeEvent()
            }
        }
        self.configuration()
        if viewModel.allNotification?.code == nil {
            self.apiCall()
        }else {
            self.setup()
        }
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isTranslucent = true
        tabBarController?.tabBar.barTintColor = .white
    
        tabBarController?.tabBar.tintColor = .black
        tabBarController?.tabBar.unselectedItemTintColor = .black
        
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
        
       

    }
    
    
    @IBAction func inboxButtonPressed(_ sender: UIButton) {
        let myViewController = InboxViewController(nibName: "InboxViewController", bundle: nil)
        myViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(myViewController, animated: true)
    }
    
    
    @objc func switchAccount(notification: NSNotification) {
        self.startPoint = 0
        self.apiCall()
    }
    
    private func setup(){
        if viewModel.allNotification?.code == 200 {
            if self.startPoint != 0, let newMessages = viewModel.allNotification?.msg {
                self.viewModel.allNotification?.msg?.append(contentsOf: newMessages)
            }
            
            self.isDataLoading = false
            self.isNextPageLoad = (self.viewModel.allNotification?.msg?.count ?? 0) >= 10
           
            self.notificationsTableView.reloadData()
        } else {
            if self.startPoint == 0 {
                DispatchQueue.main.async {
                    self.lblNoNotification.isHidden = false
                }
            }
            self.isDataLoading = true
            self.isNextPageLoad = false
        }
        self.notificationsTableView.hideSkeleton()
    }
    
    private func apiCall() {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        let showNotification = NotificationRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: startPoint)
        viewModel.showAllNotifications(parameters: showNotification)
        dispatchGroup.leave()
        
        dispatchGroup.notify(queue: .main) {
            self.observeEvent()
        }
       
    }
    
    //MARK: - BUTTON ACTION
    
    @objc
    func requestData() {
        print("requesting data")
        self.startPoint = 0
        self.apiCall()
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
 
extension NotificationsViewController: UITableViewDelegate,SkeletonTableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.allNotification?.msg?.count ?? 0
    }
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "VideoTypeTableViewCell"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let store = viewModel.allNotification?.msg?[indexPath.row].store
        let sender = viewModel.allNotification?.msg?[indexPath.row].sender
        let notification = viewModel.allNotification?.msg?[indexPath.row].notification
        let video = viewModel.allNotification?.msg?[indexPath.row].video

        let timeZone = getTimeZoneOffset()
        let day = adjustDate(for: notification?.created ?? "", timeZoneOffset: timeZone).flatMap { timeDifference(from: $0) } ?? ""

        if notification?.type == "following" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTableViewCell", for: indexPath) as! FollowTableViewCell
            let formattedText = formatText(notification?.string ?? "", characterLimit: 115, addString: day)
            cell.lblFollowNotification.attributedText = formattedText

            if sender?.business == 0 {
                cell.profileImage.sd_setImage(with: URL(string: sender?.profilePic ?? ""), placeholderImage: UIImage(named: "profile1"))
            } else {
                configureBusinessProfileImage(cell: cell, sender: sender, store: store)
            }
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped(_:)))
            cell.profileImage.isUserInteractionEnabled = true
            cell.profileImage.addGestureRecognizer(tapGesture)
            cell.profileImage.tag = indexPath.row

            configureFollowButton(cell: cell, sender: sender,indexPath: indexPath.row)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoTypeTableViewCell", for: indexPath) as! VideoTypeTableViewCell
            let formattedText = formatText(notification?.string ?? "", characterLimit: 115, addString: day)
            cell.lblVideoNotification.attributedText = formattedText
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped(_:)))
            cell.videoProfileImage.isUserInteractionEnabled = true
            cell.videoProfileImage.addGestureRecognizer(tapGesture)
            cell.videoProfileImage.tag = indexPath.row

            configureVideoProfileImage(cell: cell, sender: sender, video: video)

            return cell
        }
    }
    
    @objc private func profileImageTapped(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else { return }
        let indexPathRow = imageView.tag
        
        let user = viewModel.allNotification?.msg?[indexPathRow].sender
        let notification = viewModel.allNotification?.msg?[indexPathRow].notification
        let video = viewModel.allNotification?.msg?[indexPathRow].video
        let sender = viewModel.allNotification?.msg?[indexPathRow].sender?.id ?? 0
    
        
        if sender == nil || sender == 0 {
             Utility.showMessage(message: "Something went wrong. Please try later", on: self.view)
            return
        }
        
        if sender.toString() == UserDefaultsManager.shared.user_id {
            let story = UIStoryboard(name: "Main", bundle: nil)
            if let tabBarController = story.instantiateViewController(withIdentifier: "TabbarViewController") as? UITabBarController {
                tabBarController.selectedIndex = 4
                let nav = UINavigationController(rootViewController: tabBarController)
                nav.navigationBar.isHidden = true
                self.view.window?.rootViewController = nav
            }
        }
        
        if user?.business == 0 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let myViewController = storyboard.instantiateViewController(withIdentifier: "OtherProfileViewController")as! OtherProfileViewController
            myViewController.callback = { [self] (user) -> Void in
                self.viewModel.allNotification?.msg?[indexPathRow].sender?.button = user.button
                notificationsTableView.reloadData()
            }
            myViewController.userResponse = user
            myViewController.hidesBottomBarWhenPushed = true
            myViewController.otherUserId = sender.toString()
            self.navigationController?.pushViewController(myViewController, animated: true)
        }else {
//            let vc = BusinessProfileViewController(nibName: "BusinessProfileViewController", bundle: nil)
//            vc.hidesBottomBarWhenPushed = true
//            vc.callback = { [self] (user) -> Void in
//                self.viewModel.allNotification?.msg?[indexPathRow].sender?.button = user.button
//                notificationsTableView.reloadData()
//            }
//            vc.user = user
//            vc.store = user?.store
//            vc.storeAddress = user?.store?.storeAddress
//            vc.storeLocalHours = user?.store?.storeLocalHours
//            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }

    
    private func configureFollowButton(cell: FollowTableViewCell, sender: HomeUser?,indexPath: Int) {
        switch sender?.button {
        case "follow", "Follow":
            cell.btnFollow.setTitle("Follow", for: .normal)
            cell.btnFollow.backgroundColor = UIColor.appColor(.theme)
            cell.btnFollow.setTitleColor(UIColor.appColor(.white), for: .normal)
        case "following", "Following":
            cell.btnFollow.setTitle("Following", for: .normal)
            cell.btnFollow.backgroundColor = UIColor.appColor(.buttonColor)
            cell.btnFollow.setTitleColor(UIColor.appColor(.black), for: .normal)
        case "friends", "Friends":
            cell.btnFollow.setTitle("Message", for: .normal)
            cell.btnFollow.backgroundColor = UIColor.appColor(.buttonColor)
            cell.btnFollow.setTitleColor(UIColor.appColor(.black), for: .normal)
        case "follow back", "Follow Back":
            cell.btnFollow.setTitle(sender?.button?.capitalized, for: .normal)
            cell.btnFollow.backgroundColor = UIColor.appColor(.theme)
            cell.btnFollow.setTitleColor(UIColor.appColor(.white), for: .normal)
        default:
            break
        }
        cell.btnFollow.tag = indexPath
        cell.btnFollow.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        cell.btnFollow1.tag = indexPath
        cell.btnFollow1.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
    }
    
    
    private func configureBusinessProfileImage(cell: FollowTableViewCell, sender: HomeUser?,store:Store?) {
        let store = sender?.store
        if let profilePicURLString = store?.logoPhotos, !profilePicURLString.isEmpty {
            cell.profileImage.sd_setImage(with: URL(string: profilePicURLString), placeholderImage: UIImage(named: sender?.business == 1 ? "mealMePlaceholder" : "privateOrderPlaceholder"))
        } else {
            cell.profileImage.image = UIImage(named: sender?.business == 1 ? "mealMePlaceholder" : "privateOrderPlaceholder")
        }
    }


    private func configureVideoProfileImage(cell: VideoTypeTableViewCell, sender: HomeUser?, video: Video?) {
        if sender?.business == 0 {
            cell.videoProfileImage.sd_setImage(with: URL(string: sender?.profilePic ?? ""), placeholderImage: UIImage(named: "profile1"))
            cell.imgVideoNotification.isHidden = false
            cell.imgVideoNotification.sd_setImage(with: URL(string: video?.thum ?? ""), placeholderImage: UIImage(named: ""))
        } else {
            cell.videoProfileImage.sd_setImage(with: URL(string: sender?.profilePic ?? ""), placeholderImage: UIImage(named: sender?.business == 1 ? "mealMePlaceholder" : "privateOrderPlaceholder"))
            cell.imgVideoNotification.isHidden = true
        }
    }

    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = viewModel.allNotification?.msg?[indexPath.row].sender
        let notification = viewModel.allNotification?.msg?[indexPath.row].notification
        let video = viewModel.allNotification?.msg?[indexPath.row].video
        if notification?.type == "following" {
            let sender = viewModel.allNotification?.msg?[indexPath.row].sender?.id ?? 0
        
            
            if sender == nil || sender == 0 {
                 Utility.showMessage(message: "Something went wrong. Please try later", on: self.view)
                return
            }
            
            if sender.toString() == UserDefaultsManager.shared.user_id {
                let story = UIStoryboard(name: "Main", bundle: nil)
                if let tabBarController = story.instantiateViewController(withIdentifier: "TabbarViewController") as? UITabBarController {
                    tabBarController.selectedIndex = 4
                    let nav = UINavigationController(rootViewController: tabBarController)
                    nav.navigationBar.isHidden = true
                    self.view.window?.rootViewController = nav
                }
            }
            
            if user?.business == 0 {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myViewController = storyboard.instantiateViewController(withIdentifier: "OtherProfileViewController")as! OtherProfileViewController
                myViewController.callback = { [self] (user) -> Void in
                    self.viewModel.allNotification?.msg?[indexPath.row].sender?.button = user.button
                    notificationsTableView.reloadData()
                }
                myViewController.userResponse = user
                myViewController.hidesBottomBarWhenPushed = true
                myViewController.otherUserId = sender.toString()
                self.navigationController?.pushViewController(myViewController, animated: true)
            }else {
//                let vc = BusinessProfileViewController(nibName: "BusinessProfileViewController", bundle: nil)
//                vc.hidesBottomBarWhenPushed = true
//                vc.callback = { [self] (user) -> Void in
//                    self.viewModel.allNotification?.msg?[indexPath.row].sender = user
//                    notificationsTableView.reloadData()
//                }
//                vc.user = user
//                vc.store = user?.store
//                vc.storeAddress = user?.store?.storeAddress
//                vc.storeLocalHours = user?.store?.storeLocalHours
//                self.navigationController?.pushViewController(vc, animated: true)
            }
            
           
        }else if notification?.type == "new_order" {
            let sender = viewModel.allNotification?.msg?[indexPath.row].sender?.id ?? 0
        
            
            if sender == nil || sender == 0 {
                 Utility.showMessage(message: "Something went wrong. Please try later", on: self.view)
                return
            }
            
            if sender.toString() == UserDefaultsManager.shared.user_id {
                let story = UIStoryboard(name: "Main", bundle: nil)
                if let tabBarController = story.instantiateViewController(withIdentifier: "TabbarViewController") as? UITabBarController {
                    tabBarController.selectedIndex = 4
                    let nav = UINavigationController(rootViewController: tabBarController)
                    nav.navigationBar.isHidden = true
                    self.view.window?.rootViewController = nav
                }
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let myViewController = storyboard.instantiateViewController(withIdentifier: "OtherProfileViewController")as! OtherProfileViewController
            myViewController.callback = { [self] (user) -> Void in
                self.viewModel.allNotification?.msg?[indexPath.row].sender = user
                notificationsTableView.reloadData()
            }
            myViewController.userResponse = user
            myViewController.hidesBottomBarWhenPushed = true
            myViewController.otherUserId = sender.toString()
            self.navigationController?.pushViewController(myViewController, animated: true)
        }else {
            if video?.id != nil {
                let newVideoMsg = HomeResponseMsg(
                    video: video,
                    user: user,
                    sound: video?.sound,
                    pinComment: nil,
                    location: viewModel.allNotification?.msg?[indexPath.row].location,
                    store: viewModel.allNotification?.msg?[indexPath.row].store,
                    hashtagVideo: nil,
                    hashtag: nil
                )
                self.lastSelectedIndexPath = indexPath
                let videoDetail = VideoDetailController()
                videoDetail.dataSource = [newVideoMsg]
                videoDetail.index = indexPath.row
                videoDetail.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(videoDetail, animated: true)
            }
        }
      
    }
    
    @objc func buttonClicked(sender: UIButton) {
        let cell = notificationsTableView.cellForRow(at: IndexPath(item: sender.tag, section: 0))as! FollowTableViewCell
        let sender1 = viewModel.allNotification?.msg?[sender.tag].sender
        let receiver = viewModel.allNotification?.msg?[sender.tag].receiver
        
        if sender1?.id == nil || sender1?.id == 0 {
             Utility.showMessage(message: "Something went wrong. Please try later", on: self.view)
            return
        }
    
        if cell.btnFollow.titleLabel?.text == "Message"{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationController = storyboard.instantiateViewController(withIdentifier: "newChatViewController") as! newChatViewController
            
            destinationController.modalPresentationStyle = .fullScreen
            destinationController.senderName = UserDefaultsManager.shared.username
            destinationController.senderID =  UserDefaultsManager.shared.user_id
            destinationController.profile_url = UserDefaultsManager.shared.profileUser
            destinationController.receiverID =  sender1?.id?.toString() ?? ""
            destinationController.receiverName = sender1?.username ?? ""
            destinationController.receiver_profile_url = sender1?.profilePic ?? ""
            self.navigationController?.pushViewController(destinationController, animated: true)
            return
        }
        
        var butt = ""
        if cell.btnFollow.titleLabel?.text == "Follow" {
            butt = "Following"
            cell.btnFollow.setTitle("Following", for: .normal)
            cell.btnFollow.backgroundColor = UIColor.appColor(.buttonColor)
            cell.btnFollow.setTitleColor(UIColor.appColor(.black), for: .normal)
        }else if cell.btnFollow.titleLabel?.text == "Following" {
            butt = "Follow"
            cell.btnFollow.setTitle("Follow", for: .normal)
            cell.btnFollow.backgroundColor = UIColor.appColor(.theme)
            cell.btnFollow.setTitleColor(UIColor.appColor(.white), for: .normal)
        }else if cell.btnFollow.titleLabel?.text == "Follow Back" {
            butt = "Message"
            cell.btnFollow.setTitle("Message", for: .normal)
            cell.btnFollow.backgroundColor = UIColor.appColor(.buttonColor)
            cell.btnFollow.setTitleColor(UIColor.appColor(.black), for: .normal)
        }
        
        viewModel.allNotification?.msg?[sender.tag].sender?.button = butt
        
        let followUser = FollowUserRequest(senderId: sender1?.id ?? 0, receiverId: receiver?.id ?? 0)
        viewModel.followUser(parameters: followUser)
        print("followUserRequest",followUser)
        self.currentIndexPath.item = sender.tag
        self.observeEvent()
        
    }

}

extension NotificationsViewController {
    
    func configuration() {
        notificationsTableView.delegate = self
        notificationsTableView.dataSource = self
        notificationsTableView.register(UINib(nibName: "VideoTypeTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoTypeTableViewCell")
        notificationsTableView.register(UINib(nibName: "FollowTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowTableViewCell")
        self.notificationsTableView.showsHorizontalScrollIndicator = false
        self.notificationsTableView.showsVerticalScrollIndicator = false
        if #available(iOS 11.0, *) {
            notificationsTableView.refreshControl = refresher
        } else {
            notificationsTableView.addSubview(refresher)
        }
        notificationsTableView.rowHeight = 70
        
        spinner.color = UIColor(named: "theme")
        spinner.hidesWhenStopped = true
        notificationsTableView.tableFooterView = spinner
        
        self.view.showAnimatedGradientSkeleton()
        notificationsTableView.showAnimatedGradientSkeleton()
    }
   
    func observeEvent() {
        viewModel.eventHandler = { [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .error(let error):
                print("error", error)
                DispatchQueue.main.async {
                    if let error = error {
                        if let dataError = error as? Moves.DataError {
                            switch dataError {
                            case .invalidResponse, .invalidURL, .network:
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

            case .newShowAllNotifications(showAllNotifications: let showAllNotifications):
                print("showAllNotifications", showAllNotifications.code)
                DispatchQueue.main.async {
                    if showAllNotifications.code == 200 {
                        if self.startPoint != 0, let newMessages = showAllNotifications.msg {
                            self.viewModel.allNotification?.msg?.append(contentsOf: newMessages)
                        }else {
                            self.viewModel.allNotification?.msg?.removeAll()
                            self.viewModel.allNotification = showAllNotifications
                           
                        }
                        
                        self.isDataLoading = false
                        self.isNextPageLoad = (self.viewModel.allNotification?.msg?.count ?? 0) >= 10
                       
                        self.notificationsTableView.reloadData()
                    } else {
                        if self.startPoint == 0 {
                            DispatchQueue.main.async {
                                self.lblNoNotification.isHidden = false
                            }
                        }
                        self.isDataLoading = true
                        self.isNextPageLoad = false
                    }
                    self.notificationsTableView.hideSkeleton()
                }
            case .newFollowUser(followUser: let followUser):
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .switchAccount, object: nil)
                }
                print("followUser")
            case .newReadNotification(readNotification: let readNotification):
                if readNotification.code == 200 {
                    DispatchQueue.main.async {
                        ConstantManager.isNotification = false
                        self.tabBarController?.tabBar.items?[3].badgeValue = nil
                    }
                }

            }
        }
    }
}

extension NotificationsViewController {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging")
        if !isNextPageLoad {
            self.spinner.stopAnimating()
            isDataLoading = true
        }else {
            isDataLoading = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        if !isNextPageLoad {
            self.spinner.stopAnimating()
            isDataLoading = true
        }else {
            isDataLoading = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let tableView = scrollView as? UITableView else { return }
        
        let contentOffsetY = tableView.contentOffset.y
        let contentHeight = tableView.contentSize.height
        let frameHeight = tableView.frame.size.height
        
        if (contentOffsetY + frameHeight) >= contentHeight - 100 {
            if !isDataLoading && isNextPageLoad {
                startPoint += 1
                isDataLoading = true
                spinner.startAnimating()
                
                let showNotification = NotificationRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: startPoint)
                viewModel.showAllNotifications(parameters: showNotification)
                print("showNotification", showNotification)
                DispatchQueue.main.async {
                    self.observeEvent()
                }
            }
        }
    }

}

extension NotificationsViewController: ZoomTransitionAnimatorDelegate {
    func transitionWillStart() {
        guard let lastSelected = self.lastSelectedIndexPath else { return }
        self.notificationsTableView.cellForRow(at: lastSelected)?.isHidden = true
    }

    func transitionDidEnd() {
        guard let lastSelected = self.lastSelectedIndexPath else { return }
        self.notificationsTableView.cellForRow(at: lastSelected)?.isHidden = false
    }

    func referenceImage() -> UIImage? {
        guard
            let lastSelected = self.lastSelectedIndexPath,
            let cell = self.notificationsTableView.cellForRow(at: lastSelected) as? VideoTypeTableViewCell
        else {
            return nil
        }

        return cell.imgVideoNotification.image
    }

    func imageFrame() -> CGRect? {
        guard
            let lastSelected = self.lastSelectedIndexPath,
            let cell = self.notificationsTableView.cellForRow(at: lastSelected) as? VideoTypeTableViewCell
        
        else {
            return self.view.frame
        }
        
        return FrameHelper.getTargerFrame(originalView: cell.imgVideoNotification, targetView: self.view)  ?? self.view.frame



    }
}
