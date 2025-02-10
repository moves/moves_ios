//
//  HomeVideoViewController.swift
//  Moves
//
//  Created by Wasiq Tayyab on 17/10/2024.
//

import UIKit
import ZFPlayer
import CoreLocation

enum HomeVideoCategory: String, CaseIterable {
    case nearby = "Nearby"
    case following = "Following"
    case forYou = "For You"
}

struct CategoryItem {
    let category: HomeVideoCategory
    var isSelected: Bool
}

class HomeVideoViewController: UIViewController {

    //MARK: - VARS
    var locManager = CLLocationManager()
    var currentLocation: CLLocation?
    var isLoadingMore = false
    var popbackBlock: (() -> Void)? // 返回时的闭包
    lazy var controlView:LZFControlView = {
        let controlView = LZFControlView()
        return controlView
    }()
    var preControlView: ZFPlayerControlView?
    var isInited: Bool = false
    var player: LPlayerController? {
        didSet {
            preControlView = player?.controlView as? ZFPlayerControlView
            preControlView?.removeFromSuperview()
        }
    }
    
    var selectedCategory = 2
    var categoryCell = "HomeVideoCollectionViewCell"
    var categoryArr: [CategoryItem] = [
        CategoryItem(category: .nearby, isSelected: false),
        CategoryItem(category: .following, isSelected: false),
        CategoryItem(category: .forYou, isSelected: true)
    ]
    let homeViewModel = HomeViewModel()
    var playingIndexPath: IndexPath?
    var startPointForYou = 0
    var startPointFollowing = 0
    var startPointNearby = 0
    var index: Int = 0 // 当前索引
    var repostIndex = 0
    var loadMoreData: (() -> Void)?
    var viewModel = ReasonViewModel()
    private lazy var loader: UIView = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            fatalError("Unable to access key window")
        }
        return Utility.shared.createActivityIndicator(keyWindow)
    }()

    var dataSource: [HomeResponseMsg] = []
    var following: [HomeResponseMsg] = []
    var nearby: [HomeResponseMsg] = []
    var forYou: [HomeResponseMsg] = []
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.isPagingEnabled = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.scrollsToTop = false
        
        tableView.register(LVideoPlayerCell.classForCoder(), forCellReuseIdentifier: String(describing: LVideoPlayerCell.self))
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.frame = CGRect(x: 0, y: 0, width: UIDevice.ex.screenWidth, height: UIDevice.ex.screenHeight - UIDevice.ex.tabBarHeight)
        tableView.rowHeight = tableView.frame.size.height
        return tableView
    }()
    
    var refreshControl: UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.appColor(.theme) // Set your custom theme color
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        return refreshControl
    }
    
    @objc func requestData() {
        // Fetch Weather Data
        print("Requesting data")
        self.apiCall()
        self.refreshControl.endRefreshing()
    }
    
    
    //MARK: - OUTLET
    @IBOutlet weak var lblNoContent: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var homeVideoCategoryCollectionView: UICollectionView!
    
    
    //MARK: - View DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.checkLocationAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .lightContent
        
        tabBarController?.tabBar.isTranslucent = false
        
        tableView.refreshControl = refreshControl
        

        // animate the tab bar color
        // attempting to animate .tintBarColor doesn't work - it just changes immediately
        self.tabBarController?.tabBar.barTintColor = .clear
        if let tab = self.tabBarController?.tabBar {
            UIView.transition(with: tab, duration: 0.2) {
                tab.backgroundColor = .black
                tab.tintColor = .white
            }
        }
        tabBarController?.tabBar.unselectedItemTintColor = .white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let tab = self.tabBarController?.tabBar {
            UIView.transition(with: tab, duration: 0.2) {
                tab.backgroundColor = .white
                tab.tintColor = .black
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let isPlaying =  player?.currentPlayerManager.isPlaying, isPlaying {
            self.controlView.playButtonAction()
            player?.currentPlayerManager.pause()
        }
    }
    
    //MARK: - FUNCTION
    func checkLocationAuthorization() {
        locManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            requestLocation()
        case .notDetermined:
            locManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            
            let vc = LocationSettingViewController(nibName: "LocationSettingViewController", bundle: nil)
            vc.modalPresentationStyle = .overFullScreen
            self.navigationController?.present(vc, animated: false)
            // Handle denied/restricted case
            print("Location access denied or restricted.")
        @unknown default:
            break
        }
    }
    
    func requestLocation() {
        locManager.startUpdatingLocation()
    }
    
    private func setup() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleHomeScreenNotification), name: .stopVideo, object: nil)

        view.addSubview(tableView)
        view.addSubview(homeVideoCategoryCollectionView)
        view.addSubview(stackView)
        
        tableView.bringSubviewToFront(homeVideoCategoryCollectionView)
        tableView.bringSubviewToFront(stackView)
        homeVideoCategoryCollectionView.register(UINib(nibName: categoryCell, bundle: nil), forCellWithReuseIdentifier: categoryCell)
        homeVideoCategoryCollectionView.delegate = self
        homeVideoCategoryCollectionView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleMoveToNextVideo), name: .moveToNextVideo, object: nil)
        self.apiCall()
    }
    
    func apiCall() {
        let forYou = HomeRequest(userId: UserDefaultsManager.shared.user_id, deviceId: UserDefaultsManager.shared.deviceID, tagProduct: 0, startingPoint: 0, deliveryAddressId: 0, lat: UserDefaultsManager.shared.latitude, long: UserDefaultsManager.shared.longitude)
        let showFollowing = ShowFollowingVideosRequest(userId: UserDefaultsManager.shared.user_id, deviceId: UserDefaultsManager.shared.deviceID, startingPoint: 0)
        let showNearby = ShowNearbyVideosRequest(userId: UserDefaultsManager.shared.user_id, deviceId: UserDefaultsManager.shared.deviceID, lat: UserDefaultsManager.shared.latitude, long: UserDefaultsManager.shared.longitude, startingPoint: 0)

        Task {
            async let relatedVideos = self.homeViewModel.showRelatedVideos(parameters: forYou)
            async let followingVideos = self.homeViewModel.showFollowingVideos(parameters: showFollowing)
            async let nearbyVideos = self.homeViewModel.showNearbyVideos(parameters: showNearby)

            // Await the tasks individually without using a tuple
            await relatedVideos
            await followingVideos
            await nearbyVideos
            
            self.homeObserveEvent()
        }
    }

    
    @objc func handleHomeScreenNotification() {
        print("Received notification in Tab Bar")
        if let isPlaying = player?.currentPlayerManager.isPlaying, isPlaying {
            player?.currentPlayerManager.pause()
            self.controlView.playButtonAction()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .stopVideo, object: nil)
    }
  
    func setupPlayer() {
        DispatchQueue.main.async {
            if self.player == nil {
                print("Creating a new player")
                self.player = LPlayerController.player(with: UIView())
                self.player?.playableArray = self.dataSource
                
                self.initializePlayerIfNeeded()
            } else {
                print("Player already exists, re-attaching player view")
                self.player?.currentPlayerManager.view.removeFromSuperview()
                if let containerView = self.player?.currentPlayerManager.view {
                    self.view.addSubview(containerView)
                }
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    guard let self = self else { return }
                    let initialIndexPath = IndexPath(row: 0, section: 0)
                    self.playTheVideoAtIndexPath(indexPath: initialIndexPath, scrollToTop: false)
                    
                    self.player?.controlView = self.controlView
                    if let isPlaying = self.player?.currentPlayerManager.isPlaying, !isPlaying {
                       
                        self.player?.currentPlayerManager.play()
                    } else {
                        print("Player is already playing")
                    }
                }
            }

            self.player?.presentationSizeChanged = { [weak self] asset, size in
                guard let self = self else { return }
                if size.width >= size.height {
                    self.player?.currentPlayerManager.scalingMode = .aspectFit
                } else {
                    self.player?.currentPlayerManager.scalingMode = .aspectFill
                }
            }
        }
       
    }


    
    func cellPlayVideo() {
        if tableView.visibleCells.count == 1 {
            guard let cell = tableView.visibleCells.first else {
                return
            }
            let ip = tableView.indexPath(for: cell)
            if let ip = ip, let indexPath = playingIndexPath {
                let result = ip.compare(indexPath)
                print("result",result.rawValue)
                if result != .orderedSame {
                    player?.stop()
                    playTheVideoAtIndexPath(indexPath: ip, scrollToTop: false)
                    playingIndexPath = ip
                }
            }
        }
    }

//    func playTheVideoAtIndexPath(indexPath: IndexPath, scrollToTop: Bool) {
//        debugPrint("Attempting to play video at indexPath:", indexPath)
//
//        let cell = tableView.cellForRow(at: indexPath)
//        if let container = cell?.viewWithTag(10086) as? UIImageView {
//            debugPrint("Found container view for indexPath:", indexPath)
//            player?.play(playable: self.dataSource[indexPath.row])
//            controlView.resetControlView()
//            player?.updateNormalPlayer(with: container)
//            playingIndexPath = indexPath
//            debugPrint("Started playing video for indexPath:", indexPath)
//        } else {
//            debugPrint("Container view not found for indexPath:", indexPath)
//        }
//
//        let hasNextVideo = self.dataSource.count > indexPath.row + 1
//        if hasNextVideo {
//            let nextVideo = self.dataSource[indexPath.row + 1].video
//            let urlString = nextVideo?.thum
//
//            if let validUrlString = urlString {
//                DataPersistence.shared.cachePreload(urlString: validUrlString)
//                debugPrint("Preloading thumbnail for next video at indexPath:", indexPath.row + 1)
//            } else {
//                debugPrint("No valid URL string found for next video at indexPath:", indexPath.row + 1)
//            }
//        } else {
//            debugPrint("No next video available for indexPath:", indexPath)
//        }
//    }
    
    func playTheVideoAtIndexPath(indexPath: IndexPath, scrollToTop: Bool) {

        // Reload the row to ensure it's visible
        tableView.reloadRows(at: [indexPath], with: .none)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            // Ensure the layout is complete
            self.tableView.layoutIfNeeded()

            guard let cell = self.tableView.cellForRow(at: indexPath) else {
                return
            }

            // Check if the container view is found
            if let container = cell.viewWithTag(10086) as? UIImageView {
                self.controlView.resetControlView()
                self.player?.play(playable: self.dataSource[indexPath.row])
                self.player?.updateNormalPlayer(with: container)
                self.playingIndexPath = indexPath
            }

            // Preload thumbnail for next video
            let hasNextVideo = self.dataSource.count > indexPath.row + 1
            if hasNextVideo {
                let nextVideo = self.dataSource[indexPath.row + 1].video
                let urlString = nextVideo?.thum

                if let validUrlString = urlString {
                    DataPersistence.shared.cachePreload(urlString: validUrlString)
                }
            } else {
                debugPrint("No next video available for indexPath:", indexPath)
            }
        }
    }


    
    func handlePlayerOutofScreen(scrollView: UIScrollView) {
        if let indexPath = playingIndexPath {
            let cell = tableView.cellForRow(at: indexPath)
            guard cell == nil else {
                return
            }
            player?.stop()
        }
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            controlView.removeFromSuperview()
            for subView in player?.currentPlayerManager.view.subviews ?? [] {
                subView.removeFromSuperview()
            }
            player?.controlView = preControlView
            popbackBlock?()
        }
    }
    
    private func homeObserveEvent() {
        homeViewModel.eventHandler = { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .error(let error):
                print("error", error)
                DispatchQueue.main.async {
                    if let error = error {
                        if let dataError = error as? Moves.DataError {
                            switch dataError {
                            case .invalidResponse, .invalidURL, .network(_):
                                print("invalidData")
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
                
            case .newShowRelatedVideos(let showRelatedVideos):
                print("showRelatedVideos", showRelatedVideos)
                DispatchQueue.main.async {
                    if showRelatedVideos.code == 200 {
                        if self.startPointForYou == 0 {
                            self.forYou.removeAll()
                            self.forYou = showRelatedVideos.msg ?? []
                            self.dataSource = showRelatedVideos.msg ?? []
                        } else {
                            if let newMessages = showRelatedVideos.msg {
                                self.forYou.append(contentsOf: newMessages)
                            }
                        }
                        
                        self.tableView.reloadData()
                        self.setupPlayer()
                        
                    } else {
                        print("no response")
                        if self.startPointForYou == 0 {
                            self.dataSource.removeAll()
                        }
                    }
                }
            case .newShowNearbyVideos(let showNearbyVideos):
                print("showNearbyVideos", showNearbyVideos.code)
                DispatchQueue.main.async {
                    if showNearbyVideos.code == 200 {
                        if self.startPointNearby == 0 {
                            self.nearby.removeAll()
                            self.nearby = showNearbyVideos.msg ?? []
                        } else {
                            if let newMessages = showNearbyVideos.msg {
                                self.nearby.append(contentsOf: newMessages)
                            }
                        }
                        
                    } else {
                        print("no response")
                        if self.startPointNearby == 0 {
                            self.nearby.removeAll()
                        }
                    }
                }
            case .newShowFollowingVideos(let showFollowingVideos):
                print("showFollowingVideos", showFollowingVideos.code)
                DispatchQueue.main.async {
                    if showFollowingVideos.code == 200 {
                        if self.startPointFollowing == 0 {
                            self.following.removeAll()
                            self.following = showFollowingVideos.msg ?? []
                        } else {
                            if let newMessages = showFollowingVideos.msg {
                                self.following.append(contentsOf: newMessages)
                            }
                        }
                        
                    } else {
                        print("no response")
                        if self.startPointFollowing == 0 {
                            self.following.removeAll()
                        }
                    }
                }
            case .newReadyForOrder(let readyForOrder):break
            case .newLikeVideo(let likeVideo):
                print("likeVideo", likeVideo)
//                DispatchQueue.main.async {
//                    if likeVideo.errorMessage != "unlike" {
//                        if self.categoryArr[self.selectedCategory].category == .forYou {
//                            self.forYou[self.index].video?.like! += 1
//                            self.forYou = self.forYou
//                        } else if self.categoryArr[self.selectedCategory].category == .following {
//                            self.following[self.index].video?.like! += 1
//                            self.following = self.following
//                        } else {
//                            self.nearby[self.index].video?.like! += 1
//                            self.nearby = self.nearby
//                        }
//                        
//                    }else {
//                        if self.categoryArr[self.selectedCategory].category == .forYou {
//                            self.forYou[self.index].video?.like! -= 1
//                            self.forYou = self.forYou
//                        } else if self.categoryArr[self.selectedCategory].category == .following {
//                            self.following[self.index].video?.like! -= 1
//                            self.following = self.following
//                        } else {
//                            self.nearby[self.index].video?.like! -= 1
//                            self.nearby = self.nearby
//                        }
//                    }
//                }
               
            case .newAddVideoFavourite(let addVideoFavourite):break
            case .newShowVideoDetail(let showVideoDetail):break
            case .ShowVideoDetail2(let showVideoDetail):break
            }
        }
    }
    
    func initializePlayerIfNeeded() {
        guard !isInited else {
            print("Player already initialized")
            return
        }
        isInited = true
        print("Initializing player")

        let initialIndexPath = IndexPath(row: 0, section: 0)
        guard dataSource.count > initialIndexPath.row else {
            print("Data source is empty or index path out of bounds")
            return
        }

        player?.controlView = controlView
        print("Control view set, attempting to play the first video at index 0")

        playTheVideoAtIndexPath(indexPath: initialIndexPath, scrollToTop: false)

        if let isPlaying = player?.currentPlayerManager.isPlaying, !isPlaying {
            print("Player is not playing, starting playback")
            player?.currentPlayerManager.play()
        } else {
            print("Player is already playing")
        }
    }


    private func observeEvent() {
        self.viewModel.eventHandler = { [weak self] event in
            guard let self = self else { return }

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
                    self.loader.isHidden = true
                }
            case .showReportReasons(showReportReasons: _):
                print("showReportReasons")
            case .reportVideo(reportVideo: let reportVideo):
                print("reportVideo")
            case .repostVideo(repostVideo: let repostVideo):
                DispatchQueue.main.async {
                    print("repostVideo", repostVideo)
                    self.loader.isHidden = true
                    let cell = self.tableView.cellForRow(at: IndexPath(row: self.index, section: 0)) as! LVideoPlayerCell

                    var model = self.dataSource[self.index]

                    if repostVideo.code == 200 {
                        model.video?.repost = 1
                        Utility.showMessage(message: "Reposted Video Successfully", on: self.view)
                                       
                        cell.containerView.snp.updateConstraints { make in
                            make.height.equalTo(40)
                        }
                        cell.containerView.isHidden = false
                        cell.iconImageView.sd_setImage(with: URL(string: UserDefaultsManager.shared.profileUser), placeholderImage: UIImage(named: "videoPlaceholder"))
                    } else {
                        model.video?.repost = 0
                        cell.containerView.snp.updateConstraints { make in
                            make.height.equalTo(0)
                        }
                        cell.containerView.isHidden = true
                    }

                    self.dataSource[self.index].video?.repost = model.video?.repost
                    self.tableView.reloadData()
                    NotificationCenter.default.post(name: NSNotification.Name("changeNumber"), object: nil, userInfo: nil)
                }
            case .repostUser(repostUser: let repostUser):
                break
            }
        }
    }
    
    //MARK: - BUTTON ACTION
    @objc private func handleMoveToNextVideo() {
        Utility.showMessage(message: "Video Report Successfully", on: self.view)

        guard let visibleCells = tableView.visibleCells as? [UITableViewCell],
              let currentIndexPath = tableView.indexPath(for: visibleCells.last ?? UITableViewCell()) else {
            return
        }

        let nextRow = currentIndexPath.row + 1
        guard nextRow < tableView.numberOfRows(inSection: 0) else {
            return
        }

        let nextIndexPath = IndexPath(row: nextRow, section: 0)
        tableView.scrollToRow(at: nextIndexPath, at: .bottom, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard self.tableView.visibleCells.count == 1,
                  let nextVisibleCell = self.tableView.visibleCells.first,
                  let visibleIndexPath = self.tableView.indexPath(for: nextVisibleCell) else {
                return
            }

            self.player?.stop()
            self.playTheVideoAtIndexPath(indexPath: visibleIndexPath, scrollToTop: false)
            self.playingIndexPath = visibleIndexPath
        }
    }
}

extension HomeVideoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LVideoPlayerCell.self), for: indexPath) as? LVideoPlayerCell
        cell?.contentView.backgroundColor = .black
        cell?.indexPath = indexPath
        if dataSource.count > indexPath.row {
            cell?.updataViewModel(data: dataSource[indexPath.row])
        }
        cell?.profileClickHandler = { [weak self] indexPath in
            guard let self = self else {
                return
            }
            profileClick(indexPath: indexPath)
        }
        
        cell?.shareClickHandler = { [weak self] indexPath in
            guard let self = self else {
                return
            }
            shareClick(indexPath: indexPath)
        }
        cell?.commentClickHandler = { [weak self] indexPath in
            guard let self = self else {
                return
            }
            commentClick(indexPath: indexPath)
        }
        
        cell?.likeClickHandler = { [weak self] indexPath in
            guard let self = self else {
                return
            }
            self.player?.currentPlayerManager.pause()
            self.controlView.playButtonAction()
            
            let likeVideo = LikeVideoRequest(userId: UserDefaultsManager.shared.user_id, videoId: self.dataSource[indexPath.row].video?.id ?? 0)
            print("likeVideo", likeVideo)
            self.homeViewModel.likeVideo(parameters: likeVideo)
            
            homeObserveEvent()
        }
        
        cell?.markClickHandler = { [weak self] indexPath in
            guard let self = self else {
                return
            }
            self.player?.currentPlayerManager.pause()
            self.controlView.playButtonAction()
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
}

extension HomeVideoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoryCell, for: indexPath) as! HomeVideoCollectionViewCell
        
        let categoryItem = categoryArr[indexPath.row]
        cell.lblCategory.text = categoryItem.category.rawValue
        cell.lblCategory.textColor = categoryItem.isSelected ? UIColor.appColor(.white) : UIColor.appColor(.white)?.withAlphaComponent(0.6)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellsPerRow: CGFloat = 3
        let spaceBetweenCells: CGFloat = 10
        let categoryItem = categoryArr[indexPath.row]
        
        let totalSpacing = (cellsPerRow - 1) * spaceBetweenCells
        let collectionViewWidth = collectionView.frame.width
        let availableWidthPerCell = (collectionViewWidth - totalSpacing) / cellsPerRow
        
        let font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        let titleWidth = categoryItem.category.rawValue.size(withAttributes: [NSAttributedString.Key.font: font]).width
        
        let cellWidth = max(min(titleWidth + 20, availableWidthPerCell), availableWidthPerCell)

        return CGSize(width: cellWidth, height: 40)
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if UserDefaultsManager.shared.latitude == 0.0 || UserDefaultsManager.shared.longitude == 0.0 {
                let vc = LocationSettingViewController(nibName: "LocationSettingViewController", bundle: nil)
                vc.modalPresentationStyle = .overFullScreen
                self.navigationController?.present(vc, animated: false)
                
                return
            }
        }
        
        for i in 0..<categoryArr.count {
            categoryArr[i].isSelected = (i == indexPath.row)
        }
        
        homeVideoCategoryCollectionView.reloadData()
        let selectedCategory = categoryArr[indexPath.row].category

        self.dataSource.removeAll()
        self.player?.currentPlayerManager.stop()
        self.controlView.resetControlView()

        if let isPlaying = player?.currentPlayerManager.isPlaying, isPlaying {
            player?.currentPlayerManager.pause()
            self.controlView.playButtonAction()
        }
        
        switch selectedCategory.rawValue {
        case "Nearby":
            self.selectedCategory = 0
            if nearby.isEmpty {
                self.stackView.isHidden = false
                self.lblNoContent.text = "You have not any nearby video yet"
            } else {
                self.stackView.isHidden = true
                dataSource = nearby
            }
        case "Following":
            self.selectedCategory = 1
            if following.isEmpty {
                self.stackView.isHidden = false
                self.lblNoContent.text = "You have not any following video yet"
            } else {
                self.stackView.isHidden = true
                dataSource = following
            }
        default:
            self.selectedCategory = 2
            if forYou.isEmpty {
                self.stackView.isHidden = false
                self.lblNoContent.text = "You have not any video yet"
            } else {
                self.stackView.isHidden = true
                dataSource = forYou
            }
        }
        
        tableView.reloadData()
        
        if !dataSource.isEmpty {
            self.setupPlayer()
        }
        
        print("Selected category: \(selectedCategory.rawValue)")
    }


}

extension HomeVideoViewController {
    func profileClick(indexPath:IndexPath) {
        let model = dataSource[indexPath.row]
        if UserDefaultsManager.shared.user_id == "0" {
            player?.currentPlayerManager.pause()
            controlView.playButtonAction()
            if  let appdelegate = UIApplication.shared.delegate as? AppDelegate {
                appdelegate.presentLogin()
            }
        }else {
            let user = model.user
            if user?.id == nil || user?.id == 0 {
                Utility.showMessage(message: "Something went wrong. Please try later", on: self.view)
                return
            }
            if user?.id?.toString() == UserDefaultsManager.shared.user_id {
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
            myViewController.userResponse = user
            myViewController.callback = { [weak self] (user) -> Void in
                guard let self = self else {
                    return
                }
                dataSource[indexPath.row].user = user
                tableView.reloadData()
            }
            myViewController.hidesBottomBarWhenPushed = true
            myViewController.otherUserId = user?.id?.toString() ?? ""
            self.navigationController?.pushViewController(myViewController, animated: true)
        }
    }
    
    func repostClick(videoId: Int, indexPath: IndexPath) {
        self.repostIndex = indexPath.row
        let request = DeleteVideoRequest(videoId: videoId)
        self.viewModel.repostVideo(parameter: request)
        self.observeEvent()
    }
    
    func shareClick(indexPath:IndexPath) {
        let model = dataSource[indexPath.row]
        if UserDefaultsManager.shared.user_id == "0" {
            player?.currentPlayerManager.pause()
            controlView.playButtonAction()
            if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
                appdelegate.presentLogin()
            }
        } else {
        
            let myViewController = VideoShareViewController(nibName: "VideoShareViewController", bundle: nil)
            myViewController.videoId = model.video?.id ?? 0
            myViewController.repost = model.video?.repost ?? 0
            myViewController.indexPath = indexPath
            myViewController.repostHandler = { videoId, indexPath -> Void in
                print("callback")
                self.loader.isHidden = false
                self.repostClick(videoId: videoId, indexPath: indexPath)
            }
            myViewController.hidesBottomBarWhenPushed = true
            let nav = UINavigationController.init(rootViewController: myViewController)
            nav.isNavigationBarHidden = true
            nav.modalPresentationStyle = .overFullScreen
            self.navigationController?.present(nav, animated: true)
        }
    }
    
    func commentClick(indexPath:IndexPath) {
        let model = dataSource[indexPath.row]
        if UserDefaultsManager.shared.user_id == "0" {
            player?.currentPlayerManager.pause()
            controlView.playButtonAction()
            if  let appdelegate = UIApplication.shared.delegate as? AppDelegate {
                appdelegate.presentLogin()
            }
        }else {
//            self.pauseAllVideos()
            let video = model.video
            let user = model.user
            let newViewController = CommentViewController(nibName: "CommentViewController", bundle: nil)
            newViewController.videoId = video?.id ?? 0
            newViewController.profileImage = user?.profilePic ?? ""
            newViewController.username = user?.username ?? ""
            newViewController.commentDelegate = self
            let nav = UINavigationController.init(rootViewController: newViewController)
            nav.isNavigationBarHidden = true
            nav.modalPresentationStyle = .overFullScreen
            self.navigationController?.present(nav, animated: false)
            
        }
    }
}

extension HomeVideoViewController: CommentCountUpdateDelegate {
    func CommentCountUpdateDelegate(commentCount: Int) {
        if commentCount == 1 {
            let model = dataSource[playingIndexPath?.row ?? 0]
            var video = model.video
            let count = (video?.commentCount ?? 0) + 1
            video?.commentCount = count
            dataSource[playingIndexPath?.row ?? 0].video = video
            tableView.reloadData()
        }
    }
    
}

extension HomeVideoViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        cellPlayVideo()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handlePlayerOutofScreen(scrollView: scrollView)
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let tableViewHeight = scrollView.frame.size.height
        
        // Call the backend to load the next batch of video cells to the bottom
        if offsetY > contentHeight - tableViewHeight - (tableViewHeight * 4) {
            loadMoreVideos()
        }
    }
    
    private func loadMoreVideos() {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        loadMoreData?()
    }
    
    func loadMoreVideoFinish(videos: [HomeResponseMsg]) {
        if dataSource.count == videos.count {
            Utility.showMessage(message: "No more videos", on:view)
            return
        }
        dataSource = videos
        tableView.reloadData()
        isLoadingMore = false
    }
}


extension HomeVideoViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {
            print("Error: No location data found.")
            return
        }
        

        if UserDefaultsManager.shared.latitude == 0.0 || UserDefaultsManager.shared.longitude == 0.0 {
            UserDefaultsManager.shared.latitude = currentLocation.coordinate.latitude
            UserDefaultsManager.shared.longitude = currentLocation.coordinate.longitude
        }
        
        locManager.stopUpdatingLocation()
        if UserDefaultsManager.shared.location_name == "" {
            Utility.shared.getCityName(latitude: UserDefaultsManager.shared.latitude, longitude:  UserDefaultsManager.shared.longitude) { cityName in
                if let cityName = cityName {
                    print("City Name: \(cityName)")
                    
                    UserDefaultsManager.shared.location_address = ""
                    UserDefaultsManager.shared.location_id = 0
                    
                    UserDefaultsManager.shared.location_name = cityName
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            requestLocation()
        } else {
            print("Location access denied or restricted.")
        }
    }
}
