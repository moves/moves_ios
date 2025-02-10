//
//  ProfileViewViewController.swift
// //
//
//  Created by Wasiq Tayyab on 22/06/2024.
//

import UIKit
import SDWebImage
import SkeletonView
class ProfileViewViewController: UIViewController {
    
    let spinner = UIActivityIndicatorView(style: .white)
    private var startPoint = 0
    var currentIndexPath = IndexPath(item: 0, section: 0)
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.appColor(.theme)
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        
        return refreshControl
    }()
    private var viewModel1 = NotificaitonViewModel()
    var showProfileVisitors: ShowProfileVisitorsResponse?
    var isDataLoading:Bool = false
    private var viewModel = ProfileViewViewModel()
    var isNextPageLoad = false

    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var profileViewTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configuration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
    }
    
    @objc
    func requestData() {
        print("requesting data")
        self.startPoint = 0
        self.initViewModel(startingPoint: startPoint)
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }


    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    

}

extension ProfileViewViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.showProfileVisitors?.msg?.count ?? 0
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath)as! UserTableViewCell
        let following = showProfileVisitors?.msg?[indexPath.row].visitor
        cell.profileImage.sd_imageIndicator = SDWebImageActivityIndicator.gray

        cell.profileImage.sd_setImage(with: URL(string:(following?.profilePic ?? "")), placeholderImage: UIImage(named: "videoPlaceholder"))
        cell.lblName.text = (following?.firstName ?? "") + " " + (following?.lastName ?? "")
        cell.lblUsername.text = following?.username
        
        if following?.button == "Follow" {
            cell.btnFollow.setTitle("Follow", for: .normal)
            cell.btnFollow.backgroundColor = UIColor.appColor(.theme)
            cell.btnFollow.setTitleColor(UIColor.appColor(.white), for: .normal)
        }else if following?.button == "Following"{
            cell.btnFollow.setTitle("Following", for: .normal)
            cell.btnFollow.backgroundColor = UIColor.appColor(.buttonColor)
            cell.btnFollow.setTitleColor(UIColor.appColor(.black), for: .normal)
        }else {
            cell.btnFollow.setTitle("Friends", for: .normal)
            cell.btnFollow.backgroundColor = UIColor.appColor(.buttonColor)
            cell.btnFollow.setTitleColor(UIColor.appColor(.black), for: .normal)
        }
        cell.btnCancel.isHidden = true
        cell.imgVerified.isHidden = true
        cell.btnFollow.tag = indexPath.row
        cell.btnFollow.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        cell.lblFollowers.isHidden = true
        cell.btnFollow1.tag = indexPath.row
        cell.btnFollow1.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let following = showProfileVisitors?.msg?[indexPath.row].visitor.id ?? 0
        if following == nil || following == 0 {
             Utility.showMessage(message: "Something went wrong. Please try later", on: self.view)
            return
        }
        
        if following.toString() == UserDefaultsManager.shared.user_id {
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
            showProfileVisitors?.msg?[indexPath.row].visitor.button = user.button
            profileViewTableView.reloadData()
        }
        myViewController.hidesBottomBarWhenPushed = true
        myViewController.userResponse = showProfileVisitors?.msg?[indexPath.row].visitor
        myViewController.otherUserId = following.toString()
        self.navigationController?.pushViewController(myViewController, animated: true)
    }
  
    @objc func buttonClicked(sender: UIButton) {
        let cell = profileViewTableView.cellForRow(at: IndexPath(item: sender.tag, section: 0))as! UserTableViewCell
        var receiver = 0
        let visitor = self.showProfileVisitors?.msg?[sender.tag]
        receiver = visitor?.visitor.id ?? 0
        if receiver == nil || receiver == 0 {
             Utility.showMessage(message: "Something went wrong. Please try later", on: self.view)
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
        }else {
            butt = "Follow"
            cell.btnFollow.setTitle("Follow", for: .normal)
            cell.btnFollow.backgroundColor = UIColor.appColor(.theme)
            cell.btnFollow.setTitleColor(UIColor.appColor(.white), for: .normal)
        }
        
        self.showProfileVisitors?.msg?[sender.tag].visitor.button = butt
        
        let followUser = FollowUserRequest(senderId: UserDefaultsManager.shared.user_id.toInt() ?? 0, receiverId: receiver)
        viewModel1.followUser(parameters: followUser)
        print("followUserRequest",followUser)
        self.currentIndexPath.item = sender.tag
        self.observeEvent1()
        
    }
}

extension ProfileViewViewController {
    
    func configuration() {
        profileViewTableView.delegate = self
        profileViewTableView.dataSource = self
        profileViewTableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserTableViewCell")
        spinner.color = UIColor(named: "theme")
        spinner.hidesWhenStopped = true
        profileViewTableView.tableFooterView = spinner
        self.profileViewTableView.rowHeight = 70
        if #available(iOS 11.0, *) {
            profileViewTableView.refreshControl = refresher
        } else {
            profileViewTableView.addSubview(refresher)
        }
        initViewModel(startingPoint: startPoint)
    }
    
    func initViewModel(startingPoint:Int) {
        let profileView = FriendsRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: startingPoint, otherUserId: "")
        viewModel.showProfileVisitors(parameters: profileView)
        observeEvent()
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
                
            case .newShowProfileVisitors(showProfileVisitors: let showProfileVisitors):
                if showProfileVisitors.code == 201 {
                    if startPoint == 0 {
                        DispatchQueue.main.async {
                            self.lblNoData.isHidden = false
                            self.lblNoData.text = "You don’t have any profile views yet"
                        }
                    }else {
                        DispatchQueue.main.async {
                            self.isNextPageLoad = false
                        }
                    }
                    DispatchQueue.main.async {
                        self.spinner.hidesWhenStopped = true
                        self.spinner.stopAnimating()
                    }
                }else {
                    DispatchQueue.main.async {
                        self.lblNoData.isHidden = true
                    }
                    if startPoint == 0 {
                        viewModel.showProfileVisitors?.msg?.removeAll()
                        self.showProfileVisitors?.msg?.removeAll()
                        viewModel.showProfileVisitors = showProfileVisitors
                        self.showProfileVisitors = showProfileVisitors
                    }else {
                        
                        if let newMessages = showProfileVisitors.msg {
                            
                            viewModel.showProfileVisitors?.msg?.append(contentsOf: newMessages)
                            self.showProfileVisitors?.msg?.append(contentsOf: newMessages)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        if (self.showProfileVisitors?.msg?.count ?? 0) >= 10 {
                            self.isNextPageLoad = true
                        }else {
                            self.isNextPageLoad = false
                        }
                        self.profileViewTableView.reloadData()
                    }
                }
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
            case .newShowAllNotifications(showAllNotifications: let showAllNotifications):
                print("showAllNotifications")
            case .newFollowUser(followUser: let followUser):
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .switchAccount, object: nil)
                }
                print("showAllNotifications")
            case .newReadNotification(readNotification: let readNotification):
                print("readNotification")
            }
        }
    }
}

extension ProfileViewViewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        print("scrollViewWillBeginDragging")
        if isNextPageLoad == true {
            self.spinner.stopAnimating()
            isDataLoading = false
        }
      
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        self.spinner.stopAnimating()
    }
    //
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        print("scrollViewDidEndDragging")
        if scrollView == self.profileViewTableView{
            if ((profileViewTableView.contentOffset.y + profileViewTableView.frame.size.height) >= profileViewTableView.contentSize.height)
            {
                if isNextPageLoad == true {
                    if !isDataLoading{
                        isDataLoading = true
                        spinner.startAnimating()
                        startPoint += 1
                        initViewModel(startingPoint: startPoint)
                    }

                }
              
            }
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (profileViewTableView.contentOffset.y + profileViewTableView.frame.size.height) >= profileViewTableView.contentSize.height {
            if isNextPageLoad == true {
                self.spinner.hidesWhenStopped = true
                self.spinner.stopAnimating()
            }
           
        }
    }
}
