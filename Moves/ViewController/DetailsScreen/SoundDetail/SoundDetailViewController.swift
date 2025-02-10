//
//  SoundDetailViewController.swift
// //
//
//  Created by iMac on 15/06/2024.
//

import AVFAudio
import SkeletonView
import UIKit
import ZoomingTransition
import SDWebImage
class SoundDetailViewController: ZoomingPushVC, SkeletonCollectionViewDelegate, SkeletonCollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var lastSelectedIndexPath: IndexPath? = nil
    private let footerView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    var isDataLoading: Bool = false
    var startPoint = 0
    var sound_section_id = 0
    var soundName = ""
    var createdBy = ""
    var soundUrl = ""
    var thum = ""
    var isSoundLoading = false
    var isPlaying = false
    var player: AVAudioPlayer?
    let viewModel = SoundDetailViewModel()
    var showSoundsAgainstSection: HomeResponse?
   
    @IBOutlet var lblError: UILabel!
    @IBOutlet var mainView: UIView!
    @IBOutlet var imgThum: UIImageView!
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var soundCollectionView: UICollectionView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var lblSoundCount: UILabel!
    @IBOutlet var lblSoundCrated: UILabel!
    @IBOutlet var lblSoundName: UILabel!
    @IBOutlet var soundThum: UIImageView!
    
    @IBOutlet var soundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        soundView.startSkeletonAnimation()
        soundView.showAnimatedGradientSkeleton()
        soundCollectionView.showAnimatedGradientSkeleton()
        self.initViewModel(startPoint: 0)
        self.configuration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopSound()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showSoundsAgainstSection?.msg?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoProfileCollectionViewCell", for: indexPath) as! VideoProfileCollectionViewCell
        let video = showSoundsAgainstSection?.msg?[indexPath.row].video
        let thum = video?.thum ?? ""
        cell.videoView.sd_setImage(with: URL(string: thum), placeholderImage: UIImage(named: ""), options: .continueInBackground, completed: { [weak cell] image, _, _, _ in
            guard let cell = cell, let image = image else { return }
            UIView.transition(with: cell.videoView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                cell.videoView.image = image
            }, completion: nil)
        })
        cell.lblView.text = video?.view?.toString()
        
        cell.pinnedview.isHidden = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let video = showSoundsAgainstSection?.msg?[indexPath.row].video
            if let thum = video?.thum, let url = URL(string: thum) {
                SDWebImagePrefetcher.shared.prefetchURLs([url])
            }
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        return "VideoProfileCollectionViewCell"
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3 - 1, height: 230)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.lastSelectedIndexPath = indexPath
        let videoDetail = VideoDetailController()
        videoDetail.dataSource = showSoundsAgainstSection?.msg ?? []
        videoDetail.index = indexPath.row
        videoDetail.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(videoDetail, animated: true)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        if isPlaying {
            stopSound()
        } else if !isSoundLoading {
            downloadAndPlaySound(from: soundUrl)
        }
    }
    
    func downloadAndPlaySound(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent(url.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: tempFile.path) {
            playSound(from: tempFile)
            return
        }
        
        isSoundLoading = true
        updateButtonIcon()
        
        let downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] location, _, error in
            guard let self = self else { return }
            guard let location = location, error == nil else {
                self.isSoundLoading = false
                self.updateButtonIcon()
                return
            }
            
            do {
                try FileManager.default.moveItem(at: location, to: tempFile)
                self.playSound(from: tempFile)
            } catch {
                print("File error: \(error.localizedDescription)")
                self.isSoundLoading = false
                self.updateButtonIcon()
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
            
            isPlaying = true
            isSoundLoading = false
            updateButtonIcon()
        } catch {
            print("Audio player error: \(error.localizedDescription)")
            isSoundLoading = false
            updateButtonIcon()
        }
    }
    
    func stopSound() {
        player?.stop()
        isPlaying = false
        updateButtonIcon()
    }
    
    func updateButtonIcon() {
        DispatchQueue.main.async {
            if self.isSoundLoading {
                self.btnPlay.setImage(UIImage(systemName: "arrow.down.circle"), for: .normal)
            } else if self.isPlaying {
                self.btnPlay.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            } else {
                self.btnPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
        }
    }
}

extension SoundDetailViewController {
    func configuration() {
        soundCollectionView.delegate = self
        soundCollectionView.dataSource = self
        soundCollectionView.register(UINib(nibName: "VideoProfileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VideoProfileCollectionViewCell")
        
        soundCollectionView.prepareSkeleton { [weak self] _ in
            if let visibleCells = self?.soundCollectionView.visibleCells {
                for cell in visibleCells {
                    if let videoProfileCell = cell as? VideoProfileCollectionViewCell {
                        videoProfileCell.contentView.showAnimatedSkeleton()
                        videoProfileCell.lblView.showAnimatedSkeleton()
                        videoProfileCell.videoView.showAnimatedSkeleton()
                        videoProfileCell.pinnedview.showAnimatedSkeleton()
                        videoProfileCell.imgplay.showAnimatedSkeleton()
                    }
                }
            }
        }
       
        soundCollectionView.register(CollectionViewFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        (soundCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: soundCollectionView.bounds.width, height: 50)
        footerView.color = UIColor(named: "theme")
        footerView.hidesWhenStopped = true
    }
    
    func initViewModel(startPoint: Int) {
        let sound = ShowVideosAgainstSoundRequest(userId: UserDefaultsManager.shared.user_id, soundId: sound_section_id.toString(), startingPoint: startPoint, deviceId: UserDefaultsManager.shared.deviceID)
        viewModel.showVideosAgainstSound(parameters: sound)
        print("sound", sound)
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
            case .newShowSoundsAgainstSection(showSoundsAgainstSection: let showSoundsAgainstSection):
                self.handleSound(showVideoAgainstSound: showSoundsAgainstSection)
            }
        }
    }
    
    private func handleSound(showVideoAgainstSound: HomeResponse) {
        DispatchQueue.main.async {
            self.lblSoundName.text = self.soundName
            self.imgThum.sd_setImage(with: URL(string: self.thum), placeholderImage: UIImage(named: "placeholder 2"))
            
            self.lblSoundCrated.isHidden = self.createdBy.isEmpty
            self.lblSoundCrated.text = self.createdBy
            
            if showVideoAgainstSound.code == 200 {
                self.lblError.isHidden = true
                
                if self.startPoint == 0 {
                    self.viewModel.showSoundsAgainstSection = showVideoAgainstSound
                    self.showSoundsAgainstSection = showVideoAgainstSound
                } else if let newMessages = showVideoAgainstSound.msg {
                    self.viewModel.showSoundsAgainstSection?.msg?.append(contentsOf: newMessages)
                    self.showSoundsAgainstSection?.msg?.append(contentsOf: newMessages)
                }
                
                DispatchQueue.main.async {
                    self.soundView.hideSkeleton()
                    self.soundCollectionView.hideSkeleton()
                    self.soundCollectionView.reloadData()
                }
            }else if showVideoAgainstSound.code == 201 {
                if self.startPoint == 0 {
                    self.lblError.isHidden = false
                    self.showSoundsAgainstSection?.msg?.removeAll()
                    DispatchQueue.main.async {
                        self.soundView.hideSkeleton()
                        self.soundCollectionView.hideSkeleton()
                        self.soundCollectionView.reloadData()
                    }
                }
            }
        }
    }
}

extension SoundDetailViewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging")
        self.footerView.stopAnimating()
        isDataLoading = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        self.footerView.stopAnimating()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
        if scrollView == self.scrollView {
            if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height {
                if !isDataLoading {
                    isDataLoading = true
                    footerView.startAnimating()
                    startPoint += 1
                    initViewModel(startPoint: startPoint)
                }
            }
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height {
            self.footerView.hidesWhenStopped = true
            self.footerView.stopAnimating()
        }
    }
}

extension SoundDetailViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        updateButtonIcon()
    }
}

extension SoundDetailViewController: ZoomTransitionAnimatorDelegate {
    func transitionWillStart() {
        guard let lastSelected = self.lastSelectedIndexPath else { return }
        self.soundCollectionView.cellForItem(at: lastSelected)?.isHidden = true
    }

    func transitionDidEnd() {
        guard let lastSelected = self.lastSelectedIndexPath else { return }
        self.soundCollectionView.cellForItem(at: lastSelected)?.isHidden = false
    }

    func referenceImage() -> UIImage? {
        guard
            let lastSelected = self.lastSelectedIndexPath,
            let cell = self.soundCollectionView.cellForItem(at: lastSelected) as? VideoProfileCollectionViewCell
        else {
            return nil
        }

        return cell.videoView.image
    }

    func imageFrame() -> CGRect? {
        guard
            let lastSelected = self.lastSelectedIndexPath,
            let cell = self.soundCollectionView.cellForItem(at: lastSelected) as? VideoProfileCollectionViewCell
        
        else {
            return self.view.frame
        }
        
        return FrameHelper.getTargerFrame(originalView: cell.videoView, targetView: self.view)  ?? self.view.frame



    }
}

