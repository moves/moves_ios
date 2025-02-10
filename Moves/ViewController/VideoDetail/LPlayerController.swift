//
//  LPlayerController.swift
// //
//
//  Created by YS on 2024/9/16.
//

import UIKit
import ZFPlayer
import KTVHTTPCache


protocol XSTPlayable: Equatable {
    /// string 视频链接
    var video_url: String? { get set }
    
}

extension XSTPlayable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.video_url == rhs.video_url
    }
}




class LPlayerController: NSObject {
    // 预加载上几条
    var preLoadNum = 3
    /// 预加载下几条
    var nextLoadNum = 3
    /// 预加载的的百分比，默认10%
    var preloadPrecent = 0.1
    /// 设置playableAssets后，马上预加载的条数
    var initPreloadNum = 3
    /// The indexPath is playing.
    
    var playingIndexPath: IndexPath? {
        get {
            return player.playingIndexPath
        }
    }
    
    var containerView: UIView? {
        get {
            return player.containerView
        }
    }
    
    var currentPlayable: HomeResponseMsg?
    
    var currentPlayerManager: (any ZFPlayerMediaPlayback) {
        get {
            return player.currentPlayerManager
        }
    }
    var wwanAutoPlay = false
    var isPlaying = false
    var player: ZFPlayerController!
    var preloadArr:[MPPreLoaderModel] = []
    var isAnimating = false
    var orientation: UIInterfaceOrientation = .unknown
    
    var _playableArray:[HomeResponseMsg] = []
    var playableArray:[HomeResponseMsg] {
        set {
            _playableArray = newValue
            cancelAllPreload()
            let rangeLength = min(initPreloadNum, playableArray.count)
            let subArray = playableArray.prefix(rangeLength)
            for model in subArray {
                if let preload = getPreloadModel(model.video?.video ?? "") {
                    preloadArr.append(preload)
                }
            }
            processLoader()
        }
        
        get {
            return _playableArray
        }
        
    }
    
    var isWWANAutoPlay: Bool {
        get {
            return player.isWWANAutoPlay
        }
        set {
            player.isWWANAutoPlay = newValue
        }
    }
    
    var controlView: (ZFPlayerMediaControl & UIView)? {
        didSet {
            player.controlView = controlView
        }
    }
    
    var playerDidToEnd: ((ZFPlayerMediaPlayback) -> Void)? {
        didSet {
            player.playerDidToEnd = { asset in
                self.playerDidToEnd?(asset)
            }
        }
    }
    
    var playerPlayFailed: ((ZFPlayerMediaPlayback, Any) -> Void)? {
        set {
            player.playerPlayFailed = newValue
        }
        get {
            return player.playerPlayFailed
        }
    }
    
    var playerPlayTimeChanged: ((ZFPlayerMediaPlayback, TimeInterval, TimeInterval) -> Void)? {
        set {
            player.playerPlayTimeChanged = newValue
        }
        get {
            player.playerPlayTimeChanged;
        }
    }
    
    var playerBufferTimeChanged: ((ZFPlayerMediaPlayback, TimeInterval) -> Void)? {
        set {
            player.playerBufferTimeChanged = newValue
        }
        get {
            return player.playerBufferTimeChanged
        }
    }
    
    var presentationSizeChanged: ((ZFPlayerMediaPlayback, CGSize) -> Void)? {
        set {
            player.presentationSizeChanged = newValue
        }
        
        get {
            return player.presentationSizeChanged
        }
    }
    
    var playerPlayStateChanged: ((ZFPlayerMediaPlayback, ZFPlayerPlaybackState) -> Void)? {
        set {
            player.playerPlayStateChanged = newValue
        }
        
        get {
            return player.playerPlayStateChanged
        }
    }
    
    var playerLoadStateChanged: ((ZFPlayerMediaPlayback, ZFPlayerLoadState) -> Void)? {
        set {
            player.playerLoadStateChanged = newValue
        }
        get {
            return player.playerLoadStateChanged
        }
    }
    
    var zf_playerDisappearingInScrollView: ((IndexPath, CGFloat) -> Void)? {
        set {
            player.zf_playerDisappearingInScrollView = newValue
        }
        
        get {
            return player.zf_playerDisappearingInScrollView
        }
    }
    
    var zf_playerDidDisappearInScrollView: ((IndexPath) -> Void)? {
        set {
            player.zf_playerDidDisappearInScrollView = newValue
        }
        
        get {
            return player.zf_playerDidDisappearInScrollView
        }
    }
    
    var playerApperaPercent: CGFloat  {
        get {
            return player.playerApperaPercent
        }
        set {
            player.playerApperaPercent = newValue
        }
    }
    
    var playerDisapperaPercent: CGFloat {
        get {
            return player.playerDisapperaPercent
        }
        set {
            player.playerDisapperaPercent = newValue
        }
    }
    
    // MARK: - Init
    static func player(with containerView: UIView) -> LPlayerController {
        return LPlayerController(containerView: containerView)
    }
    
    convenience init(containerView: UIView) {
        self.init()
        let mgr = MPlayerAttributeManager()
        player = ZFPlayerController(playerManager: mgr, containerView: containerView)
        player.customAudioSession = true
        setup()
    }
    
    static func player(with scrollView: UIScrollView, containerViewTag: Int) -> LPlayerController {
        return LPlayerController(scrollView: scrollView, containerViewTag: containerViewTag)
    }
    
    convenience init(scrollView: UIScrollView, containerViewTag: Int) {
        self.init()
        let mgr = MPlayerAttributeManager()
        player = ZFPlayerController(scrollView: scrollView, playerManager: mgr, containerViewTag: containerViewTag)
        player.disableGestureTypes = .pan
        player.customAudioSession = true
        setup()
    }
    
    override init() {
        super.init()
    }
    
    private func setup() {
        
        player.allowOrentitaionRotation = false
        player.playerDisapperaPercent = 0.5
        player.playerApperaPercent = 0.5
        player.playerDidToEnd = { [weak self] asset in
            self?.player.currentPlayerManager.replay()
        }
    }
    
    static func playr(withContainerView containerView: UIView) -> LPlayerController {
        return LPlayerController(containerView: containerView)
    }
    
    func stop() {
        player.scrollView?.zf_playingIndexPath = nil
        player.stop()
    }
    
    func stopCurrentPlayingCell() {
        player.stopCurrentPlayingCell()
    }
    
    func play(indexPath: IndexPath, playable: HomeResponseMsg) {
        cancelAllPreload()
        currentPlayable = playable
        if let url = URL(string: playable.video?.video ?? "") {
//            player.playTheIndexPath(indexPath, assetURL: url, scrollPosition: .top, animated: true)
            player.playTheIndexPath(indexPath, assetURL: url)
            player.currentPlayerManager.playerReadyToPlay = { [weak self] asset, assetURL in
                self?.preload(playable)
            }
        }
        
        
    }
    
    func play(playable: HomeResponseMsg) {
        currentPlayable = playable
        player.assetURL = URL(string: playable.video?.video ?? "")
        player.currentPlayerManager.playerReadyToPlay = { [weak self] asset, assetURL in
            self?.preload(playable)
        }
    }
    
    func setDisappearPercent(_ disappearPercent: CGFloat, appearPercent: CGFloat) {
        player.playerDisapperaPercent = disappearPercent
        player.playerApperaPercent = appearPercent
    }
    
    func enterLandscapeFullScreen(orientation: UIInterfaceOrientation, animated: Bool) {
        let cellHeight = UIDevice.ex.isIphoneX ? UIDevice.ex.screenHeight - 83 : UIDevice.ex.screenHeight
        guard !isAnimating, self.orientation != orientation else { return }
        if player.currentPlayerManager.playState == .playStatePlaying || player.currentPlayerManager.playState == .playStatePaused {
            isAnimating = true
        }
        
        self.orientation = orientation
        let rotation: CGFloat = (orientation == .landscapeLeft) ? .pi / 2 : .pi * 1.5
        let landRect = CGRect(x: 0, y: 0, width: cellHeight, height: UIDevice.ex.screenHeight)
        let presentView = player.currentPlayerManager.view
        UIView.animate(withDuration: 0.35, animations: {
            presentView.layer.setAffineTransform(CGAffineTransform(rotationAngle: rotation))
        }) { _ in
            self.isAnimating = false
        }
        presentView.layer.bounds = landRect
    }
    
    func exitFullScreen(animated: Bool) {
        let cellHeight = UIDevice.ex.isIphoneX ? UIDevice.ex.screenHeight - 49 : UIDevice.ex.screenHeight
        guard !isAnimating, orientation != .portrait else { return }
        
        let presentView = player.currentPlayerManager.view
        if !animated {
            presentView.layer.setAffineTransform(.identity)
            orientation = .portrait
        } else {
            isAnimating = true
            orientation = .portrait
            UIView.animate(withDuration: 0.35, animations: {
                presentView.layer.setAffineTransform(.identity)
            }) { _ in
                self.isAnimating = false
            }
        }
        presentView.layer.bounds = CGRect(x: 0, y: 0, width: UIDevice.ex.screenWidth, height: cellHeight)
    }
    
    func updateScrollViewPlayerToCell() {
        if let playingIndexPath = player.scrollView?.zf_playingIndexPath,
           let cell = player.scrollView?.zf_getCell(for: playingIndexPath),
           let containerView = cell.viewWithTag(player.containerViewTag) {
            updateNormalPlayer(with: containerView)
        }
    }
    
    func updateNormalPlayer(with containerView: UIView) {
        player.addPlayerView(toContainerView: containerView)
    }
    
    func controoll() {
        
    }
    
    static func player(withScrollView scrollView: UIScrollView, containerViewTag: Int) -> LPlayerController {
        return LPlayerController(scrollView: scrollView, containerViewTag: containerViewTag)
    }
    
    
    private func preload(_ resource: HomeResponseMsg) {
        guard playableArray.count > 1 else { return }
        guard nextLoadNum != 0 || preLoadNum != 0 else { return }
        
        guard let start = playableArray.firstIndex(of: resource) else { return }
        
        cancelAllPreload()
        var index = 0
        for i in (start + 1)..<playableArray.count where index < nextLoadNum {
            index += 1
            let model = playableArray[i]
            if let preModel = getPreloadModel(model.video?.video) {
                print("预加载下一个Video.url=====\(model.video?.video)")
                preloadArr.append(preModel)
            }
        }
        
        index = 0
        for i in stride(from: start - 1, through: 0, by: -1) where index < preLoadNum {
            index += 1
            let model = playableArray[i]
            if let preModel = getPreloadModel(model.video?.video) {
                print("预加载上一个Video.url=====\(model.video?.video)")
                preloadArr.append(preModel)
            }
        }
        processLoader()
    }
    
    func getPreloadModel(_ urlStr: String?) -> MPPreLoaderModel? {
        guard let urlStr = urlStr else { return nil }
        
        var res = false
        for model in self.preloadArr {
            if model.url == urlStr {
                res = true
                break
            }
        }
        if res { return nil }
        
        guard let proxyUrl = KTVHTTPCache.proxyURL(withOriginalURL: URL(string: urlStr)) else { return nil }
        if let item = KTVHTTPCache.cacheCacheItem(with: proxyUrl)  {
            let cachePercent = Double(item.cacheLength) / Double(item.totalLength)
            if cachePercent >= preloadPrecent {
                return nil
            }
        }
        let req = KTVHCDataRequest(url: proxyUrl, headers: [:])
        if let loader = KTVHTTPCache.cacheLoader(with: req) {
            return MPPreLoaderModel(url: urlStr, loader: loader)
        }
        return nil
    }
    
    func processLoader() {
        guard preloadArr.count > 0 else {
            return
        }
        let model = preloadArr.first
        model?.loader?.delegate = self
        model?.loader?.prepare()
    }
    
    func removePreloadTask(loader: KTVHCDataLoader) {
        let preloadQueue = DispatchQueue(label: "com.yourapp.preloadQueue", attributes: .concurrent)
        preloadQueue.sync(flags: .barrier) {
            var target: MPPreLoaderModel? = nil
            for model in self.preloadArr {
                if model.loader == loader {
                    target = model
                    break
                }
            }
            if let target = target {
                if let index = self.preloadArr.firstIndex(of: target) {
                    self.preloadArr.remove(at: index)
                }
            }
        }
    }
    
    func cancelAllPreload() {
        guard preloadArr.count > 0 else {
            return
        }
        preloadArr.forEach { $0.loader?.close() }
        preloadArr.removeAll()
    }
    
    
    deinit {
        cancelAllPreload()
        player = nil
    }
}

extension LPlayerController: KTVHCDataLoaderDelegate {
    @objc func ktv_loaderDidFinish(_ loader: KTVHCDataLoader) {
    }
    
    @objc func ktv_loader(_ loader: KTVHCDataLoader, didFailWithError error: Error) {
        removePreloadTask(loader: loader)
        processLoader()
    }
    
    @objc func ktv_loader(_ loader: KTVHCDataLoader, didChangeProgress progress: Double) {
        if progress >= preloadPrecent {
            loader.close()
            removePreloadTask(loader: loader)
            processLoader()
        }
    }
}


