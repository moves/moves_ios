//
//  PrivacyPolicyViewController.swift
// //
//
//  Created by iMac on 15/06/2024.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {
    
    var directMessagedarray = ["Everyone","Friends","No One"]
    var videolikearray = ["Everyone","Only Me"]
    var commentarray =  ["Everyone","Friends","No One"]
    var viewModel = ProfileViewModel()
    var viewModel1 = PrivacyPolicyViewModel()
    var firstOption = ""
    var secondOption = ""
    var thirdOption = ""
    
    private lazy var loader: UIView = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("Unable to access key window")
        }
        return Utility.shared.createActivityIndicator(keyWindow)
    }()

    @IBOutlet weak var btnMessage: UIButton!
    @IBOutlet weak var btnLikeVideo: UIButton!
    @IBOutlet weak var commentVideo: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loader.isHidden = false
        let showUserDetail = ShowUserDetailRequest(authToken: UserDefaultsManager.shared.authToken)
        viewModel.showUserDetail(parameters: showUserDetail)
        
        self.observeEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func privacyButtonPressed(_ sender: UIButton) {
        let newViewController = PostStatusViewController(nibName: "PostStatusViewController", bundle: nil)
        newViewController.hidesBottomBarWhenPushed = true
        newViewController.modalPresentationStyle = .overFullScreen
        if sender.tag == 0 {
            newViewController.status = "message"
            newViewController.selected = firstOption
            newViewController.lbl = "Select Message Option"
            newViewController.mainArr = directMessagedarray
        }else if sender.tag == 1 {
            newViewController.status = "like"
            newViewController.selected = secondOption
            newViewController.lbl = "Select Like Video Option"
            newViewController.mainArr = videolikearray
        }else {
            newViewController.status = "comment"
            newViewController.selected = thirdOption
            newViewController.lbl = "Select Comment Option"
            newViewController.mainArr = videolikearray
        }
        newViewController.callback = { (str, status) -> Void in
                    print("callback")
            if status == "message" {
                self.firstOption = str
            }else if status == "like"{
                self.secondOption = str
            }else {
                self.thirdOption = str
            }
            
            self.loader.isHidden = false
            let privacy = AddPrivacySettingRequest(authToken: UserDefaultsManager.shared.authToken, videosDownload: nil, directMessage: self.firstOption, duet: nil, likedVideos: self.secondOption, videoComment: self.thirdOption, orderHistory: nil)
            self.viewModel1.addPrivacySetting(parameters: privacy)
            self.observeEvent1()
        }
        self.navigationController?.present(newViewController, animated: false)
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
                if showUserDetail.code == 200 {
                    DispatchQueue.main.async {
                        self.thirdOption = showUserDetail.msg?.privacySetting?.videoComment?.stringValue?.capitalized ?? ""
                        self.commentVideo.setTitle(showUserDetail.msg?.privacySetting?.videoComment?.stringValue?.capitalized, for: .normal)
                        
                        self.secondOption = showUserDetail.msg?.privacySetting?.likedVideos?.stringValue?.capitalized ?? ""
                        self.btnLikeVideo.setTitle(showUserDetail.msg?.privacySetting?.likedVideos?.stringValue?.capitalized, for: .normal)
                        
                        self.firstOption = showUserDetail.msg?.privacySetting?.directMessage?.stringValue?.capitalized ?? ""
                        self.btnMessage.setTitle(showUserDetail.msg?.privacySetting?.directMessage?.stringValue?.capitalized, for: .normal)
                        self.loader.isHidden = true
                    }
                }
            case .newShowVideosAgainstUserID(showVideosAgainstUserID: let showVideosAgainstUserID):
              print("showVideosAgainstUserID")
            case .newShowUserLikedVideos(showUserLikedVideos: let showUserLikedVideos):
                print("showUserLikedVideos")
            case .newShowFavouriteVideos(showFavouriteVideos: let showFavouriteVideos):
                print("showTaggedVideosAgainstUserID")
            case .newShowOtherUserDetail(showOtherUserDetail: let showOtherUserDetail):
                print("showOtherUserDetail")
            case .newDeleteVideo(deleteVideo: let deleteVideo):
                print("deleteVideo")
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
    
    func observeEvent1() {
        viewModel1.eventHandler = { [weak self] event in
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
            case .newAddPrivacySetting(addPrivacySetting: let addPrivacySetting):
                if addPrivacySetting.code == 200 {
                    DispatchQueue.main.async {
                       
                        Utility.showMessage(message: "Privacy Setting Updated", on: self.view)
                        self.loader.isHidden = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                   
                }
            }
        }
    }
    
}
