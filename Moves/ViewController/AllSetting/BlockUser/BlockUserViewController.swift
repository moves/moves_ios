//
//  BlockUserViewController.swift
// //
//
//  Created by Wasiq Tayyab on 25/06/2024.
//

import SDWebImage
import SkeletonView
import UIKit

class BlockUserViewController: UIViewController {
    let spinner = UIActivityIndicatorView(style: .white)
    private var startPoint = 0
    var currentIndexPath = IndexPath(item: 0, section: 0)
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.appColor(.theme)
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        
        return refreshControl
    }()

    var showBlockedUsers: ShowBlockedUsersResponse?
    var isDataLoading: Bool = false
    private var viewModel = BlockUserViewModel()
    var isNextPageLoad = false
    var shouldAnimate = true
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet var lblNoData: UILabel!
    @IBOutlet var profileViewTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.delegate = self
        view.showAnimatedGradientSkeleton()
        profileViewTableView.showAnimatedGradientSkeleton()
        configuration()
    }
    
    func hideSkeleton() {
        view.hideSkeleton(transition: .crossDissolve(transitionDurationStepper))
        profileViewTableView.hideSkeleton(transition: .crossDissolve(transitionDurationStepper))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
    }
    
    @objc
    func requestData() {
        print("requesting data")
        startPoint = 0
        initViewModel(startingPoint: startPoint)
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}

extension BlockUserViewController: SkeletonTableViewDelegate, SkeletonTableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showBlockedUsers?.msg?.count ?? 0
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "UserTableViewCell"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as! UserTableViewCell
        let following = showBlockedUsers?.msg?[indexPath.row].blockedUser
        cell.profileImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        
        cell.profileImage.sd_setImage(with: URL(string: (following?.profilePic ?? "")), placeholderImage: UIImage(named: "videoPlaceholder"))
        cell.lblName.text = (following?.firstName ?? "") + " " + (following?.lastName ?? "")
        cell.lblUsername.text = following?.username
        
        cell.btnFollow.setTitle("Unblock", for: .normal)
        cell.btnFollow.backgroundColor = UIColor.appColor(.theme)
        cell.btnFollow.setTitleColor(UIColor.appColor(.white), for: .normal)
        
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
        let showBlockedUsers = viewModel.showBlockedUsers?.msg?[indexPath.row]
        
        if showBlockedUsers?.blockedUser.id == nil || showBlockedUsers?.blockedUser.id == 0 {
            Utility.showMessage(message: "Something went wrong. Please try later", on: view)
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myViewController = storyboard.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
        myViewController.hidesBottomBarWhenPushed = true
        myViewController.otherUserId = showBlockedUsers?.blockedUser.id.toString() ?? ""
        navigationController?.pushViewController(myViewController, animated: true)
    }
    
    @objc func buttonClicked(sender: UIButton) {
        var receiver = 0
        let showBlockedUsers = viewModel.showBlockedUsers?.msg?[sender.tag]
        receiver = showBlockedUsers?.blockedUser.id ?? 0
        
        let blockUser = BlockUserRequest(userId: UserDefaultsManager.shared.user_id, blockUserId: receiver.toString())
        viewModel.blockUser(parameters: blockUser)
        print("blockUser", blockUser)
    }
}

extension BlockUserViewController {
    func configuration() {
        profileViewTableView.delegate = self
        profileViewTableView.dataSource = self
        profileViewTableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserTableViewCell")
        spinner.color = UIColor(named: "theme")
        spinner.hidesWhenStopped = true
        profileViewTableView.tableFooterView = spinner
        profileViewTableView.rowHeight = 70
        if #available(iOS 11.0, *) {
            profileViewTableView.refreshControl = refresher
        } else {
            profileViewTableView.addSubview(refresher)
        }
        initViewModel(startingPoint: startPoint)
    }
    
    func initViewModel(startingPoint: Int) {
        let showBlock = ShowBlockedUsersRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: startPoint)
        viewModel.showBlockedUsers(parameters: showBlock)
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
                }
            case .newShowBlockedUsers(showBlockedUsers: let showBlockedUsers):
                if showBlockedUsers.code == 201 {
                    if startPoint == 0 {
                        DispatchQueue.main.async {
                            self.profileViewTableView.isHidden = true
                            self.showBlockedUsers?.msg?.removeAll()
                            self.profileViewTableView.reloadData()
                            self.lblNoData.isHidden = false
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.isNextPageLoad = false
                        }
                    }
                    DispatchQueue.main.async {
                        self.spinner.hidesWhenStopped = true
                        self.spinner.stopAnimating()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.lblNoData.isHidden = true
                    }
                    if startPoint == 0 {
                        viewModel.showBlockedUsers?.msg?.removeAll()
                        self.showBlockedUsers?.msg?.removeAll()
                        viewModel.showBlockedUsers = showBlockedUsers
                        self.showBlockedUsers = showBlockedUsers
                    } else {
                        if let newMessages = showBlockedUsers.msg {
                            viewModel.showBlockedUsers?.msg?.append(contentsOf: newMessages)
                            self.showBlockedUsers?.msg?.append(contentsOf: newMessages)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        if (self.showBlockedUsers?.msg?.count ?? 0) >= 10 {
                            self.isNextPageLoad = true
                        } else {
                            self.isNextPageLoad = false
                        }
                        self.profileViewTableView.hideSkeleton()
                        self.view.hideSkeleton()
                        self.profileViewTableView.reloadData()
                    }
                }
            case .newBlockUser(blockUser: let blockUser):
                if blockUser.code == 201 {
                    DispatchQueue.main.async {
                        let showBlock = ShowBlockedUsersRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: self.startPoint)
                        self.viewModel.showBlockedUsers(parameters: showBlock)
                        self.observeEvent()
                        self.profileViewTableView.reloadData()
                    }
                }
            case .newShowFavouriteVideos(showFavouriteVideos: let showFavouriteVideos):
                print("showFavouriteVideos")
            }
        }
    }
}

extension BlockUserViewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging")
        if isNextPageLoad == true {
            spinner.stopAnimating()
            isDataLoading = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
    }

    //
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
        if scrollView == profileViewTableView {
            if (profileViewTableView.contentOffset.y + profileViewTableView.frame.size.height) >= profileViewTableView.contentSize.height {
                if isNextPageLoad == true {
                    if !isDataLoading {
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
                spinner.hidesWhenStopped = true
                spinner.stopAnimating()
            }
        }
    }
}

extension BlockUserViewController: UINavigationBarDelegate { 
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
