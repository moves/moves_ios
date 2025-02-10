//
//  SeatchViewController.swift
// //
//
//  Created by Wasiq Tayyab on 15/06/2024.
//

import UIKit
import SkeletonView
import ZoomingTransition

class SearchViewController: UIViewController, UITableViewDelegate, SkeletonTableViewDataSource {
    
    // MARK: - Variables
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.appColor(.theme)
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        return refreshControl
    }()
    let viewModel = DiscoverViewModel()
    var index = 0
    var startPoint = 0
    var isDataLoading: Bool = false
    let spinner = UIActivityIndicatorView(style: .white)
    
    // MARK: - Outlets
    @IBOutlet weak var discoverTblView: UITableView!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialViewState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    

    // MARK: - Setup Methods
    private func setupInitialViewState() {
        self.setupTableView()
        if let fetchedData: DiscoverResponse = DataPersistence.shared.fetchFromCoreData(withId: "discover") {
            print("fetchedData",fetchedData)
            viewModel.hashtagVideo?.msg?.removeAll()
            viewModel.hashtagVideo = fetchedData
            self.discoverTblView.reloadData()
        } else {
            print("No data found for the given ID.")
            self.configuration()
            self.view.showAnimatedGradientSkeleton()
            discoverTblView.showAnimatedGradientSkeleton()
        }        
    }
    
    
    
    private func setupNavigationBar() {
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
        if #available(iOS 10.0, *) {
            discoverTblView.refreshControl = refresher
        } else {
            discoverTblView.addSubview(refresher)
        }
    }
    
    private func setupTableView() {
        discoverTblView.delegate = self
        discoverTblView.dataSource = self
        discoverTblView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchTableViewCell")
        discoverTblView.rowHeight = 190
        spinner.color = UIColor(named: "theme")
        spinner.hidesWhenStopped = true
        discoverTblView.tableFooterView = spinner
    }
    
    private func configuration() {
        initViewModel(startingPoint: startPoint)
    }
    
    // MARK: - ViewModel Methods
    private func initViewModel(startingPoint: Int) {
        self.startPoint = startingPoint
        let hashtag = DiscoverRequest(userId: UserDefaultsManager.shared.user_id, countryId: UserDefaultsManager.shared.country_id, startingPoint: startPoint)
        viewModel.getVideosData(parameters: hashtag)
        print("hashtag",hashtag)
        observeEvent()
    }
    
    private func observeEvent() {
        viewModel.eventHandler = { [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .error(let error):
                self.handleError(error)
                
            case .newShowDiscoverySections(let showDiscoverySections):
                DataPersistence.shared.saveToCoreData(data: showDiscoverySections, withId: "discover")
                self.handleNewDiscoverySections(showDiscoverySections)
            }
        }
    }
    
    private func handleError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error as? Moves.DataError {
                Utility.showMessage(message: error.localizedDescription, on: self.view)
            } else {
                Utility.showMessage(message: "Something went wrong. Please try again", on: self.view)
            }
            self.stopLoading()
        }
    }
    
    private func handleNewDiscoverySections(_ showDiscoverySections: DiscoverResponse) {
        DispatchQueue.main.async {
            if self.startPoint == 0 {
                self.viewModel.hashtagVideo = showDiscoverySections
            } else {
                self.viewModel.hashtagVideo?.msg?.append(contentsOf: showDiscoverySections.msg ?? [])
            }
            self.stopLoading()
            self.discoverTblView.reloadData()
        }
    }
    
    // MARK: - Helper Methods
    private func stopLoading() {
        self.view.hideSkeleton()
        self.discoverTblView.hideSkeleton()
        self.spinner.stopAnimating()
        self.isDataLoading = false
    }
    
    // MARK: - TableView DataSource and Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.hashtagVideo?.msg?.count ?? 0
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "SearchTableViewCell"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") as! SearchTableViewCell
        let hashObj = viewModel.hashtagVideo?.msg?[indexPath.row].hashtag
       
        
        
        cell.hashName.text = hashObj?.name
        cell.hashNameSub.text = "Trending Hashtags"
        cell.index = indexPath.row
        cell.lblVideoCount.text = "\(hashObj?.videosCount.toString() ?? "") Posts"
        cell.videoObj = hashObj?.videos ?? []
        cell.hashTagIndexPath = indexPath
        index = indexPath.row
        
        cell.btnPost.addTarget(self, action: #selector(postButtonPressed(_:)), for: .touchUpInside)
        cell.btnPost.tag = indexPath.row
        
        cell.hashtagClickHandler = { [weak self] indexPath,hashtag in
            guard let self = self else {
                return
            }
            let vc = HashtagViewController(nibName: "HashtagViewController", bundle: nil)
            vc.hashtag = hashtag
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        cell.videoClickHandler = { [weak self] indexPath, videoObj in
            guard let self = self else {
                return
            }
            
            let videoDetail = VideoDetailController()
            videoDetail.dataSource = videoObj
            videoDetail.index = indexPath.row
            videoDetail.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(videoDetail, animated: true)
        }
        
        cell.discoverCollectionView.reloadData()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let hashObj = viewModel.hashtagVideo?.msg?[indexPath.row].hashtag
        navigateToHashtagViewController(with: hashObj?.name ?? "")
    }
    
    @objc func postButtonPressed(_ sender: UIButton) {
        let hashObj = viewModel.hashtagVideo?.msg?[sender.tag].hashtag
        navigateToHashtagViewController(with: hashObj?.name ?? "")
    }
    
    private func navigateToHashtagViewController(with hashtag: String) {
        let vc = HashtagViewController(nibName: "HashtagViewController", bundle: nil)
        vc.hashtag = hashtag
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - ScrollView Delegate Methods
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopSpinnerIfNeeded()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        stopSpinnerIfNeeded()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            stopSpinnerIfNeeded()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let tableView = scrollView as? UITableView else { return }
        
        let contentOffsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        // Check if we are close to the bottom
        if contentOffsetY + frameHeight > contentHeight - 100 {
            if !isDataLoading {
                loadMoreData()
            }
        }
    }
    
    private func loadMoreData() {
        isDataLoading = true
        spinner.startAnimating()
        startPoint += 1
        initViewModel(startingPoint: startPoint)
    }
    
    private func stopSpinnerIfNeeded() {
        if !isDataLoading {
            spinner.stopAnimating()
            isDataLoading = false
        }
    }
    
    // MARK: - Button Actions
    @objc func requestData() {
        startPoint = 0
        initViewModel(startingPoint: startPoint)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
            self.refresher.endRefreshing()
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        self.view.hideSkeleton()
        self.discoverTblView.hideSkeleton()
        let searchVC = SearchUserViewController(nibName: "SearchUserViewController", bundle: nil)
        searchVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(searchVC, animated: false)
    }
}
