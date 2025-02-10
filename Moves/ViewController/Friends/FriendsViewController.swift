//
//  FriendsViewController.swift
// //
//
//  Created by Wasiq Tayyab on 15/06/2024.
//

import SDWebImage
import SkeletonView
import UIKit

class FriendsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SkeletonTableViewDelegate, SkeletonTableViewDataSource {
    // MARK: - VARS
    
    fileprivate var menuTitles = [["menu": "Following", "isSelected": "false"],
                                  ["menu": "Followers", "isSelected": "false"],
                                  ["menu": "Suggested", "isSelected": "false"]]
    var selectedMenu = "Suggested"
    private var viewModel = FriendsViewModel()
    private var viewModel1 = NotificaitonViewModel()
 
    let spinner = UIActivityIndicatorView(style: .white)
    private var suggestedStartPoint = 0
    private var followersStartPoint = 0
    private var followingStartPoint = 0
    var isInitedFollowing = false
    var isInitedFollower = false
    var isInitedSuggested = false
    var otherUserId = ""
    var username = ""
    private var index = 2
    
    var privateFollower = false
    var privateFollowing = false

    private var isSuggestedApi = true
    private var isFollowerApi = true
    private var isFollowingApi = true
    
    var isNextPageLoad = true
    var isNextFollowersPageLoad = true
    var isNextFollowingPageLoad = true
    
    var currentIndexPath = IndexPath(item: 0, section: 0)
    private var showSuggestedUsers: SuggestedResponse?
    private var showFollowing: FollowingResponse?
    private var showFollowers: FollowerResponse?
    var isDataLoading: Bool = true
    var objNotification: Any?
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.appColor(.theme)
        refreshControl.addTarget(self, action: #selector(self.requestData), for: .valueChanged)
        
        return refreshControl
    }()

    var shouldAnimate = true

    // MARK: - OUTLET

    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet var friendTableView: UITableView!
    @IBOutlet var menuCollectionView: UICollectionView!
    @IBOutlet var heightTable: NSLayoutConstraint!
    @IBOutlet var lblNoData: UILabel!
    
    // MARK: - VIEW DID LOAD

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let index = menuTitles.firstIndex(where: { $0["menu"] == selectedMenu }) {
            menuTitles[index]["isSelected"] = "true"
        }
        
        self.menuCollectionView.delegate = self
        self.menuCollectionView.dataSource = self
        self.menuCollectionView.register(UINib(nibName: "SearchCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SearchCollectionViewCell")
        
        self.lblUsername.text = "@" + username
        
        self.friendTableView.delegate = self
        self.friendTableView.dataSource = self
        self.friendTableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserTableViewCell")
        self.friendTableView.rowHeight = 70
        self.spinner.color = UIColor(named: "theme")
        self.spinner.hidesWhenStopped = true
        self.friendTableView.tableFooterView = self.spinner
        
        self.view.showAnimatedGradientSkeleton()
        self.friendTableView.showAnimatedGradientSkeleton()
      
        if #available(iOS 11.0, *) {
            friendTableView.refreshControl = refresher
        } else {
            self.friendTableView.addSubview(self.refresher)
        }
        self.initViewModel(startingPoint: 0)
        
        self.objNotification = NotificationCenter.default.addObserver(self, selector: #selector(self.switchAccount(notification:)), name: .switchAccount, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
    }
    
    deinit {
        NotificationCenter.default.removeObserver(objNotification)
    }
   
    @objc
    func requestData() {
        print("requesting data")
        if self.selectedMenu == "Following" {
            self.followingStartPoint = 0
            let following = FriendsRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: self.followingStartPoint, otherUserId: self.otherUserId)
            self.viewModel.showFollowing(parameters: following)
            print("following", following)
        } else if self.selectedMenu == "Followers" {
            self.followersStartPoint = 0
            let follower = FriendsRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: self.followersStartPoint, otherUserId: self.otherUserId)
            self.viewModel.showFollowers(parameters: follower)
            print("follower", follower)
        } else {
            self.suggestedStartPoint = 0
            let suggested = ShowSuggestedUsersRequest(userId: UserDefaultsManager.shared.user_id, otherUserId: nil, startingPoint: self.suggestedStartPoint)
            self.viewModel.showSuggestedUsers(parameters: suggested)
        }
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    
    @objc func switchAccount(notification: NSNotification) {
        self.initViewModel(startingPoint: 0)
    }

    // MARK: - FUNCTION
    
    @objc func StoreSelectedIndex(index: Int) {
        self.index = index
        var obj = self.menuTitles[index]
        obj.updateValue("true", forKey: "isSelected")
        self.menuTitles[index] = obj

        self.menuCollectionView.reloadData()
        
        print("isNextPageLoad", self.isNextPageLoad)
        
        if !self.isNextPageLoad {
            self.isDataLoading = true
        } else if !self.isNextFollowersPageLoad {
            self.isDataLoading = true
        } else if !self.isNextFollowingPageLoad {
            self.isDataLoading = true
        }
        
        if index == 0 {
            self.selectedMenu = "Following"
            let hasData = (viewModel.showFollowing?.msg?.count ?? 0) > 0
            if !hasData {
                self.friendTableView.isHidden = false
                self.lblNoData.isHidden = true
            }
            
            if self.isFollowingApi {
                self.friendTableView.showAnimatedGradientSkeleton()
                return
            }
            
            if let followerCount = viewModel.showFollowing?.msg?.count, followerCount > 0 {
                self.isNextPageLoad = (self.showFollowing?.msg?.count ?? 0) >= 10
                
                self.friendTableView.isHidden = false
                self.lblNoData.isHidden = true
                
                self.showFollowing?.msg?.removeAll()
                self.showFollowing = self.viewModel.showFollowing
//                self.heightTable.constant = CGFloat((self.showFollowing?.msg?.count ?? 0) * 70)
                
                self.friendTableView.reloadData()
            } else {
                if !isInitedFollowing {
                    self.initViewModel(startingPoint: 0)
                    self.isInitedFollowing = true
                }else {
                    self.lblNoData.isHidden = false
                    self.lblNoData.text = "You don’t have any following users yet"
                    self.friendTableView.isHidden = true
                }
            }

        } else if index == 1 {
            self.selectedMenu = "Followers"
            let hasData = (viewModel.showFollowers?.msg?.count ?? 0) > 0
            print("hasData", hasData)
            if !hasData {
                self.friendTableView.isHidden = false
                self.lblNoData.isHidden = true
            }
         
            if let followerCount = viewModel.showFollowers?.msg?.count, followerCount > 0 {
                self.isNextPageLoad = (self.showFollowers?.msg?.count ?? 0) >= 10
                
                self.friendTableView.isHidden = false
                self.lblNoData.isHidden = true
                
                self.showFollowers?.msg?.removeAll()
                self.showFollowers = self.viewModel.showFollowers
//                self.heightTable.constant = CGFloat((self.showFollowers?.msg?.count ?? 0) * 70)
                
                self.friendTableView.reloadData()
            } else {
                if !isInitedFollower {
                    self.friendTableView.showAnimatedGradientSkeleton()
                    self.initViewModel(startingPoint: 0)
                    self.isInitedFollower = true
                }else {
                    self.lblNoData.isHidden = false
                    self.lblNoData.text = "You don’t have any followers yet"
                    self.friendTableView.isHidden = true
                }
               
            }
            
        } else {
            self.selectedMenu = "Suggested"
            let hasData = (viewModel.showSuggestedUsers?.msg?.count ?? 0) > 0
            if !hasData {
                self.friendTableView.isHidden = false
                self.lblNoData.isHidden = true
            }
           

            if let followerCount = viewModel.showSuggestedUsers?.msg?.count, followerCount > 0 {
                self.isNextPageLoad = (self.showSuggestedUsers?.msg?.count ?? 0) >= 10
                
                self.friendTableView.isHidden = false
                self.lblNoData.isHidden = true
                
                self.showSuggestedUsers?.msg?.removeAll()
                self.showSuggestedUsers = self.viewModel.showSuggestedUsers
//                self.heightTable.constant = CGFloat((self.showSuggestedUsers?.msg?.count ?? 0) * 70)
                
                self.friendTableView.reloadData()
            } else {
                
                if !isInitedSuggested {
                    self.friendTableView.showAnimatedGradientSkeleton()
                    self.initViewModel(startingPoint: 0)
                    self.isInitedSuggested = true
                }else {
                    self.lblNoData.isHidden = false
                    self.lblNoData.text = "You don’t have any suggested users yet"
                    self.friendTableView.isHidden = true
                }
               
                
            }
        }
        self.menuCollectionView.reloadData()
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - COLLECTION VIEW
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.menuTitles.count
    }
  
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCollectionViewCell", for: indexPath) as! SearchCollectionViewCell
        cell.lblMenu.text = self.menuTitles[indexPath.row]["menu"] ?? ""
        if self.menuTitles[indexPath.row]["isSelected"] == "true" {
            cell.lineView.isHidden = false
            cell.lineView.backgroundColor = UIColor.appColor(.theme)
            cell.lblMenu.textColor = UIColor.appColor(.theme)
            self.selectedMenu = self.menuTitles[indexPath.row]["menu"] ?? ""
        } else {
            cell.lineView.isHidden = true
            cell.lblMenu.textColor = UIColor.appColor(.darkGrey)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Int(collectionView.frame.width) / 3, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for i in 0 ..< self.menuTitles.count {
            var obj = self.menuTitles[i]
            obj.updateValue("false", forKey: "isSelected")
            self.menuTitles[i] = obj
        }
        self.StoreSelectedIndex(index: indexPath.row)
    }
    
    // MARK: - TABLE VIEW

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectedMenu == "Following" {
            return self.showFollowing?.msg?.count ?? 0
        } else if self.selectedMenu == "Followers" {
            return self.showFollowers?.msg?.count ?? 0
        } else {
            return self.showSuggestedUsers?.msg?.count ?? 0
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "UserTableViewCell"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as! UserTableViewCell
        
        cell.lblFollowers.isHidden = true
        cell.imgVerified.isHidden = true
        
        let user: HomeUser?
        let store: Store?
        
        if self.selectedMenu == "Suggested" {
            user = self.showSuggestedUsers?.msg?[indexPath.row].user
            store = self.showSuggestedUsers?.msg?[indexPath.row].store
            
            cell.btnCancel.isHidden = false
            cell.btnCancel1.isHidden = false
        } else {
            user = self.selectedMenu == "Following" ? self.showFollowing?.msg?[indexPath.row].user : self.showFollowers?.msg?[indexPath.row].user
            store = self.selectedMenu == "Following" ? self.showFollowing?.msg?[indexPath.row].store : self.showFollowers?.msg?[indexPath.row].store
            
            cell.btnCancel.isHidden = true
            cell.btnCancel1.isHidden = true
        }
        
        let placeholderImage = (user?.business == 1 || user?.business == 2) ? "mealMePlaceholder" : "privateOrderPlaceholder"
        let profilePicURLString = (user?.business == 1 || user?.business == 2) ? store?.logoPhotos : user?.profilePic
        let profilePicURL = URL(string: profilePicURLString ?? "")
        
        let invalidURLString = "https://cdn-img.mealme.ai/2c95a5a823fbebaf0b8dcebfaa64e5e4a20151c3/68747470733a2f2f7777772e70616e6461657870726573732e636f6d2f7468656d65732f637573746f6d2f70616e64612f6c6f676f2e706e67"
        let isValidProfilePic = profilePicURL?.absoluteString != invalidURLString
        
        cell.profileImage.sd_setImage(with: isValidProfilePic ? profilePicURL : nil, placeholderImage: UIImage(named: placeholderImage))
        
        let fullName = "\(user?.firstName ?? "") \(user?.lastName ?? "")"
        cell.lblName.text = fullName
        
        if let storeName = user?.store?.name {
            cell.lblName.isHidden = true
            cell.lblUsername.text = storeName
        } else {
            cell.lblName.isHidden = false
            cell.lblUsername.text = user?.username
        }

        let followTitle: String
        let backgroundColor: UIColor
        let titleColor: UIColor
        
        switch user?.button?.lowercased() {
        case "follow", nil:
            followTitle = "Follow"
            backgroundColor = .appColor(.theme) ?? .clear
            titleColor = .appColor(.white) ?? .clear
        case "following":
            followTitle = "Following"
            backgroundColor = .appColor(.buttonColor) ?? .clear
            titleColor = .appColor(.black) ?? .clear
        default:
            followTitle = "Friends"
            backgroundColor = .appColor(.buttonColor) ?? .clear
            titleColor = .appColor(.black) ?? .clear
        }
        
        cell.btnFollow.setTitle(followTitle, for: .normal)
        cell.btnFollow.backgroundColor = backgroundColor
        cell.btnFollow.setTitleColor(titleColor, for: .normal)

        for button in [cell.btnFollow, cell.btnFollow1, cell.btnCancel, cell.btnCancel1] {
            button?.tag = indexPath.row
            button?.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        }
        
        return cell
    }

    @objc func removeUser(sender: UIButton) {
        self.viewModel.showSuggestedUsers?.msg?.remove(at: sender.tag)
        self.showSuggestedUsers?.msg?.remove(at: sender.tag)
        self.friendTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var userId = 0
        var isBusinessUser = false
        var user: HomeUser?
        var store: Store?
        var storeAddress: StoreAddress?
        var storeLocalHours: [StoreLocalHour]?

        switch self.selectedMenu {
        case "Following":
            let showFollowing = showFollowing?.msg?[indexPath.row]
            userId = showFollowing?.user?.id ?? 0
            isBusinessUser = showFollowing?.user?.business == 2 || showFollowing?.user?.business == 1
            user = showFollowing?.user
            store = showFollowing?.store
            storeAddress = showFollowing?.store?.storeAddress
            storeLocalHours = showFollowing?.store?.storeLocalHours
        case "Followers":
            let showFollower = self.showFollowers?.msg?[indexPath.row]
            userId = showFollower?.user?.id ?? 0
            isBusinessUser = showFollower?.user?.business == 2 || showFollower?.user?.business == 1
            user = showFollower?.user
            store = showFollower?.store
            storeAddress = showFollower?.store?.storeAddress
            storeLocalHours = showFollower?.store?.storeLocalHours
        default:
            let showSuggestedUsers = showSuggestedUsers?.msg?[indexPath.row]
            userId = showSuggestedUsers?.user?.id ?? 0
            isBusinessUser = showSuggestedUsers?.user?.business == 2 || showSuggestedUsers?.user?.business == 1
            user = showSuggestedUsers?.user
            store = showSuggestedUsers?.store
            storeAddress = showSuggestedUsers?.store?.storeAddress
            storeLocalHours = showSuggestedUsers?.store?.storeLocalHours
        }

        if userId == 0 {
            Utility.showMessage(message: "Something went wrong. Please try later", on: self.view)
            return
        }
        
        if isBusinessUser {
//            let vc = BusinessProfileViewController(nibName: "BusinessProfileViewController", bundle: nil)
//            vc.hidesBottomBarWhenPushed = true
//            vc.callback = { [self] user in
//                switch self.selectedMenu {
//                case "Following":
//                    self.showFollowing?.msg?[indexPath.row].user = user
//                case "Followers":
//                    self.showFollowers?.msg?[indexPath.row].user = user
//                default:
//                    self.showSuggestedUsers?.msg?[indexPath.row].user = user
//                }
//                self.friendTableView.reloadData()
//            }
//            vc.currentIndexPath = indexPath
//            vc.user = user
//            vc.store = store
//            vc.storeAddress = storeAddress
//            vc.storeLocalHours = storeLocalHours
//            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            var userReponse: HomeUser?
            switch self.selectedMenu {
            case "Following":
                userReponse = self.showFollowing?.msg?[indexPath.row].user
            case "Followers":
                userReponse = self.showFollowers?.msg?[indexPath.row].user
            default:
                userReponse = self.showSuggestedUsers?.msg?[indexPath.row].user
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let myViewController = storyboard.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
            
            myViewController.callback = { [self] user in
                switch self.selectedMenu {
                case "Following":
                    self.showFollowing?.msg?[indexPath.row].user = user
                case "Followers":
                    self.showFollowers?.msg?[indexPath.row].user = user
                default:
                    self.showSuggestedUsers?.msg?[indexPath.row].user = user
                }
                self.friendTableView.reloadData()
            }
            
            myViewController.hidesBottomBarWhenPushed = true
            myViewController.userResponse = userReponse
            myViewController.otherUserId = userId.toString()
            self.navigationController?.pushViewController(myViewController, animated: true)
        }
    }
    
    @objc func buttonClicked(sender: UIButton) {
        let cell = self.friendTableView.cellForRow(at: IndexPath(item: sender.tag, section: 0)) as! UserTableViewCell
        var butt = ""
        var receiver = 0
        if self.selectedMenu == "Following" {
            let following = self.viewModel.showFollowing?.msg?[sender.tag]
            receiver = following?.user?.id ?? 0
        } else if self.selectedMenu == "Followers" {
            let following = self.viewModel.showFollowers?.msg?[sender.tag]
            receiver = following?.user?.id ?? 0
        } else {
            let following = self.viewModel.showSuggestedUsers?.msg?[sender.tag]
            receiver = following?.user?.id ?? 0
        }
        if receiver == nil || receiver == 0 {
            Utility.showMessage(message: "Something went wrong. Please try later", on: self.view)
            return
        }
        
        if cell.btnFollow.titleLabel?.text == "Follow" {
            butt = "Following"
            cell.btnFollow.setTitle("Following", for: .normal)
            cell.btnFollow.backgroundColor = UIColor.appColor(.buttonColor)
            cell.btnFollow.setTitleColor(UIColor.appColor(.black), for: .normal)
        } else if cell.btnFollow.titleLabel?.text == "Following" {
            butt = "Follow"
            cell.btnFollow.setTitle("Follow", for: .normal)
            cell.btnFollow.backgroundColor = UIColor.appColor(.theme)
            cell.btnFollow.setTitleColor(UIColor.appColor(.white), for: .normal)
        } else {
            butt = "Follow"
            cell.btnFollow.setTitle("Follow", for: .normal)
            cell.btnFollow.backgroundColor = UIColor.appColor(.theme)
            cell.btnFollow.setTitleColor(UIColor.appColor(.white), for: .normal)
        }
        
        if self.selectedMenu == "Following" {
            self.viewModel.showFollowing?.msg?[sender.tag].user?.button = butt
        } else if self.selectedMenu == "Followers" {
            self.viewModel.showFollowers?.msg?[sender.tag].user?.button = butt
        } else {
            self.viewModel.showSuggestedUsers?.msg?[sender.tag].user?.button = butt
        }
    
        let followUser = FollowUserRequest(senderId: UserDefaultsManager.shared.user_id.toInt() ?? 0, receiverId: receiver)
        self.viewModel1.followUser(parameters: followUser)

        self.currentIndexPath.item = sender.tag
        self.observeEvent1()
    }
}

extension FriendsViewController {
    func initViewModel(startingPoint: Int) {
        if self.selectedMenu == "Following" {
            let following = FriendsRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: startingPoint, otherUserId: self.otherUserId)
            self.viewModel.showFollowing(parameters: following)
            print("following", following)
        } else if self.selectedMenu == "Followers" {
            let follower = FriendsRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: startingPoint, otherUserId: self.otherUserId)
            self.viewModel.showFollowers(parameters: follower)
            print("follower", follower)
        } else {
            let suggested = ShowSuggestedUsersRequest(userId: self.otherUserId, otherUserId: nil, startingPoint: startingPoint)
            self.viewModel.showSuggestedUsers(parameters: suggested)
            print("suggested", suggested)
        }
        
        DispatchQueue.main.async {
            self.observeEvent() // UI-related work on the main thread
        }
    }
    
    func observeEvent() {
        self.friendTableView.isHidden = false
        self.viewModel.eventHandler = { [weak self] event in
            guard let self else { return }
            
            switch event {
            case .error(let error):
                print("error", error ?? "")
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
                    self.friendTableView.hideSkeleton()
                }

            case .newShowSuggestedUsers(showSuggestedUsers: let showSuggestedUsers):
                if self.suggestedStartPoint == 0 {
                    self.isDataLoading = false
                    self.viewModel.showSuggestedUsers?.msg?.removeAll()
                    self.showSuggestedUsers?.msg?.removeAll()
                    self.viewModel.showSuggestedUsers = showSuggestedUsers
                    self.showSuggestedUsers = showSuggestedUsers
                }

                if showSuggestedUsers.code == 200 {
                    DispatchQueue.main.async {
                        self.lblNoData.isHidden = true
                    }

                    self.isNextPageLoad = (self.showSuggestedUsers?.msg?.count ?? 0) >= 10
                    if self.suggestedStartPoint != 0, let newMessages = showSuggestedUsers.msg {
                        let currentUserIds = self.viewModel.showSuggestedUsers?.msg?.compactMap { $0.user?.id } ?? []
                        let filteredNewMessages = newMessages.filter { !currentUserIds.contains($0.user?.id ?? 0) }
                        
                        self.viewModel.showSuggestedUsers?.msg?.append(contentsOf: filteredNewMessages)
                        self.showSuggestedUsers?.msg?.append(contentsOf: filteredNewMessages)
                        
                        self.isDataLoading = false
                    }

                    DispatchQueue.main.async {
                        self.friendTableView.reloadData()
                    }
                   
                } else {
                    DispatchQueue.main.async {
                        if self.suggestedStartPoint == 0 {
                            self.friendTableView.hideSkeleton()
                            self.friendTableView.isHidden = true
                        } else {
                            self.isNextPageLoad = false
                        }
                        self.isDataLoading = true
                    }
                }

                // Update UI on the main thread
                DispatchQueue.main.async {
//                    self.heightTable.constant = CGFloat((self.showSuggestedUsers?.msg?.count ?? 0) * 70)
                    self.spinner.hidesWhenStopped = true
                    self.spinner.stopAnimating()
                    self.isSuggestedApi = false
                    if !self.isSuggestedApi {
                        self.friendTableView.hideSkeleton()
                    }
                    self.friendTableView.hideSkeleton()
                }

            case .newShowFollowing(showFollowing: let showFollowing):
                print("showFollowing", showFollowing.code)
                
                if self.followingStartPoint == 0 {
                    self.isDataLoading = false
                    self.viewModel.showFollowing?.msg?.removeAll()
                    self.showFollowing?.msg?.removeAll()
                    self.viewModel.showFollowing = showFollowing
                    self.showFollowing = showFollowing
                }
              
                if showFollowing.code == 200 {
                    self.privateFollower = false
                    if self.followingStartPoint != 0, let newMessages = showFollowing.msg {
                        self.viewModel.showFollowing?.msg?.append(contentsOf: newMessages)
                        self.showFollowing?.msg?.append(contentsOf: newMessages)
                        self.isDataLoading = false
                    }
                    DispatchQueue.main.async {
                        self.isNextFollowingPageLoad = (self.showFollowing?.msg?.count ?? 0) >= 10
                        self.friendTableView.reloadData()
                    }
                  
                } else {
                    DispatchQueue.main.async {
                        if self.followingStartPoint == 0 {
                            self.viewModel.showFollowing?.msg?.removeAll()
                            self.showFollowing?.msg?.removeAll()
                        } else {
                            self.isNextFollowingPageLoad = false
                        }
                        self.isDataLoading = true
                        
                        if self.index == 0 {
                            if self.followingStartPoint == 0 {
                                self.privateFollower = true
                            }
                            self.friendTableView.reloadData()
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    if self.privateFollower {
                        self.lblNoData.isHidden = false
                        self.lblNoData.text = "You don’t have any followers yet"
                    }
                    
                    self.friendTableView.hideSkeleton()
                    self.isFollowingApi = false
                }

            case .newShowFollowers(showFollowers: let showFollowers):
                if self.followersStartPoint == 0 {
                    self.isDataLoading = false
                    self.viewModel.showFollowers?.msg?.removeAll()
                    self.showFollowers?.msg?.removeAll()
                    self.viewModel.showFollowers = showFollowers
                    self.showFollowers = showFollowers
                }
                
                if showFollowers.code == 200 {
                    self.privateFollowing = false
                    if self.followersStartPoint != 0, let newMessages = showFollowers.msg {
                        self.viewModel.showFollowers?.msg?.append(contentsOf: newMessages)
                        self.showFollowers?.msg?.append(contentsOf: newMessages)
                        self.isDataLoading = false
                    }
                    DispatchQueue.main.async {
                        self.friendTableView.reloadData()
                        self.isNextFollowersPageLoad = (self.showFollowers?.msg?.count ?? 0) >= 10
                    }
                   
                } else {
                    DispatchQueue.main.async {
                        if self.followersStartPoint == 0 {
                            self.viewModel.showFollowers?.msg?.removeAll()
                            self.showFollowers?.msg?.removeAll()
                        } else {
                            self.isNextFollowersPageLoad = false
                        }
                        if self.index == 1 {
                            if self.followersStartPoint == 0 {
                                self.privateFollowing = true
                            }
                           
                            self.friendTableView.reloadData()
                        }
                        self.isDataLoading = true
                    }
                }
               
                
                DispatchQueue.main.async {
                    if self.privateFollowing {
                        self.lblNoData.isHidden = false
                        self.lblNoData.text = "You don’t have any following yet"
                    }
                    self.friendTableView.hideSkeleton()
                    self.isFollowerApi = false
                }
            }
        }
    }
    
    func observeEvent1() {
        self.viewModel1.eventHandler = { [weak self] event in
            guard let self else { return }
            
            switch event {
            case .error(let error):
                print("error", error ?? "")
                DispatchQueue.main.async {
                    if let urlError = error as? URLError, urlError.code == .badServerResponse {
                        Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                    } else {
//                       Utility.showMessage(message: "Something went wrong. Please try again", on: self.view)
                    }
                }
            case .newShowAllNotifications(showAllNotifications: _):
                print("showAllNotifications")
            case .newFollowUser(followUser: let followUser):
                print("followUser")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .switchAccount, object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name("changeNumber"), object: nil, userInfo: nil)
                }
            case .newReadNotification(readNotification: let readNotification):
                print("followUser")
            }
        }
    }
}

extension FriendsViewController {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        self.spinner.stopAnimating()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let tableView = scrollView as? UITableView else { return }
        
        let contentOffsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        if contentOffsetY + frameHeight > contentHeight - 100 {
            if !self.isDataLoading {
                self.handlePagination(for: tableView)
            }
        }
    }
    
    private func handlePagination(for tableView: UITableView) {
        self.isDataLoading = true
        self.spinner.startAnimating()
        
        var startingPoint: Int
        switch self.selectedMenu {
        case "Following":
            self.followingStartPoint += 1
            startingPoint = self.followingStartPoint
        case "Followers":
            self.followersStartPoint += 1
            startingPoint = self.followersStartPoint
        default:
            self.suggestedStartPoint += 1
            startingPoint = self.suggestedStartPoint
        }
        
        self.initViewModel(startingPoint: startingPoint)
    }
    
    
}
