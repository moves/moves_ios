//
//  SearchUserViewController.swift
// //
//
//  Created by Wasiq Tayyab on 19/05/2024.
//

import UIKit
import SDWebImage
import AVFAudio
import SkeletonView
import ZoomingTransition
class SearchUserViewController: ZoomingPushVC, UISearchBarDelegate {
    
    //MARK: - VARS
    var lastSelectedIndexPath: IndexPath? = nil
    fileprivate var menuTitles = [["menu":"Users","isSelected":"false"],["menu":"Videos","isSelected":"false"], ["menu":"Sounds","isSelected":"false"],["menu":"Hashtags","isSelected":"false"]]
    fileprivate var selectedMenu = "Shops"
    private var viewModel = SearchViewModel()
    private var keyword = ""
    private var startPoint = 0
    private var viewModel1 = NotificaitonViewModel()
    let spinner = UIActivityIndicatorView(style: .white)
    var isDataLoading:Bool = false
    private let footerView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    var isNextPageLoad = false
    var player: AVAudioPlayer?
    var isPlaying = false
    var isSoundLoading: Bool = false
    var currentPlayingCell: SoundsTableViewCell?
    var currentPlayingIndex: Int? = nil
    
   
    //MARK: - OUTLET
    @IBOutlet weak var menuCollectionView: UICollectionView!
    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var videoCollectionView: UICollectionView!
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.showAnimatedGradientSkeleton()
        self.setup()
        self.searchBar.becomeFirstResponder()
        let toolBar = ConstantManager.shared.getKeyboardToolbar()
        self.searchBar.inputAccessoryView = toolBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.stopSound()
    }
    
    
    //MARK: - FUNCTION
    private func setup(){
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self
        menuCollectionView.register(UINib(nibName: "SearchCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SearchCollectionViewCell")
        
        videoCollectionView.delegate = self
        videoCollectionView.dataSource = self
        videoCollectionView.register(UINib(nibName: "VideoProfileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VideoProfileCollectionViewCell")
        videoCollectionView.register(CollectionViewFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
    
        (videoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: videoCollectionView.bounds.width, height: 50)
        footerView.color = UIColor(named: "theme")
        footerView.hidesWhenStopped = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserTableViewCell")
        tableView.register(UINib(nibName: "SoundsTableViewCell", bundle: nil), forCellReuseIdentifier: "SoundsTableViewCell")
        tableView.register(UINib(nibName: "PlacesTableViewCell", bundle: nil), forCellReuseIdentifier: "PlacesTableViewCell")
        tableView.register(UINib(nibName: "HashtagsTableViewCell", bundle: nil), forCellReuseIdentifier: "HashtagsTableViewCell")
        tableView.rowHeight = 70
        spinner.color = UIColor(named: "theme")
        spinner.hidesWhenStopped = true
        
        tableView.tableFooterView = spinner
        searchBar.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            selectedMenu = "Users"
            self.viewModel.searchUser?.msg?.removeAll()
            self.viewModel.searchStore?.msg?.removeAll()
            self.viewModel.searchSound?.msg?.removeAll()
            self.viewModel.searchVideo?.msg?.removeAll()
            self.viewModel.searchHashtag?.msg?.removeAll()
            self.footerView.hidesWhenStopped = true
            self.spinner.hidesWhenStopped = true
            self.tableView.reloadData()
            self.videoCollectionView.reloadData()
            self.lblNoData.isHidden = true
            self.tableView.isHidden = true
            self.menuCollectionView.isHidden = true
            self.videoCollectionView.isHidden = true
            self.lineView.isHidden = true
            tableView.rowHeight = 70
        }
    }

    @objc func StoreSelectedIndex(index: Int) {
        print("Selected index:", index)
    
        self.startPoint = 0
        
        switch index {
        case 0:
            tableView.rowHeight = 70
            self.stopSound()
            self.selectedMenu = "Users"
            if viewModel.searchUser?.code == 200 {
                if (viewModel.searchUser?.msg?.count ?? 0) >= 10 {
                    self.isNextPageLoad = true
                }else {
                    self.isNextPageLoad = false
                    self.footerView.hidesWhenStopped = true
                    self.spinner.hidesWhenStopped = true
                }
                self.lblNoData.isHidden = true
                self.tableView.isHidden = false
                self.videoCollectionView.isHidden = true
                self.tableView.reloadData()
            }else {
                self.videoCollectionView.isHidden = true
                self.tableView.isHidden = true
                self.lblNoData.isHidden = false
                self.lblNoData.text = "There is no user yet."
            }
        case 1:
            self.stopSound()
            self.selectedMenu = "Videos"
            if viewModel.searchVideo?.code == 200 {
                if (viewModel.searchVideo?.msg?.count ?? 0) >= 10 {
                    self.isNextPageLoad = true
                }else {
                    self.isNextPageLoad = false
                    self.footerView.hidesWhenStopped = true
                    self.spinner.hidesWhenStopped = true
                }
                self.lblNoData.isHidden = true
                self.tableView.isHidden = true
                self.videoCollectionView.isHidden = false
                self.videoCollectionView.reloadData()
            }else {
                self.tableView.isHidden = true
                self.videoCollectionView.isHidden = true
                self.lblNoData.isHidden = false
                self.lblNoData.text = "There is no video yet."
            }
        case 2:
            self.stopSound()
            self.tableView.rowHeight = 70
            self.selectedMenu = "Sounds"
            if viewModel.searchSound?.code == 200 {
                if (viewModel.searchSound?.msg?.count ?? 0) >= 10 {
                    self.isNextPageLoad = true
                }else {
                    self.isNextPageLoad = false
                    self.footerView.hidesWhenStopped = true
                    self.spinner.hidesWhenStopped = true
                }
                self.lblNoData.isHidden = true
                self.tableView.isHidden = false
                self.videoCollectionView.isHidden = true
                self.tableView.reloadData()
            }else {
                self.videoCollectionView.isHidden = true
                self.tableView.isHidden = true
                self.lblNoData.isHidden = false
                self.lblNoData.text = "There is no sound yet."
            }
        default:
            self.tableView.rowHeight = 50
            self.stopSound()
            self.selectedMenu = "Hashtags"
            if viewModel.searchHashtag?.code == 200 {
                if (viewModel.searchHashtag?.msg?.count ?? 0) >= 10 {
                    self.isNextPageLoad = true
                }else {
                    self.isNextPageLoad = false
                    self.footerView.hidesWhenStopped = true
                    self.spinner.hidesWhenStopped = true
                }
                self.lblNoData.isHidden = true
                self.tableView.isHidden = false
                self.videoCollectionView.isHidden = true
                self.tableView.reloadData()
            }else {
                self.videoCollectionView.isHidden = true
                self.tableView.isHidden = true
                self.lblNoData.isHidden = false
                self.lblNoData.text = "There is no hashtag yet."
            }
          
        }

        self.menuCollectionView.reloadData()
    }

    //MARK: - BUTTON ACTION
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            self.menuCollectionView.isUserInteractionEnabled = false
            self.tableView.showAnimatedGradientSkeleton()
            self.lblNoData.isHidden = true
            view.endEditing(true)
            keyword = searchBar.text!
            startPoint = 0
            self.initViewModel(keyword: keyword, startingPoint: startPoint)
            
            for i in 0..<self.menuTitles.count {
                self.menuTitles[i].updateValue("false", forKey: "isSelected")
            }
            self.menuTitles[0].updateValue("true", forKey: "isSelected")
            self.menuCollectionView.reloadData()
           
            self.tableView.isHidden = false
            self.menuCollectionView.isHidden = false
            self.lineView.isHidden = false
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func playButtonPressed(_ sender: UIButton) {
        let newIndex = sender.tag
        let indexPath = IndexPath(item: newIndex, section: 0)
        
        guard let cell = tableView.cellForRow(at: indexPath) as? SoundsTableViewCell else {
            return
        }
        
        let soundURL = viewModel.searchSound?.msg?[newIndex].sound
        
        if sender.currentImage == UIImage(systemName: "play.fill") {
            stopSound()
            downloadAndPlaySound(from: soundURL?.audio ?? "", in: cell) { success in
                if success {
                    DispatchQueue.main.async {
                        cell.btnPlay.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                        self.currentPlayingIndex = newIndex
                        self.currentPlayingCell = cell
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.btnPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
                    }
                }
            }
        } else {
            stopSound()
            cell.btnPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }

    func downloadAndPlaySound(from urlString: String, in cell: SoundsTableViewCell, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: urlString) else { return }
        
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent(url.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: tempFile.path) {
            // If file already exists, play it
            playSound(from: tempFile)
            completion(true)
            return
        }
        
        // Show activity view while downloading
        cell.activityView.isHidden = false
        cell.activityView.startAnimating()
        
        let downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] (location, response, error) in
            guard let self = self else { return }
            guard let location = location, error == nil else {
                DispatchQueue.main.async {
                    cell.activityView.isHidden = true
                    completion(false)
                }
                return
            }
            
            do {
                // Move downloaded file to temp directory
                try FileManager.default.moveItem(at: location, to: tempFile)
                DispatchQueue.main.async {
                    cell.activityView.isHidden = true
                    // Play the downloaded sound
                    self.playSound(from: tempFile)
                    completion(true)
                }
            } catch {
                print("File error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    cell.activityView.isHidden = true
                    completion(false)
                }
            }
        }
        
        downloadTask.resume()
    }

    func playSound(from url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()
        } catch let error {
            print("Audio player error: \(error.localizedDescription)")
        }
    }

    func stopSound() {
        player?.stop()
        
        // Reset UI for the previously playing cell if any
        if let index = currentPlayingIndex, let cell = tableView.cellForRow(at: IndexPath(item: index, section: 0)) as? SoundsTableViewCell {
            cell.btnPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
        
        currentPlayingIndex = nil
        currentPlayingCell = nil
    }

}

//MARK: - COLLECTION VIEW
extension SearchUserViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == videoCollectionView {
            return viewModel.searchVideo?.msg?.count ?? 0
        }else {
            return menuTitles.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == videoCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoProfileCollectionViewCell", for: indexPath)as! VideoProfileCollectionViewCell
            let video = viewModel.searchVideo?.msg?[indexPath.row].video
            
            cell.videoView.sd_setImage(with: URL(string: video?.thum ?? ""), placeholderImage: UIImage(named: ""), options: .continueInBackground, completed: { [weak cell] image, _, _, _ in
                guard let cell = cell, let image = image else { return }
                UIView.transition(with: cell.videoView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    cell.videoView.image = image
                }, completion: nil)
            })
            cell.lblView.text = video?.view?.toString()
            handlePagination(for: "Videos", at: indexPath)
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCollectionViewCell", for: indexPath)as! SearchCollectionViewCell
            cell.lblMenu.text = menuTitles[indexPath.row]["menu"] ?? ""
            if menuTitles[indexPath.row]["isSelected"] == "true" {
                cell.lineView.isHidden = false
                cell.lblMenu.textColor = UIColor.appColor(.black)
                selectedMenu = menuTitles[indexPath.row]["menu"] ?? ""
            }else {
                cell.lineView.isHidden = true
                cell.lblMenu.textColor = UIColor.appColor(.darkGrey)
            }
           
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == videoCollectionView {
            return CGSize(width: collectionView.frame.width / 3 - 1, height: 230)
        }else {
            return CGSize(width: Int(collectionView.frame.width) / 5, height: 40)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == videoCollectionView {
            if kind == UICollectionView.elementKindSectionFooter {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath) as! CollectionViewFooterView
                footer.addSubview(footerView)
                footerView.frame = footer.bounds
                return footer
            }
            return UICollectionReusableView()
        }else {
            return UICollectionReusableView()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == videoCollectionView {
            self.lastSelectedIndexPath = indexPath
            let videoDetail = VideoDetailController()
            videoDetail.dataSource = viewModel.searchVideo?.msg ?? []
            videoDetail.index = indexPath.row
            videoDetail.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(videoDetail, animated: true)
        
        }else {
            for i in 0..<self.menuTitles.count {
                self.menuTitles[i].updateValue("false", forKey: "isSelected")
            }
            self.menuTitles[indexPath.row].updateValue("true", forKey: "isSelected")
         
            self.StoreSelectedIndex(index: indexPath.row)
            self.menuCollectionView.reloadData()
            
            
            if viewModel.searchSound?.msg?.count ?? 0 < 10 {
                self.footerView.hidesWhenStopped = true
                self.spinner.hidesWhenStopped = true
                self.isNextPageLoad = false
            }
        }
    }
    
}

//MARK: - COLLECTION VIEW
extension SearchUserViewController: SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedMenu == "Sounds" {
            return viewModel.searchSound?.msg?.count ?? 0
        }else if selectedMenu == "Users" {
            return viewModel.searchUser?.msg?.count ?? 0
        }else if selectedMenu == "Hashtags"{
            return viewModel.searchHashtag?.msg?.count ?? 0
        }else {
            return viewModel.searchStore?.msg?.count ?? 0
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "UserTableViewCell"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedMenu == "Sounds" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SoundsTableViewCell", for: indexPath)as! SoundsTableViewCell
            let sound =  viewModel.searchSound?.msg?[indexPath.row].sound
            cell.soundImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.soundImage.sd_setImage(with: URL(string:(sound?.thum ?? "")), placeholderImage: UIImage(named: "videoPlaceholder"))
            cell.lblSoundName.text = sound?.name
            cell.lblName.text = sound?.description
            cell.lblInformation.text = sound?.duration
            
            cell.btnPlay.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
            cell.btnPlay.tag = indexPath.row
            
            handlePagination(for: "Sounds", at: indexPath)
            
            return cell
        }else if selectedMenu == "Users" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath)as! UserTableViewCell
            let user =  viewModel.searchUser?.msg?[indexPath.row].user
            cell.profileImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.profileImage.sd_setImage(with: URL(string:(user?.profilePic ?? "")), placeholderImage: UIImage(named: "videoPlaceholder"))
            cell.lblName.text = (user?.firstName ?? "") + " " + (user?.lastName ?? "")
            cell.lblUsername.text = user?.username
           
            cell.imgVerified.isHidden = true
            
            if user?.button == "following" || user?.button == "Following" {
                cell.btnFollow.backgroundColor = UIColor.appColor(.buttonColor)
                cell.btnFollow.setTitleColor(UIColor.appColor(.black), for: .normal)
                cell.btnFollow.setTitle(user?.button?.capitalized, for: .normal)
            }else if user?.button == "follow back" {
                cell.btnFollow.backgroundColor = UIColor.appColor(.theme)
                cell.btnFollow.setTitleColor(UIColor.appColor(.white), for: .normal)
                cell.btnFollow.setTitle(user?.button?.capitalized, for: .normal)
            }else if user?.button == "Friends"{
                cell.btnFollow.backgroundColor = UIColor.appColor(.buttonColor)
                cell.btnFollow.setTitleColor(UIColor.appColor(.black), for: .normal)
                cell.btnFollow.setTitle(user?.button?.capitalized, for: .normal)
            }else {
                cell.btnFollow.backgroundColor = UIColor.appColor(.theme)
                cell.btnFollow.setTitleColor(UIColor.appColor(.white), for: .normal)
                cell.btnFollow.setTitle(user?.button?.capitalized, for: .normal)
            }
            let followersCount = user?.followersCount ?? 0
            let videoCount = user?.videoCount ?? 0
            cell.lblFollowers.text = "\(followersCount) followers • \(videoCount) videos"
            cell.btnFollow.tag = indexPath.row
            cell.btnFollow.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
            cell.btnFollow1.tag = indexPath.row
            cell.btnFollow1.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
            handlePagination(for: "Users", at: indexPath)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HashtagsTableViewCell", for: indexPath)as! HashtagsTableViewCell
            let hashtag = viewModel.searchHashtag?.msg?[indexPath.row].hashtag
            cell.lblHashtag.text = hashtag?.name
            cell.lblPost.text = (hashtag?.views ?? "0") + " posts"
            handlePagination(for: "Hashtags", at: indexPath)
            return cell
        }
    }
    
    func handlePagination(for category: String, at indexPath: IndexPath) {
        guard isNextPageLoad && !isDataLoading else { return }
        
        var shouldLoadMore = false
        var request: Any?
        
        let keyword = self.keyword
        
        switch category {
        case "Sounds":
            if indexPath.row == (viewModel.searchSound?.msg?.count ?? 0) - 1 {
                shouldLoadMore = true
                startPoint += 1
                request = SearchRequest(userId: UserDefaultsManager.shared.user_id, type: "sound", keyword: keyword, startingPoint: startPoint)
            }
        case "Users":
            if indexPath.row == (viewModel.searchUser?.msg?.count ?? 0) - 1 {
                shouldLoadMore = true
                startPoint += 1
                request = SearchRequest(userId: UserDefaultsManager.shared.user_id, type: "user", keyword: keyword, startingPoint: startPoint)
            }
        case "Hashtags":
            if indexPath.row == (viewModel.searchHashtag?.msg?.count ?? 0) - 1 {
                shouldLoadMore = true
                startPoint += 1
                request = SearchRequest(userId: UserDefaultsManager.shared.user_id, type: "hashtag", keyword: keyword, startingPoint: startPoint)
            }
        case "Videos":
            if indexPath.row == (viewModel.searchVideo?.msg?.count ?? 0) - 1 {
                shouldLoadMore = true
                startPoint += 1
                request = SearchRequest(userId: UserDefaultsManager.shared.user_id, type: "video", keyword: keyword, startingPoint: startPoint)
            }
        default:
            break
        }
        
        if shouldLoadMore, let request = request {
            isDataLoading = true
            footerView.startAnimating()
            spinner.startAnimating()
            print("request",request)
            switch category {
            case "Sounds":
                viewModel.searchSound(parameters: request as! SearchRequest)
            case "Users":
                viewModel.searchUser(parameters: request as! SearchRequest)
            case "Hashtags":
                viewModel.searchHashtag(parameters: request as! SearchRequest)
            case "Videos":
                viewModel.searchVideo(parameters: request as! SearchRequest)
            default:
                break
            }
        }
    }

    
    @objc func buttonClicked(sender: UIButton) {
        let cell = tableView.cellForRow(at: IndexPath(item: sender.tag, section: 0))as! UserTableViewCell
        var butt = ""
        let receiver =  viewModel.searchStore?.msg?[sender.tag].user?.id
        if receiver == nil || receiver == 0 {
             Utility.showMessage(message: "Something went wrong. Please try later", on: self.view)
            return
        }
        
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
     
        viewModel.searchStore?.msg?[sender.tag].user?.button = butt
        
        let followUser = FollowUserRequest(senderId: UserDefaultsManager.shared.user_id.toInt() ?? 0, receiverId: receiver ?? 0)
        viewModel1.followUser(parameters: followUser)
        print("followUserRequest",followUser)
        self.observeEvent1()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedMenu == "Sounds" {
            let sound = viewModel.searchSound?.msg?[indexPath.row].sound
            print("sound",sound)
            let vc = SoundDetailViewController(nibName: "SoundDetailViewController", bundle: nil)
            vc.soundUrl = sound?.audio ?? ""
            vc.soundName = sound?.name ?? ""
            vc.createdBy = sound?.description ?? ""
            vc.thum = sound?.thum ?? ""
            vc.sound_section_id = sound?.id ?? 0
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if selectedMenu == "Users" {
            let user = viewModel.searchUser?.msg?[indexPath.row].user
            
            if user?.id == nil || user?.id == 0 {
                 Utility.showMessage(message: "Something went wrong. Please try later", on: self.view)
                return
            }
            
            if user?.id?.toString() ?? "" == UserDefaultsManager.shared.user_id {
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
                viewModel.searchUser?.msg?[indexPath.row].user.button = user.button
                tableView.reloadData()
            }
            
            myViewController.userResponse = user
            myViewController.hidesBottomBarWhenPushed = true
            myViewController.otherUserId = user?.id?.toString() ?? ""
            self.navigationController?.pushViewController(myViewController, animated: true)
        }else if selectedMenu == "Hashtags" {
            let hashtag = viewModel.searchHashtag?.msg?[indexPath.row].hashtag
            let vc = HashtagViewController(nibName: "HashtagViewController", bundle: nil)
            vc.hashtag = hashtag?.name ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            let user = viewModel.searchStore?.msg?[indexPath.row].user
            
            if user?.id == nil || user?.id == 0 {
                 Utility.showMessage(message: "Something went wrong. Please try later", on: self.view)
                return
            }
            
            if user?.id?.toString() ?? "" == UserDefaultsManager.shared.user_id {
                let story = UIStoryboard(name: "Main", bundle: nil)
                if let tabBarController = story.instantiateViewController(withIdentifier: "TabbarViewController") as? UITabBarController {
                    tabBarController.selectedIndex = 4
                    let nav = UINavigationController(rootViewController: tabBarController)
                    nav.navigationBar.isHidden = true
                    self.view.window?.rootViewController = nav
                }
            }
            
            
//            let vc = BusinessProfileViewController(nibName: "BusinessProfileViewController", bundle: nil)
//            vc.hidesBottomBarWhenPushed = true
//            
//            vc.callback = { (user) -> Void in
//                self.viewModel.searchStore?.msg?[indexPath.row].user = user
//                tableView.reloadData()
//            }
//
//            vc.currentIndexPath = indexPath
//            vc.user = viewModel.searchStore?.msg?[indexPath.row].user
//            vc.store = viewModel.searchStore?.msg?[indexPath.row].store
//            vc.storeAddress = viewModel.searchStore?.msg?[indexPath.row].store?.storeAddress
//            vc.storeLocalHours = viewModel.searchStore?.msg?[indexPath.row].store?.storeLocalHours
//            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension SearchUserViewController {
   
    func initViewModel(keyword: String, startingPoint: Int) {
        let dispatchGroup = DispatchGroup()
        
        let userId = UserDefaultsManager.shared.user_id
    
        let user = SearchRequest(userId: userId, type: "user", keyword: keyword, startingPoint: startingPoint)
        dispatchGroup.enter()
        viewModel.searchUser(parameters: user)
        dispatchGroup.leave()

        let videos = SearchRequest(userId: userId, type: "video", keyword: keyword, startingPoint: startingPoint)
        dispatchGroup.enter()
        viewModel.searchVideo(parameters: videos)
        dispatchGroup.leave()

        let sound = SearchRequest(userId: userId, type: "sound", keyword: keyword, startingPoint: startingPoint)
        dispatchGroup.enter()
        viewModel.searchSound(parameters: sound)
        dispatchGroup.leave()

        let hashtag = SearchRequest(userId: userId, type: "hashtag", keyword: keyword, startingPoint: startingPoint)
        dispatchGroup.enter()
        viewModel.searchHashtag(parameters: hashtag)
        dispatchGroup.leave()

        dispatchGroup.notify(queue: .main) {
            self.observeEvent()
        }
    }

    func observeEvent() {
        viewModel.eventHandler = { [weak self] event in
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
                if searchVideo.code == 200 {
                    if startPoint == 0 {
                        viewModel.searchVideo?.msg?.removeAll()
                        viewModel.searchVideo = searchVideo
                    } else {
                        if let newMessages = searchVideo.msg {
                            viewModel.searchVideo?.msg?.append(contentsOf: newMessages)
                        }
                        DispatchQueue.main.async {
                            self.videoCollectionView.reloadData()
                        }
                    }
                   
                    
                }else {
                    if startPoint == 0 {
                        viewModel.searchVideo?.msg?.removeAll()
                    }else {
                        DispatchQueue.main.async {
                            self.isNextPageLoad = false
                        }
                    }
                    return
                }
                
            case .newSearchUser(searchUser: let searchUser):
                if searchUser.code == 200 {
                    if startPoint == 0 {
                        viewModel.searchUser?.msg?.removeAll()
                        viewModel.searchUser = searchUser
                        
                    } else {
                        if let newMessages = searchUser.msg {
                            viewModel.searchUser?.msg?.append(contentsOf: newMessages)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        if (self.viewModel.searchUser?.msg?.count ?? 0) >= 10 {
                            self.isNextPageLoad = true
                        }else {
                            self.footerView.hidesWhenStopped = true
                            self.spinner.hidesWhenStopped = true
                            self.isNextPageLoad = false
                        }
                      
                        self.tableView.hideSkeleton()
                        self.menuCollectionView.isUserInteractionEnabled = true
                        self.tableView.reloadData()
                    }
                  
                }else {
                    if startPoint == 0 {
                        viewModel.searchUser?.msg?.removeAll()
                        DispatchQueue.main.async {
                            self.tableView.isHidden = true
                            self.lblNoData.isHidden = false
                            self.lblNoData.text = "There is no user yet."
                            self.tableView.hideSkeleton()
                            self.menuCollectionView.isUserInteractionEnabled = true
                        }
                    }else {
                        DispatchQueue.main.async {
                            self.isNextPageLoad = false
                        }
                    }
                    return
                    
                }
            
            case .newSearchSound(searchSound: let searchSound):
                print("searchSound",searchSound)
                if searchSound.code == 200 {
                    if startPoint == 0 {
                        viewModel.searchSound?.msg?.removeAll()
                        viewModel.searchSound = searchSound
                    } else {
                        if let newMessages = searchSound.msg {
                            viewModel.searchSound?.msg?.append(contentsOf: newMessages)
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                       
                    }
                    
                }else {
                    if startPoint == 0 {
                        viewModel.searchSound?.msg?.removeAll()
                    }else {
                        DispatchQueue.main.async {
                            self.isNextPageLoad = false
                        }
                    }
                    return
                }
            case .newSearchHashtag(searchHashtag: let searchHashtag):
                print("searchHashtag",searchHashtag)
                if searchHashtag.code == 200 {
                    if startPoint == 0 {
                        viewModel.searchHashtag?.msg?.removeAll()
                        viewModel.searchHashtag = searchHashtag
                    } else {
                        if let newMessages = searchHashtag.msg {
                            viewModel.searchHashtag?.msg?.append(contentsOf: newMessages)
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    
                }else {
                    if startPoint == 0 {
                        viewModel.searchHashtag?.msg?.removeAll()
                    }else {
                        DispatchQueue.main.async {
                            self.isNextPageLoad = false
                        }
                    }
                    return
                }
            }
        }
    }
    
    func observeEvent1() {
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
            case .newShowAllNotifications(showAllNotifications: _):
                print("showAllNotifications")
            case .newFollowUser(followUser: let followUser):
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .switchAccount, object: nil)
                }
                print("followUser")
            case .newReadNotification(readNotification: let readNotification):
                print("followUser")
            }
        }
    }
}


extension SearchUserViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopSound()
    }
}

extension SearchUserViewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging")
        if isNextPageLoad {
            self.footerView.stopAnimating()
            self.spinner.stopAnimating()
            isDataLoading = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        if isNextPageLoad {
            self.footerView.stopAnimating()
            self.spinner.stopAnimating()
        }else {
            self.footerView.hidesWhenStopped = true
            self.spinner.hidesWhenStopped = true
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
    }
}

extension SearchUserViewController: ZoomTransitionAnimatorDelegate {
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
