//
//  LocationDetailViewController.swift
// //
//
//  Created by iMac on 15/06/2024.
//

import GoogleMaps
import SkeletonView
import UIKit
import ZoomingTransition
import SDWebImage
class LocationDetailViewController: ZoomingPushVC, SkeletonCollectionViewDelegate, UICollectionViewDelegateFlowLayout, SkeletonCollectionViewDataSource, UIScrollViewDelegate, GMSMapViewDelegate {
    // MARK: - Properties
    var lastSelectedIndexPath: IndexPath? = nil
    var nearby: HomeResponse?
    var location_string = ""
    var location_title = ""
    var id = 0
    var lat = ""
    var long = ""
    let viewModel = HashtagVideoViewModel()
    var startPoint = 0
    private let footerView = UIActivityIndicatorView(style: .medium)
    var isDataLoading: Bool = false
    var isNextPageLoad = false
    var locationManager: CLLocationManager!
    private var mapView: GMSMapView!
    private let mapZoomLevel: Float = 12.0
    
    // MARK: - IBOutlets

    @IBOutlet var mapView1: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var lblLocation: UILabel!
    @IBOutlet var locationCollectionView: UICollectionView!
    @IBOutlet var lblHeader: UILabel!
    
    @IBOutlet var locationView: UIView!
    
    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationCollectionView.showAnimatedGradientSkeleton()
        setupGoogleMap()
        scrollView.delegate = self
        configuration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Setup Methods

    private func setupGoogleMap() {
        let latitude = lat.toDouble() ?? 0.0
        let longitude = long.toDouble() ?? 0.0
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: mapZoomLevel)
        
        // Initialize mapView after mapView1 is loaded
        mapView = GMSMapView.map(withFrame: mapView1.bounds, camera: camera)
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView1.addSubview(mapView)
        
        // Set constraints for mapView within mapView1
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: mapView1.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: mapView1.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: mapView1.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: mapView1.bottomAnchor)
        ])
        
        let mapCenter = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let marker = GMSMarker(position: mapCenter)
        marker.icon = UIImage(named: "custom_pin.png")
        marker.map = mapView
    }
    
    private func configuration() {
        lblLocation.text = location_string
        lblHeader.text = location_title
        
        setupCollectionView()
        initViewModel(startingPoint: startPoint)
    }
    
    private func setupCollectionView() {
        locationCollectionView.delegate = self
        locationCollectionView.dataSource = self
        locationCollectionView.register(UINib(nibName: "VideoProfileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VideoProfileCollectionViewCell")
        locationCollectionView.register(CollectionViewFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        (locationCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: locationCollectionView.bounds.width, height: 50)
        
        locationCollectionView.prepareSkeleton { [weak self] _ in
            if let visibleCells = self?.locationCollectionView.visibleCells {
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
    }
    
    // MARK: - ViewModel Methods

    private func initViewModel(startingPoint: Int) {
        let nearby = ShowVideosAgainstLocationRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: startingPoint, id: id)
        viewModel.showVideosAgainstLocation(parameters: nearby)
        observeEvent()
    }
    
    private func observeEvent() {
        viewModel.eventHandler = { [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .error(let error):
                print("handleError:", error?.localizedDescription ?? "Unknown error")
                
                DispatchQueue.main.async {
                    if let dataError = error as? Moves.DataError {
                        switch dataError {
                        case .invalidResponse:
                            Utility.showMessage(message: "Unstable Network. Please try again", on: self.view)
                        default:
                            Utility.showMessage(message: "Something went wrong. Please try again", on: self.view)
                        }
                    } else {
                        Utility.showMessage(message: "Something went wrong. Please try again", on: self.view)
                    }
                }
                
            case .newShowVideosAgainstHashtag:
                break
                
            case .newAddHashtagFavourite:
                break
                
            case .newShowVideosAgainstLocation(let showVideosAgainstLocation):
                DispatchQueue.main.async {
                    self.locationCollectionView.hideSkeleton()
                    if showVideosAgainstLocation.code == 200 {
                        if self.startPoint == 0 {
                            self.viewModel.nearby = showVideosAgainstLocation
                            self.nearby = showVideosAgainstLocation
                        } else if let newMessages = showVideosAgainstLocation.msg {
                            self.viewModel.nearby?.msg?.append(contentsOf: newMessages)
                            self.nearby?.msg?.append(contentsOf: newMessages)
                        }
                        
                        self.isNextPageLoad = (self.nearby?.msg?.count ?? 0) >= 10
                        self.locationCollectionView.reloadData()
                        
                    } else if showVideosAgainstLocation.code == 201 {
                        if self.startPoint == 0 {
                            self.nearby?.msg?.removeAll()
                            self.locationCollectionView.reloadData()
                        } else {
                            self.isNextPageLoad = false
                        }
                    }
                }
            }
        }
    }


    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nearby?.msg?.count ?? 0
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "VideoProfileCollectionViewCell"
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoProfileCollectionViewCell", for: indexPath) as! VideoProfileCollectionViewCell
        let video = nearby?.msg?[indexPath.row].video
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
            let video = nearby?.msg?[indexPath.row].video
            if let thum = video?.thum, let url = URL(string: thum) {
                SDWebImagePrefetcher.shared.prefetchURLs([url])
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3 - 1, height: 230)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.lastSelectedIndexPath = indexPath
        let videoDetail = VideoDetailController()
        videoDetail.dataSource = nearby?.msg ?? []
        videoDetail.index = indexPath.row
        videoDetail.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(videoDetail, animated: true)

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
    
    // MARK: - UIScrollViewDelegate

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

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
        if scrollView == self.scrollView {
            if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height {
                if isNextPageLoad == true {
                    if !isDataLoading {
                        isDataLoading = true
                        footerView.startAnimating()
                        startPoint += 1
                        initViewModel(startingPoint: startPoint)
                    }
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height {
            if isNextPageLoad == true {
                footerView.hidesWhenStopped = true
                footerView.stopAnimating()
            }
        }
    }
    
    // MARK: - IBActions

    @IBAction func backButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func currentLocationButtonPressed(_ sender: UIButton) {
        handleCurrentLocation()
    }
    
    private func handleCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Request location authorization
        locationManager.requestWhenInUseAuthorization()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationDetailViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        } else {
            Utility.showMessage(message: "Location authorization denied. Please enable it in settings", on: view)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15)
        mapView?.animate(to: camera)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error)")
    }
}
extension LocationDetailViewController: ZoomTransitionAnimatorDelegate {
    func transitionWillStart() {
        guard let lastSelected = self.lastSelectedIndexPath else { return }
        self.locationCollectionView.cellForItem(at: lastSelected)?.isHidden = true
    }

    func transitionDidEnd() {
        guard let lastSelected = self.lastSelectedIndexPath else { return }
        self.locationCollectionView.cellForItem(at: lastSelected)?.isHidden = false
    }

    func referenceImage() -> UIImage? {
        guard
            let lastSelected = self.lastSelectedIndexPath,
            let cell = self.locationCollectionView.cellForItem(at: lastSelected) as? VideoProfileCollectionViewCell
        else {
            return nil
        }

        return cell.videoView.image
    }

    func imageFrame() -> CGRect? {
        guard
            let lastSelected = self.lastSelectedIndexPath,
            let cell = self.locationCollectionView.cellForItem(at: lastSelected) as? VideoProfileCollectionViewCell
        
        else {
            return self.view.frame
        }
        
        return FrameHelper.getTargerFrame(originalView: cell.videoView, targetView: self.view)  ?? self.view.frame



    }
}

