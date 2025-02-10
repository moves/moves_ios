//
//  VideoDetailController.swift
// //
//
//  Created by YS on 2024/9/16.
//

import UIKit
import ZFPlayer
import BadgeControl
import ZoomingTransition

class VideoDetailController: UIViewController {
    var viewModel = ReasonViewModel()
    var index: Int = 0 // 当前索引
    var dataSource: [HomeResponseMsg] = []
    var popbackBlock: (() -> Void)? // 返回时的闭包
    lazy var controlView:LZFControlView = {
        let controlView = LZFControlView()
        return controlView
    }()
    var ourVideo = false
    var playingIndexPath: IndexPath?
    var preControlView: ZFPlayerControlView?
    var isInited: Bool = false
    var player: LPlayerController? {
        didSet {
            preControlView = player?.controlView as? ZFPlayerControlView
            preControlView?.removeFromSuperview()
        }
    }
    
    private lazy var loader: UIView = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            fatalError("Unable to access key window")
        }
        return Utility.shared.createActivityIndicator(keyWindow)
    }()

    var isLoadingMore = false

    var repostIndex = 0
    var loadMoreData: (() -> Void)?
    
    

    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.isPagingEnabled = true
        tableView.delegate = self
        tableView.dataSource = self
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
        tableView.frame = CGRect(x: 0, y: 0, width: UIDevice.ex.screenWidth, height: UIDevice.ex.screenHeight)
        tableView.rowHeight = tableView.frame.size.height
        return tableView
    }()

    lazy var backBtn: EnlargedButton = {
        let backBtn = EnlargedButton(type: .custom)
        backBtn.touchAreaInsets = UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -20)
        backBtn.setImage(UIImage(named: "white_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backClick(_:)), for: .touchUpInside)
       return backBtn
    }()
   
    @objc func backClick(_ sender: UIButton) {
        popbackBlock?()
        navigationController?.popViewController(animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let isPlaying =  player?.currentPlayerManager.isPlaying, isPlaying {
            self.controlView.playButtonAction()
            player?.currentPlayerManager.pause()
        }
    }
    

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        backBtn.frame = CGRect(x: 17, y: UIDevice.ex.statusBarHeight + 10, width: 16, height: 32)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isInited {
            isInited = true
            player?.controlView = controlView
            if let indexPath = playingIndexPath {
                playTheVideoAtIndexPath(indexPath: indexPath, scrollToTop: false)
            }
        }
        
        if let isPlaying =  player?.currentPlayerManager.isPlaying, !isPlaying {
            player?.currentPlayerManager.play()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleMoveToNextVideo), name: .moveToNextVideo, object: nil)

        setupUI()
        setupPlayer()
        
        tableView.reloadData()
        playingIndexPath = IndexPath(row: index, section: 0)
        tableView.scrollToRow(at: playingIndexPath!, at: .middle, animated: false)
    

        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleRightSwipe))
        rightSwipe.direction = .right
        rightSwipe.delegate = self
        view.addGestureRecognizer(rightSwipe)
    }
    
    @objc func handleRightSwipe() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleMoveToNextVideo() {
        Utility.showMessage(message: "Video Report Successfully", on: self.view)
        let nextIndex = index + 1
        let indexPath = IndexPath(row: nextIndex, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.tableView.visibleCells.count == 1 {
                guard let cell = self.tableView.visibleCells.first else {
                    return
                }
                let visibleIndexPath = self.tableView.indexPath(for: cell)
                
                if let visibleIndexPath = visibleIndexPath, let playingIndexPath = self.playingIndexPath {
                    let result = visibleIndexPath.compare(playingIndexPath)
                    if result != .orderedSame {
                        self.player?.stop()
                        self.playTheVideoAtIndexPath(indexPath: visibleIndexPath, scrollToTop: false)
                        self.playingIndexPath = visibleIndexPath
                    }
                }
            }
        }
    }
    

    
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(backBtn)
//        view.addSubview(shopButton)
    }
    
    func setupPlayer() {
        if  player == nil {
            player = LPlayerController.playr(withContainerView: UIView())
            player?.playableArray = dataSource
        } else {
            for subView in player?.currentPlayerManager.view.subviews ?? [] {
                self.view.addSubview(subView)
            }
        }
        
        self.player?.presentationSizeChanged = { [weak self] asset, size in
            guard let self = self else {
                return
            }
            if size.width >= size.height {
                player?.currentPlayerManager.scalingMode = .aspectFit
            } else {
                player?.currentPlayerManager.scalingMode = .aspectFill
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
                if result != .orderedSame {
                    player?.stop()
                    playTheVideoAtIndexPath(indexPath: ip, scrollToTop: false)
                    playingIndexPath = ip
                }
            }
        }
    }
    
    func playTheVideoAtIndexPath(indexPath: IndexPath, scrollToTop:Bool) {
        debugPrint(indexPath)
        let cell = tableView.cellForRow(at: indexPath)
        if let container = cell?.viewWithTag(10086) as? UIImageView {
            player?.play(playable: self.dataSource[indexPath.row])
            controlView.resetControlView()
            player?.updateNormalPlayer(with: container)
            playingIndexPath = indexPath
        }
        // preload video thumbnail image for next cell
        let hasNextVideo = self.dataSource.count > indexPath.row + 1
        if hasNextVideo {
            let nextVideo = self.dataSource[indexPath.row + 1].video
            let urlString = nextVideo?.user_thumbnail?.isEmpty == false ? nextVideo?.user_thumbnail : nextVideo?.default_thumbnail
            
            if let validUrlString = urlString {
                DataPersistence.shared.cachePreload(urlString: validUrlString)
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
    
    
    deinit {
        //remove
        player?.stop()
    }
    

    func observeEvent() {
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
}


//Cell Click
extension VideoDetailController {
    func profileClick(indexPath:IndexPath) {
        let model = dataSource[indexPath.row]
        if UserDefaultsManager.shared.user_id == "0" {
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
            if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
                appdelegate.presentLogin()
            }
        } else {
        
            if ourVideo {
                let video = dataSource[indexPath.row].video
               
                let vc = VideoEditPopupViewController(nibName: "VideoEditPopupViewController", bundle: nil)
                vc.modalPresentationStyle = .overFullScreen
                vc.repost = video?.repost ?? 0
                vc.videoID = video?.id ?? 0
                vc.objVideo = dataSource[indexPath.row]
                vc.indexPath = indexPath
                vc.callback = { test in
                    NotificationCenter.default.post(name: NSNotification.Name("changeNumber"), object: nil, userInfo: nil)
                    self.loader.isHidden = true
                    self.navigationController?.popViewController(animated: true)
                }
                
                vc.repostHandler = { videoId, indexPath in
                    print("callback")
                    self.loader.isHidden = false
                    self.repostClick(videoId: videoId, indexPath: indexPath)
                }
                navigationController?.present(vc, animated: true)
            }else {
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
    }
    
    func commentClick(indexPath:IndexPath) {
        let model = dataSource[indexPath.row]
        if UserDefaultsManager.shared.user_id == "0" {
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

extension VideoDetailController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let swipeGesture = gestureRecognizer as? UISwipeGestureRecognizer {
            return swipeGesture.direction == .right
        }
        return false
    }
}

extension VideoDetailController: UIScrollViewDelegate {
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

extension VideoDetailController: UITableViewDelegate, UITableViewDataSource {
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
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
}

extension VideoDetailController: CommentCountUpdateDelegate {
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

class EnlargedButton: UIButton {
    var touchAreaInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let bounds = self.bounds
        let hitArea = bounds.inset(by: touchAreaInsets)
        return hitArea.contains(point)
    }
}

extension VideoDetailController: ZoomTransitionAnimatorDelegate {
    func transitionWillStart() {
        self.view.alpha = 0
    }
    
    func transitionDidEnd() {
        self.view.alpha = 1
    }
    
    func referenceImage() -> UIImage? {
        return FrameHelper.getScreenshot(with: self.view)
    }
    
    func imageFrame() -> CGRect? {
        return self.view.frame
    }
}
