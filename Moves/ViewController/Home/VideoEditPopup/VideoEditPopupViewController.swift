//
//  VideoEditPopupViewController.swift
// //
//
//  Created by Wasiq Tayyab on 23/07/2024.
//

import UIKit

class VideoEditPopupViewController: UIViewController {
    
    var viewModel = ProfileViewModel()
    var categoryArr = [["menu": "Edit Video","image":"ic_edit_video 1"],
                       ["menu": "Delete Video","image":"ic_delete 1"],
                       ["menu": "Repost", "image": ""]]
    var callback: ((_ test: Bool) -> Void)?
    var videoID = 0
    var repost = 0
    var repostHandler: ((Int, IndexPath)->())?
    var indexPath: IndexPath?
    var objVideo:HomeResponseMsg?
    private lazy var loader: UIView = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("Unable to access key window")
        }
        return Utility.shared.createActivityIndicator(keyWindow)
    }()
    
    @IBOutlet weak var videoEditCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("thum",self.objVideo?.video?.thum)
//        print("thumSmall",self.objVideo?.video?.thumSmall)
        print("default_thumbnail",self.objVideo?.video?.default_thumbnail)
        
        if repost == 0 {
            categoryArr[2]["image"] = "repost"
        }else {
            categoryArr[2]["image"] = "reposted"
        }
        
        videoEditCollectionView.delegate = self
        videoEditCollectionView.dataSource = self
        videoEditCollectionView.register(UINib(nibName: "VideoEditPopupCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VideoEditPopupCollectionViewCell")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == self.view {
                callback?(true)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

}

extension VideoEditPopupViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoEditPopupCollectionViewCell", for: indexPath)as! VideoEditPopupCollectionViewCell
        cell.imgVideoEdit.image = UIImage(named: categoryArr[indexPath.row]["image"] ?? "")
        cell.lblVideoEdit.text = categoryArr[indexPath.row]["menu"]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 5.1, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            print("Edit Video")
            
            let vc = PostVideoViewController(nibName: "PostVideoViewController", bundle: nil)
            vc.objVideo =  self.objVideo
            vc.isEditVideo = true
            let nav = UINavigationController(rootViewController: vc)
            nav.isNavigationBarHidden =  true
            nav.modalPresentationStyle = .overFullScreen
            self.present(nav, animated: true, completion: nil)
            
        }else if indexPath.row == 1{
            self.loader.isHidden = false
            let deleteVideo = DeleteVideoRequest(videoId: videoID)
            viewModel.deleteVideo(parameters: deleteVideo)
            self.observeEvent()
        }else {
            self.dismiss(animated: true)
            repostHandler?(self.videoID ?? 0,indexPath)
        }
    }
    
    func observeEvent() {
        viewModel.eventHandler = { [weak self] event in
            guard let self else { return }
            
            switch event {
            case .error(let error):
                print("error",error)
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
            
            case .newShowUserDetail(showUserDetail: let showUserDetail):
                print("showUserDetail")
            case .newShowVideosAgainstUserID(showVideosAgainstUserID: let showVideosAgainstUserID):
                print("newShowVideosAgainstUserID")
            case .newShowUserLikedVideos(showUserLikedVideos: let showUserLikedVideos):
                print("showUserLikedVideos")
            case .newShowFavouriteVideos(showFavouriteVideos: let showFavouriteVideos):
                print("showFavouriteVideos")
            case .newShowOtherUserDetail(showOtherUserDetail: let showOtherUserDetail):
                print("")
            case .newDeleteVideo(deleteVideo: let deleteVideo):
                DispatchQueue.main.async {
                    if deleteVideo.code == 200 {
                        self.callback?(false)
                        self.dismiss(animated: true, completion: nil)
                        self.loader.isHidden = true
                    }else {
                        self.callback?(false)
                        self.dismiss(animated: true, completion: nil)
                        self.loader.isHidden = true
                    }
                }
            case .newWithdrawRequest(withdrawRequest: let withdrawRequest):
                print("withdrawRequest")
            case .newShowPayout(showPayout: let showPayout):
                print("showPayout")
            case .newShowStoreTaggedVideos(showStoreTaggedVideos: let showStoreTaggedVideos):
                print("showStoreTaggedVideos")
            case .newShowPrivateVideosAgainstUserID(showPrivateVideosAgainstUserID: let showPrivateVideosAgainstUserID):
                print("showPrivateVideosAgainstUserID")
            case .showUserRepostedVideos(showUserRepostedVideos: let showUserRepostedVideos):
                print("showUserRepostedVideos")
            }
        }
    }

}

