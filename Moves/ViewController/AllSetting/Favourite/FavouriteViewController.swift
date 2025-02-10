//
//  FavouriteViewController.swift
// //
//
//  Created by Wasiq Tayyab on 27/06/2024.
//

import UIKit
import SkeletonView
import SDWebImage
import ZoomingTransition
class FavouriteViewController: ZoomingPushVC {
    var lastSelectedIndexPath: IndexPath? = nil
    private let footerView = UIActivityIndicatorView(style: .medium)
    private var startPoint = 0
    var currentIndexPath = IndexPath(item: 0, section: 0)
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.appColor(.theme)
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        
        return refreshControl
    }()
    var showFavouriteVideos: HomeResponse?
    var isDataLoading:Bool = false
    private var viewModel = BlockUserViewModel()
    var isNextPageLoad = false
    
    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var favourtieCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.favourtieCollectionView.showAnimatedGradientSkeleton()
        self.configuration()
    }
    
    
    func hideSkeleton() {
        favourtieCollectionView.hideSkeleton(transition: .crossDissolve(transitionDurationStepper))
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

extension FavouriteViewController: SkeletonCollectionViewDelegate, UICollectionViewDelegateFlowLayout, SkeletonCollectionViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        return "VideoProfileCollectionViewCell"
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showFavouriteVideos?.msg?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoProfileCollectionViewCell", for: indexPath) as! VideoProfileCollectionViewCell
        let video = showFavouriteVideos?.msg?[indexPath.row].video
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
            let video = showFavouriteVideos?.msg?[indexPath.row].video
            if let thum = video?.thum, let url = URL(string: thum) {
                SDWebImagePrefetcher.shared.prefetchURLs([url])
            }
        }
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
        videoDetail.dataSource = showFavouriteVideos?.msg ?? []
        videoDetail.index = indexPath.row
        videoDetail.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(videoDetail, animated: true)
    }
}

extension FavouriteViewController {
    
    func configuration() {
        favourtieCollectionView.delegate = self
        favourtieCollectionView.dataSource = self
        favourtieCollectionView.register(UINib(nibName: "VideoProfileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VideoProfileCollectionViewCell")
        favourtieCollectionView.register(CollectionViewFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        (favourtieCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: favourtieCollectionView.bounds.width, height: 50)
        
        favourtieCollectionView.prepareSkeleton { [weak self] (done) in
            if let visibleCells = self?.favourtieCollectionView.visibleCells {
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
       
        footerView.color = UIColor(named: "theme")
        footerView.hidesWhenStopped = true
        
        if #available(iOS 11.0, *) {
            favourtieCollectionView.refreshControl = refresher
        } else {
            favourtieCollectionView.addSubview(refresher)
        }
        initViewModel(startingPoint: startPoint)
    }
    
    func initViewModel(startingPoint:Int) {
        let showFavouriteVideos = FriendsRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: startingPoint, otherUserId: "")
        viewModel.showFavouriteVideos(parameters: showFavouriteVideos)
        observeEvent()
    }
    
    func observeEvent() {
        viewModel.eventHandler = { [weak self] event in
            guard let self else { return }
            
            switch event {
            case .error(let error):
                print("error",error ?? "")
                DispatchQueue.main.async {
                      if let urlError = error as? URLError, urlError.code == .badServerResponse {
                        Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                      } else {
                          if isDebug == true {
                              Utility.showMessage(message: "Something went wrong. Please try again", on: self.view)
                          }}
                }
            case .newShowBlockedUsers(showBlockedUsers: let showBlockedUsers):
               print("showBlockedUsers")
            case .newBlockUser(blockUser: let blockUser):
                print("showBlockedUsers")
            case .newShowFavouriteVideos(showFavouriteVideos: let showFavouriteVideos):
                if showFavouriteVideos.code == 200 {
                    if startPoint == 0 {
                        viewModel.showFavouriteVideos?.msg?.removeAll()
                        self.showFavouriteVideos?.msg?.removeAll()
                        viewModel.showFavouriteVideos = showFavouriteVideos
                        self.showFavouriteVideos = showFavouriteVideos
                    } else {
                        if let newMessages = showFavouriteVideos.msg {
                            viewModel.showFavouriteVideos?.msg?.append(contentsOf: newMessages)
                            self.showFavouriteVideos?.msg?.append(contentsOf: newMessages)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        if (self.showFavouriteVideos?.msg?.count ?? 0) >= 10 {
                            self.isNextPageLoad = true
                        }else {
                            self.isNextPageLoad = false
                        }
                        self.favourtieCollectionView.hideSkeleton()
                        self.favourtieCollectionView.reloadData()
                    }
                }else {
                    if startPoint == 0 {
                        self.showFavouriteVideos?.msg?.removeAll()
                        DispatchQueue.main.async {
                            self.favourtieCollectionView.reloadData()
                        }
                    }else {
                        DispatchQueue.main.async {
                            self.isNextPageLoad = false
                        }
                    }
                }
            }
        }
    }

}

extension FavouriteViewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        print("scrollViewWillBeginDragging")
        if isNextPageLoad == true {
            self.footerView.stopAnimating()
            isDataLoading = false
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        self.footerView.stopAnimating()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

        print("scrollViewDidEndDragging")
        if scrollView == self.favourtieCollectionView{
            if ((favourtieCollectionView.contentOffset.y + favourtieCollectionView.frame.size.height) >= favourtieCollectionView.contentSize.height)
            {
                if isNextPageLoad == true {
                    if !isDataLoading{
                        isDataLoading = true
                        footerView.startAnimating()
                        startPoint += 1
                        initViewModel(startingPoint: startPoint)
                    }
                }
            }
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (favourtieCollectionView.contentOffset.y + favourtieCollectionView.frame.size.height) >= favourtieCollectionView.contentSize.height {
            if isNextPageLoad == true {
                self.footerView.hidesWhenStopped = true
                self.footerView.stopAnimating()
            }
        }
    }
}

extension FavouriteViewController: ZoomTransitionAnimatorDelegate {
    func transitionWillStart() {
        guard let lastSelected = self.lastSelectedIndexPath else { return }
        self.favourtieCollectionView.cellForItem(at: lastSelected)?.isHidden = true
    }

    func transitionDidEnd() {
        guard let lastSelected = self.lastSelectedIndexPath else { return }
        self.favourtieCollectionView.cellForItem(at: lastSelected)?.isHidden = false
    }

    func referenceImage() -> UIImage? {
        guard
            let lastSelected = self.lastSelectedIndexPath,
            let cell = self.favourtieCollectionView.cellForItem(at: lastSelected) as? VideoProfileCollectionViewCell
        else {
            return nil
        }

        return cell.videoView.image
    }

    func imageFrame() -> CGRect? {
        guard
            let lastSelected = self.lastSelectedIndexPath,
            let cell = self.favourtieCollectionView.cellForItem(at: lastSelected) as? VideoProfileCollectionViewCell
        
        else {
            return self.view.frame
        }
        
        return FrameHelper.getTargerFrame(originalView: cell.videoView, targetView: self.view)  ?? self.view.frame



    }
}
