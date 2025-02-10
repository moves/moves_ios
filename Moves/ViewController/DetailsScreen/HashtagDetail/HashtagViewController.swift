//
//  HashtagViewController.swift
// //
//
//  Created by Eclipse on 13/06/2024.
//

import SkeletonView
import UIKit
import ZoomingTransition
import SDWebImage
class HashtagViewController: ZoomingPushVC, SkeletonCollectionViewDelegate, UICollectionViewDelegateFlowLayout, SkeletonCollectionViewDataSource, UIScrollViewDelegate {
    
    var lastSelectedIndexPath: IndexPath? = nil
    
    let viewModel = HashtagVideoViewModel()
    var showVideosAgainstHashtag: ShowVideosAgainstHashtagResponse?
    var startPoint = 0
    var hashtag = ""
    var hashtag_id = ""
    var isNextPageLoad = false
   
    private let footerView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    var isDataLoading: Bool = false
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var lblTotalVideos: UILabel!
    @IBOutlet var lblHashtag: UILabel!
    @IBOutlet var hashtagCollectionView: UICollectionView!
    @IBOutlet var hashtagView: UIView!
    @IBOutlet var btnFavorite: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hashtagView.startSkeletonAnimation()
        hashtagView.showAnimatedGradientSkeleton()
        hashtagCollectionView.showAnimatedGradientSkeleton()
        scrollView.delegate = self
        initViewModel(startPoint: 0)
        configuration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showVideosAgainstHashtag?.msg?.hashtag.videos.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoProfileCollectionViewCell", for: indexPath) as! VideoProfileCollectionViewCell
        let video = showVideosAgainstHashtag?.msg?.hashtag.videos[indexPath.row].video
        let thum = video?.thum ?? ""
        cell.videoView.sd_setImage(with: URL(string: thum), placeholderImage: UIImage(named: ""), options: .continueInBackground, completed: { [weak cell] image, _, _, _ in
            guard let cell = cell, let image = image else { return }
            UIView.transition(with: cell.videoView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                cell.videoView.image = image
            }, completion: nil)
        })
        cell.lblView.text = video?.view?.toString() ?? ""
        
        cell.pinnedview.isHidden = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let video = showVideosAgainstHashtag?.msg?.hashtag.videos[indexPath.row].video
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
        videoDetail.dataSource = showVideosAgainstHashtag?.msg?.hashtag.videos ?? []
        videoDetail.index = indexPath.row
        videoDetail.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(videoDetail, animated: true)
    }
   
    @IBAction func backButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addToFavoritesButtonPressed(_ sender: UIButton) {
        if sender.titleLabel?.text == "Add to Favorites" {
            btnFavorite.setTitle("Added to Favorites", for: .normal)
            btnFavorite.setImage(UIImage(named: "bookmarked"), for: .normal)
        } else {
            btnFavorite.setTitle("Add to Favorites", for: .normal)
            btnFavorite.setImage(UIImage(named: "Bookmark"), for: .normal)
        }
       
        let addHashtagFavourite = AddHashtagFavouriteRequest(userId: UserDefaultsManager.shared.user_id, hashtagId: hashtag_id)
        viewModel.addHashtagFavourite(parameters: addHashtagFavourite)
        print("addHashtagFavourite", addHashtagFavourite)
        observeEvent()
    }
}

extension HashtagViewController {
    func configuration() {
        hashtagCollectionView.delegate = self
        hashtagCollectionView.dataSource = self
        hashtagCollectionView.register(UINib(nibName: "VideoProfileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VideoProfileCollectionViewCell")
        
        hashtagCollectionView.register(CollectionViewFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        (hashtagCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: hashtagCollectionView.bounds.width, height: 50)
        footerView.color = UIColor(named: "theme")
        footerView.hidesWhenStopped = true
        
        hashtagCollectionView.prepareSkeleton { [weak self] _ in
            if let visibleCells = self?.hashtagCollectionView.visibleCells {
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
    }
    
    func initViewModel(startPoint: Int) {
        let hashtag = ShowVideosAgainstHashtagRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: startPoint, hashtag: self.hashtag)
        viewModel.showVideosAgainstHashtag(parameters: hashtag)
        print("hashtag", hashtag)
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
                    self.hashtagView.hideSkeleton(transition: .crossDissolve(transitionDurationStepper))
                }

            case .newShowVideosAgainstHashtag(showVideosAgainstHashtag: let showVideosAgainstHashtag):
                DispatchQueue.main.async {
                    self.lblHashtag.text = "#" + self.hashtag
                    if showVideosAgainstHashtag.code == 200 {
                        if self.startPoint == 0 {
                            self.viewModel.showVideosAgainstHashtag = showVideosAgainstHashtag
                            self.showVideosAgainstHashtag = showVideosAgainstHashtag
                            
                            let favorite = showVideosAgainstHashtag.msg?.hashtag.favourite ?? 0
                            if favorite == 0 {
                                self.btnFavorite.setTitle("Add to Favorites", for: .normal)
                                self.btnFavorite.setImage(UIImage(named: "Bookmark"), for: .normal)
                            } else {
                                self.btnFavorite.setTitle("Added to Favorites", for: .normal)
                                self.btnFavorite.setImage(UIImage(named: "bookmarked"), for: .normal)
                            }

                            let video = Utility.shared.formatPoints(num: showVideosAgainstHashtag.msg?.hashtag.videosCount.toDouble() ?? 0.0)
                            self.lblTotalVideos.text = video + " Videos"
                            self.hashtag_id = showVideosAgainstHashtag.msg?.hashtag.id.toString() ?? ""
                        } else {
                            if let newMessages = showVideosAgainstHashtag.msg?.hashtag.videos {
                                self.viewModel.showVideosAgainstHashtag?.msg?.hashtag.videos.append(contentsOf: newMessages)
                                self.showVideosAgainstHashtag?.msg?.hashtag.videos.append(contentsOf: newMessages)
                            }
                        }
                        
                    } else if showVideosAgainstHashtag.code == 201 {
                        if self.startPoint == 0 {
                            self.hashtagView.hideSkeleton()
                            self.hashtagCollectionView.hideSkeleton()
                            self.showVideosAgainstHashtag?.msg?.hashtag.videos.removeAll()
                            self.hashtagCollectionView.reloadData()
                        } else {
                            self.isNextPageLoad = false
                        }
                    }

                    self.isNextPageLoad = (self.showVideosAgainstHashtag?.msg?.hashtag.videos.count ?? 0) >= 10
                    self.hashtagCollectionView.reloadData()
                    self.hashtagView.hideSkeleton()
                    self.hashtagCollectionView.hideSkeleton()
                }

            case .newAddHashtagFavourite:
                break

            case .newShowVideosAgainstLocation:
                break
            }
        }
    }
}

extension HashtagViewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging")
        if isNextPageLoad == true {
            footerView.stopAnimating()
            isDataLoading = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        footerView.stopAnimating()
    }

    //
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
        if scrollView == self.scrollView {
            if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height {
                if isNextPageLoad == true {
                    if !isDataLoading {
                        isDataLoading = true
                        footerView.startAnimating()
                        startPoint += 1
                        initViewModel(startPoint: startPoint)
                    }
                }
            }
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height {
            if isNextPageLoad == true {
                footerView.hidesWhenStopped = true
                footerView.stopAnimating()
            }
        }
    }
}

extension HashtagViewController: ZoomTransitionAnimatorDelegate {
    func transitionWillStart() {
        guard let lastSelected = self.lastSelectedIndexPath else { return }
        self.hashtagCollectionView.cellForItem(at: lastSelected)?.isHidden = true
    }

    func transitionDidEnd() {
        guard let lastSelected = self.lastSelectedIndexPath else { return }
        self.hashtagCollectionView.cellForItem(at: lastSelected)?.isHidden = false
    }

    func referenceImage() -> UIImage? {
        guard
            let lastSelected = self.lastSelectedIndexPath,
            let cell = self.hashtagCollectionView.cellForItem(at: lastSelected) as? VideoProfileCollectionViewCell
        else {
            return nil
        }

        return cell.videoView.image
    }

    func imageFrame() -> CGRect? {
        guard
            let lastSelected = self.lastSelectedIndexPath,
            let cell = self.hashtagCollectionView.cellForItem(at: lastSelected) as? VideoProfileCollectionViewCell
        
        else {
            return self.view.frame
        }
        
        return FrameHelper.getTargerFrame(originalView: cell.videoView, targetView: self.view)  ?? self.view.frame



    }
}
