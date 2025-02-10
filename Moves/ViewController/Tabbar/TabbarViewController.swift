//
//  TabbarViewController.swift
//  TIK TIK
//
//  Created by Junaid Kamoka on 24/04/2019.
//  Copyright © 2019 Junaid Kamoka. All rights reserved.
//

import UIKit
class TabbarViewController: UITabBarController,UITabBarControllerDelegate {

    var viewModel = ProfileViewModel()
    let tabBarSeperatorTopLine: CALayer = {
        let tabBarTopLine = CALayer()
        tabBarTopLine.backgroundColor = UIColor.black.withAlphaComponent(0.2).cgColor
        return tabBarTopLine
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataPersistence.shared.cacheLoad(urlString: UserDefaultsManager.shared.profileUser) { result in
            switch(result) {
            case .success(let imageData):
                self.updateTabBar(with: UIImage(data: imageData))
            case .failure(let error):
                print(error)
            }
        }
        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .black
        delegate = self
        handleSetUpViewControllers()
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: NSNotification.Name("changeProfile"), object: nil)
        
        tabBar.items?[4].selectedImage = UIImage(named: "profile")
        tabBar.items?[4].image = UIImage(named: "profile1")

        self.getUserDetail()
    }
    
    func getUserDetail() {
        if UserDefaultsManager.shared.user_id == "0" {
            tabBar.items?[4].selectedImage = UIImage(named: "profile")
            tabBar.items?[4].image = UIImage(named: "profile1")
        }else {
            let showUserDetail = ShowUserDetailRequest(authToken: UserDefaultsManager.shared.authToken)
            self.viewModel.showUserDetail(parameters: showUserDetail)
            DispatchQueue.main.async {
                self.observeEvent()
            }
        }
    }
    
    func observeEvent() {
        viewModel.eventHandler = { [weak self] event in
            guard let self else { return }
            switch event {
            case .error(let error):break
            case .newShowUserDetail(showUserDetail: let showUserDetail):
                print("showUserDetail")
                if showUserDetail.code == 200 {
                    DispatchQueue.main.async {
                        DataPersistence.shared.saveOrUpdateCoreData(data: showUserDetail, withId: "profile")
                        self.login(msg: showUserDetail.msg!)
                    }
                }
            case .newShowOtherUserDetail(showOtherUserDetail: let showOtherUserDetail): break
            case .newShowVideosAgainstUserID(showVideosAgainstUserID: let showVideosAgainstUserID): break
            case .newShowUserLikedVideos(showUserLikedVideos: let showUserLikedVideos): break
            case .newShowFavouriteVideos(showFavouriteVideos: let showFavouriteVideos): break
            case .newDeleteVideo(deleteVideo: let deleteVideo): break
            case .newWithdrawRequest(withdrawRequest: let withdrawRequest): break
            case .newShowPayout(showPayout: let showPayout): break
            case .newShowStoreTaggedVideos(showStoreTaggedVideos: let showStoreTaggedVideos): break
            case .newShowPrivateVideosAgainstUserID(showPrivateVideosAgainstUserID: let showPrivateVideosAgainstUserID): break
            case .showUserRepostedVideos(showUserRepostedVideos: let showUserRepostedVideos):break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func methodOfReceivedNotification(notification: NSNotification) {
        self.getUserDetail()
    }

//    private func setup() {
//        print(" UserDefaultsManager.shared.user_id", UserDefaultsManager.shared.user_id)
//        if UserDefaultsManager.shared.user_id == "0" {
//            tabBar.items?[4].selectedImage = UIImage(named: "profile")
//            tabBar.items?[4].image = UIImage(named: "profile1")
//        }else {
//            
////            if let profileUser = ConstantManager.profileUser{
////                ConstantManager.isNotification = true
////                self.tabBar.items?[3].badgeValue = String(unreadNotificationCount)
////            } else {
////                self.tabBar.items?[3].badgeValue = nil
////            }
//
//            if let message = ConstantManager.profileUser?.msg {
//                self.login(msg: message)
//            }
//        }
//    }
    private func login(msg: ProfileResponseMsg) {
        UserDefaultsManager.shared.wallet = msg.user?.wallet?.stringValue ?? ""
        UserDefaultsManager.shared.business = msg.user?.business?.toString() ?? ""

        let user = msg.user
        let imageURLString: String
        let defaultImage = UIImage(named: "profile")
        
        imageURLString = user?.profilePic ?? ""
        
        UserDefaultsManager.shared.profileUser = imageURLString
        
        DataPersistence.shared.cacheLoad(urlString: imageURLString) { result in
            switch(result) {
            case .success(let imageData):
                self.updateTabBar(with: UIImage(data: imageData))
            case .failure(let error):
                print(error)
            }
        }

    }

    private func updateTabBar(with image: UIImage?) {
        guard let tabBarItem = tabBar.items?[4] else {
            print("Failed to get tab bar item")
            return
        }
        
        let defaultImage = UIImage(named: "profile")
        let finalImage = image ?? defaultImage
        
//        guard let referenceIcon = tabBarItem.image else {
//            print("Failed to get reference tab bar icon size")
//            return
//        }
        
        let referenceSize = CGSize(width: 25, height: 25) //referenceIcon.size
        let resizedImage = finalImage?.resized(to: referenceSize)
        let circularImage = resizedImage?.roundedImageWithBorder(width: 1.0, color: .black)
//        let circularImage = finalImage?.roundedImageWithBorder(width: 1.0, color: .black)

        tabBarItem.selectedImage = circularImage?.withRenderingMode(.alwaysOriginal)
        tabBarItem.image = circularImage?.withRenderingMode(.alwaysOriginal)
    }


    func handleSetUpViewControllers() {
        tabBarSeperatorTopLine.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 0.5)
        tabBar.layer.addSublayer(tabBarSeperatorTopLine)
        tabBar.clipsToBounds = true
    }
    
    //MARK: - Tabbar Delegates
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let midtabbar : UITabBarItem = self.tabBar.items![2] as UITabBarItem
        
        let index = -(tabBar.items?.firstIndex(of: item)?.distance(to: 0))!
        item.tag = index
        print("index",index)
        if index == 1 {
            tabBar.isTranslucent = true
            tabBar.barTintColor = .white
            
            tabBar.tintColor = .black
            tabBar.unselectedItemTintColor = .black
        }
        
    }
    
    
    // Tabbar delegate Method
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController == tabBarController.viewControllers?[3] {
            let userID = UserDefaultsManager.shared.user_id
            
            if userID != "0" {
                return true
            } else {
                newLoginScreenAppear()
                return false
            }
        } else if viewController == tabBarController.viewControllers?[4] {
            hidesBottomBarWhenPushed = false
            let userID = UserDefaultsManager.shared.user_id
            
            if userID != "0" {
                return true
            } else {
                newLoginScreenAppear()
                return false
            }
        } else if viewController == tabBarController.viewControllers?[2] {
            hidesBottomBarWhenPushed = false
            let userID = UserDefaultsManager.shared.user_id
            
            if userID != "0" {
                UserDefaultsManager.shared.sound_name = ""
                UserDefaultsManager.shared.sound_url = ""
                UserDefaultsManager.shared.sound_id = ""
                
                
                let vc1 = RecordPopupViewController(nibName: "RecordPopupViewController", bundle: nil)
                let nav = UINavigationController(rootViewController: vc1)
                nav.isNavigationBarHidden =  true
                nav.modalPresentationStyle = .overFullScreen
                self.present(nav, animated: true, completion: nil)
                return false
            } else {
                newLoginScreenAppear()
                return false
            }
        } else {
            hidesBottomBarWhenPushed = false
            return true
        }
    }
    
    private
    
    func newLoginScreenAppear(){
        NotificationCenter.default.post(name: .stopVideo, object: nil)

        let myViewController = SignUpViewController(nibName: "SignUpViewController", bundle: nil)
        let navController = UINavigationController.init(rootViewController: myViewController)
        navController.navigationBar.isHidden = true
        navController.modalPresentationStyle = .overFullScreen
        self.present(navController, animated: false, completion: nil)
    }
}
