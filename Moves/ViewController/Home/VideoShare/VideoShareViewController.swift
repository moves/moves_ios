//
//  VideoShareViewController.swift
// //
//
//  Created by Wasiq Tayyab on 03/09/2024.
//

import UIKit

class VideoShareViewController: UIViewController {
    var categoryArr = [["menu": "Report", "image": "flag"],
                       ["menu": "Repost", "image": ""],
    /* ["menu": "Not Interested", "image": "notInterested"] */ ]
    
    var block = 0
    var profileId: Int = 0
    var videoId: Int?
    var repostHandler: ((Int, IndexPath)->())?
    
    var blockUser: ((Int)->())?
    var indexPath: IndexPath?
    var repost = 0
    

    
    private lazy var loader: UIView = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            fatalError("Unable to access key window")
        }
        return Utility.shared.createActivityIndicator(keyWindow)
    }()
    
    @IBOutlet var videoShareCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        print("profileId",profileId)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == view {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func setup() {
        print("repost",repost)
        
        if profileId == 0{
            if repost == 0 {
                categoryArr[1]["image"] = "repost"
            }else {
                categoryArr[1]["image"] = "reposted"
            }
        }else {
            if block == 0 {
                categoryArr[1]["image"] = "block1"
                categoryArr[1]["menu"] = "Block"
            }else {
                categoryArr[1]["image"] = "unblock"
                categoryArr[1]["menu"] = "Unblock"
            }
        }
        
        videoShareCollectionView.delegate = self
        videoShareCollectionView.dataSource = self
        videoShareCollectionView.register(UINib(nibName: "VideoEditPopupCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VideoEditPopupCollectionViewCell")
    }
    
    private func presentReportPopup(videoId: Int, profileId: Int) {
        let myViewController = ReportReasonViewController(nibName: "ReportReasonViewController", bundle: nil)
        myViewController.videoId = videoId.toString()
        myViewController.profileId = profileId.toString()
        myViewController.hidesBottomBarWhenPushed = true
        let nav = UINavigationController(rootViewController: myViewController)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .overFullScreen
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController
        {
            rootViewController.dismiss(animated: false) {
                rootViewController.present(nav, animated: true, completion: nil)
            }
        } else {
            navigationController?.present(nav, animated: true, completion: nil)
        }
    }
}

extension VideoShareViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoEditPopupCollectionViewCell", for: indexPath) as! VideoEditPopupCollectionViewCell
        cell.imgVideoEdit.image = UIImage(named: categoryArr[indexPath.row]["image"] ?? "")
        cell.lblVideoEdit.text = categoryArr[indexPath.row]["menu"]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 5.1, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            dismiss(animated: false) {
                if self.profileId == 0 {
                    self.presentReportPopup(videoId: self.videoId ?? 0, profileId: self.profileId)
                }else{
                    self.presentReportPopup(videoId: self.videoId ?? 0, profileId: self.profileId)
                }
            }
        }else {
            if profileId == 0 {
                self.dismiss(animated: true)
                repostHandler?(self.videoId ?? 0,indexPath)
            }else {
                self.dismiss(animated: true)
                if block == 0 {
                    blockUser?(1)
                }else {
                    blockUser?(0)
                }
            }
        }
    }
}
