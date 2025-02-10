//
//  TagFriendsViewController.swift
// //
//
//  Created by Macbook Pro on 03/09/2024.
//

import UIKit
import SDWebImage
import SkeletonView

protocol tagFriendDelegate:class{
    func listFriends(obj:[[String:Any]])
}


class TagFriendsViewController: UIViewController ,SkeletonTableViewDelegate, SkeletonTableViewDataSource,UISearchBarDelegate {

    //MARK: - Variables
    
    private var viewModel = FriendsViewModel()
    private var viewModel1 = SearchViewModel()
    
    private var showFollowing: FollowingResponse?
    let coverableCellsIds = ["UserTableViewCell"]
    let spinner = UIActivityIndicatorView(style: .white)
    private var startPoint = 0
    var isNextPageLoad = false
    var currentIndexPath = IndexPath(item: 0, section: 0)
    var isDataLoading:Bool = true
    var isReload = false
    var objNotification:Any?
    var delegate:tagFriendDelegate?
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.appColor(.theme)
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        
        return refreshControl
    }()
    var shouldAnimate = true
    var selectedFriends:[HomeUser] = []
    var select_Indexes:[[String:Any]] = []
    var isSearch =  false
    
    //MARK: - OUTLET
    @IBOutlet weak var friendTableView: UITableView!
    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var tfSearch: UISearchBar!
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.friendTableView.delegate = self
        self.friendTableView.dataSource = self
        self.friendTableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserTableViewCell")
        self.friendTableView.rowHeight = 70
        self.tfSearch.delegate  = self
        self.spinner.color = UIColor(named: "theme")
        self.spinner.hidesWhenStopped = true
        self.friendTableView.tableFooterView = spinner
        self.view.showAnimatedGradientSkeleton()
        self.friendTableView.showAnimatedGradientSkeleton()
        self.friendTableView.refreshControl = refresher
        objNotification = NotificationCenter.default.addObserver(self, selector: #selector(switchAccount(notification:)), name: .switchAccount, object: nil)
        
        self.initViewModel(startingPoint: 0)
    }
    
    //MARK: Deinit
    deinit{
        NotificationCenter.default.removeObserver(objNotification)
    }
  
  
    //MARK: Refresher
    @objc
    func requestData() {
        print("requesting data")
        self.startPoint = 0
        self.isReload = true
        self.initViewModel(startingPoint: startPoint)
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    
    //MARK: NSNotification

    @objc func switchAccount(notification: NSNotification) {
        self.startPoint = 0
        self.initViewModel(startingPoint: 0)
    }

    //MARK: Button action
    @IBAction func btnBackAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnDoneAction(_ sender: Any) {
        let check = self.select_Indexes.filter({$0["selected_index"] as! Int == 1})
        print("Check ",check.map{$0["user_name"]as! String})
        self.delegate?.listFriends(obj: check)
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: SEARCH BAR
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if self.tfSearch.text?.count == 0 {
            self.initViewModel(startingPoint: 0)
            self.isSearch = false
        }else{
            DispatchQueue.main.async {
                self.friendTableView.showAnimatedGradientSkeleton()

            }
            let user = SearchRequest(userId: UserDefaultsManager.shared.user_id, type: "user", keyword: searchBar.text ?? "" , startingPoint: 0)
            print("user search ", user)
            viewModel1.searchUser(parameters: user)
            self.observeSearchEvent()
            self.isSearch = true
        }
    }
    
    //MARK: KeyBoard Handling
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - TABLE VIEW
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return select_Indexes.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as! UserTableViewCell
        let obj  =  select_Indexes[indexPath.row]
        
        cell.lblFollowers.isHidden = true
        cell.btnFollow.isHidden    = true
        cell.btnFollow1.isHidden   = true
        cell.btnCancel.isHidden    = true
        cell.btnCancel.isHidden    = true
        cell.imgVerified.isHidden  = true
        
        cell.profileImage.isUserInteractionEnabled =  true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.profileView(tap:)))
        cell.profileImage?.tag =  indexPath.row
        cell.profileImage.addGestureRecognizer(tap)
        
        cell.lblName.text = obj["name"] as? String ?? ""
        cell.lblUsername.text = obj["user_name"] as? String ?? ""
        
        if obj["profile_image"] as? String  ?? "" ==  "https://cdn-img.mealme.ai/2c95a5a823fbebaf0b8dcebfaa64e5e4a20151c3/68747470733a2f2f7777772e70616e6461657870726573732e636f6d2f7468656d65732f637573746f6d2f70616e64612f6c6f676f2e706e67" {
            cell.profileImage.image = UIImage(named: "mealMePlaceholder")
        }else{
            cell.profileImage.sd_setImage(with: URL(string: obj["profile_image"] as? String ?? ""), placeholderImage: UIImage(named: "mealMePlaceholder"))
        }
        if self.select_Indexes[indexPath.row]["selected_index"] as! Int == 1{
            cell.accessoryType = .checkmark
            cell.tintColor = UIColor(named: "theme")
        }else{
            cell.accessoryType = .none
        }
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var upd_obj = self.select_Indexes[indexPath.row]
        if  upd_obj["selected_index"] as! Int == 0{
            upd_obj.updateValue(1, forKey: "selected_index")
            self.select_Indexes.remove(at: indexPath.row)
            self.select_Indexes.insert(upd_obj, at: indexPath.row)
        }else{
            upd_obj.updateValue(0, forKey: "selected_index")
            self.select_Indexes.remove(at: indexPath.row)
            self.select_Indexes.insert(upd_obj, at: indexPath.row)
        }
       
        self.friendTableView.reloadData()
    }
    
    
    @objc func profileView(tap:UITapGestureRecognizer){
        print(tap.view?.tag)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myViewController = storyboard.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
        myViewController.hidesBottomBarWhenPushed = true
        myViewController.userResponse =  isSearch ? self.viewModel1.searchStore?.msg?[tap.view!.tag].user : self.showFollowing?.msg?[tap.view!.tag].user
        myViewController.otherUserId = self.select_Indexes[tap.view!.tag]["id"] as? String ?? "0"
        self.navigationController?.pushViewController(myViewController, animated: true)
    }
    
    //MARK: CEll DESIGN
    private func configureFollowingOrFollowersCell(_ cell: UserTableViewCell, at indexPath: IndexPath) {
        let user: HomeUser?
        user = showFollowing?.msg?[indexPath.row].user
        configureCommonCell(cell, with: user)
        cell.btnCancel.isHidden = true
        cell.imgVerified.isHidden = true
        cell.btnFollow.tag = indexPath.row
        cell.btnFollow1.tag = indexPath.row
        
    }


    private func configureCommonCell(_ cell: UserTableViewCell, with user: HomeUser?) {
        
        if let profilePicURLString = user?.profilePic, !profilePicURLString.isEmpty, profilePicURLString != "https://cdn-img.mealme.ai/2c95a5a823fbebaf0b8dcebfaa64e5e4a20151c3/68747470733a2f2f7777772e70616e6461657870726573732e636f6d2f7468656d65732f637573746f6d2f70616e64612f6c6f676f2e706e67" {
            if user?.business == 1 {
                cell.profileImage.sd_setImage(with: URL(string: profilePicURLString), placeholderImage: UIImage(named: "mealMePlaceholder"))
            }else {
                cell.profileImage.sd_setImage(with: URL(string: profilePicURLString), placeholderImage: UIImage(named: "privateOrderPlaceholder"))
            }
           
           
        } else {
            if user?.business == 1 {
                cell.profileImage.image = UIImage(named: "mealMePlaceholder")
            }else {
                cell.profileImage.image = UIImage(named: "privateOrderPlaceholder")
            }
        }
      
        cell.lblName.text = (user?.firstName ?? "") + " " + (user?.lastName ?? "")
        
        if user?.store == nil {
            cell.lblName.isHidden = false
            cell.lblUsername.text = user?.username
        } else {
            cell.lblName.isHidden = true
            cell.lblUsername.text = user?.store?.name
        }
    }
    

    //MARK: SKELETION VIEW
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "UserTableViewCell"
    }
}


//MARK: API Calling
extension TagFriendsViewController {
    
    func initViewModel(startingPoint: Int) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            let following = FriendsRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: startingPoint, otherUserId: "")
            self.viewModel.showFollowing(parameters: following)
            
            DispatchQueue.main.async {
                print("following", following)
                self.observeEvent()
                self.isSearch = false
            }
        }
    }

    func observeEvent() {
        self.friendTableView.isHidden = false
        viewModel.eventHandler = { [weak self] event in
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
                    self.friendTableView.hideSkeleton()
                }

            case .newShowSuggestedUsers(showSuggestedUsers: let showSuggestedUsers):
                    print("newShowSuggestedUsers")
            case .newShowFollowing(showFollowing: let showFollowing):
                print("showFollowing")
                if showFollowing.code == 201 {
                    if startPoint == 0 {
                        DispatchQueue.main.async {
                            self.friendTableView.hideSkeleton()
                            self.friendTableView.isHidden = true
                            self.lblNoData.isHidden = false
                            self.lblNoData.text = "You don’t have any following users yet"
                        }
                    }else {
                        self.isNextPageLoad = false
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
                        viewModel.showFollowing?.msg?.removeAll()
                        self.showFollowing?.msg?.removeAll()
                        viewModel.showFollowing = showFollowing
                        self.showFollowing = showFollowing
                    }else {
                        
                        if let newMessages = showFollowing.msg {
                            viewModel.showFollowing?.msg?.append(contentsOf: newMessages)
                            self.showFollowing?.msg?.append(contentsOf: newMessages)
                        }
                    }
                    
                    
                    //FOR LOGIC
                    self.select_Indexes.removeAll()
                    if let msg = self.showFollowing?.msg{
                        for var i in 0..<msg.count{
                            var obj:[String:Any] = ["selected_index": 0,"name": "\(msg[i].user?.firstName ?? "") \(msg[i].user?.lastName ?? "" )" ,"user_name":msg[i].user?.username ?? "","profile_image":msg[i].user?.profilePic ?? "","id": "\(msg[i].user?.id ?? 0)"]
                            self.select_Indexes.append(obj)
                        }
                    }
                    
                    
                    DispatchQueue.main.async {
                        if (self.showFollowing?.msg?.count ?? 0) >= 10 {
                            self.isNextPageLoad = true
                        }else {
                            self.isNextPageLoad = false
                        }
                        self.friendTableView.hideSkeleton()
                        self.friendTableView.reloadData()
                    }
                }
            case .newShowFollowers(showFollowers: let showFollowers):
                print("showFollowers")
            }
        }
    }
    
    func observeSearchEvent() {
        viewModel1.eventHandler = { [weak self] event in
            guard let self else { return }
            
            switch event {
            case .error(let error):
                print("error",error ?? "")
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
                
            case .newSearchVideo(searchVideo: let searchVideo):
                print("searchVideo")
                
            case .newSearchUser(searchUser: let searchUser):
                print("searchUser")
                if searchUser.code == 200 {
                    if startPoint == 0 {
                        viewModel1.searchUser?.msg?.removeAll()
                        viewModel1.searchUser = searchUser
                        
                    } else {
                        if let newMessages = searchUser.msg {
                            viewModel1.searchUser?.msg?.append(contentsOf: newMessages)
                        }
                    }
                    
                    //FOR LOGIC
                    self.select_Indexes.removeAll()
                    if let msg = viewModel1.searchUser?.msg{
                        for var i in 0..<msg.count{
                            var obj:[String:Any] = ["selected_index": 0,"name": "\(msg[i].user.firstName ?? "") \(msg[i].user.lastName ?? "" )" ,"user_name":msg[i].user.username ?? "","profile_image":msg[i].user.profilePic ?? "","id": "\(msg[i].user.id ?? 0)"]
                            self.select_Indexes.append(obj)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.friendTableView.hideSkeleton()
                        self.friendTableView.reloadData()
                    }
                }else {
                    if startPoint == 0 {
                        self.friendTableView.hideSkeleton()
                        viewModel1.searchUser?.msg?.removeAll()
                    }else {
                        DispatchQueue.main.async {
                            self.friendTableView.hideSkeleton()
                            self.isNextPageLoad = false
                        }
                    }
                    return
                }
            
            case .newSearchSound(searchSound: let searchSound):
                print("searchSound",searchSound)
    
            case .newSearchHashtag(searchHashtag: let searchHashtag):
                print("searchHashtag",searchHashtag)
            
            }
        }
    }
}

//MARK: PAGINATION
extension TagFriendsViewController {
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
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
        if scrollView == self.friendTableView{
            if ((friendTableView.contentOffset.y + friendTableView.frame.size.height) >= friendTableView.contentSize.height)
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
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height {
            if isNextPageLoad == true {
                self.spinner.hidesWhenStopped = true
                self.spinner.stopAnimating()
            }
        }
    }
}
