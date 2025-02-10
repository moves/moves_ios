//
//  ManageAccountViewController.swift
// //
//
//  Created by Wasiq Tayyab on 26/06/2024.
//

import UIKit

class ManageAccountViewController: UIViewController {

    var arr: [String] = []
    var profileResponse : ProfileResponse?
    var viewModel = ProfileViewModel()
    
    @IBOutlet weak var tblConstant: NSLayoutConstraint!
    @IBOutlet weak var manageAccountTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        manageAccountTableView.delegate = self
        manageAccountTableView.dataSource = self
        manageAccountTableView.register(UINib(nibName: "ManageAccountTableViewCell", bundle: nil), forCellReuseIdentifier: "ManageAccountTableViewCell")
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: NSNotification.Name("changeNumber"), object: nil)
    }
    
    
    
    @objc func methodOfReceivedNotification(notification: NSNotification) {
        let showUserDetail = ShowUserDetailRequest(authToken: UserDefaultsManager.shared.authToken)
        viewModel.showUserDetail(parameters: showUserDetail)
        self.observeEvent()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
        if profileResponse?.msg?.user?.social == "phone" {
            tblConstant.constant =  120
            arr = ["Phone"]
        }else if profileResponse?.msg?.user?.social == "email"{
            tblConstant.constant =  160
            arr = ["Email", "Password"]
        }else {
            tblConstant.constant =  40
            arr.removeAll()
        }
        
    }
   
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let newViewController = DeleteAccountViewController(nibName: "DeleteAccountViewController", bundle: nil)
        newViewController.profileResponse = self.profileResponse
        newViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
}

extension ManageAccountViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if profileResponse?.msg?.user?.social == "google" || profileResponse?.msg?.user?.social == "apple" || profileResponse?.msg?.user?.social == "facebook" {
            return 1
        }else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if profileResponse?.msg?.user?.social == "google" || profileResponse?.msg?.user?.social == "apple" || profileResponse?.msg?.user?.social == "facebook" { 
            return 0
        }else {
            if section == 0 {
                return arr.count ?? 0
            }else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ManageAccountTableViewCell", for: indexPath)as! ManageAccountTableViewCell
        cell.lblManageAccount.text = arr[indexPath.row]
        if indexPath.section == 0 {
            if arr.count == 1 {
                if indexPath.row == 0 {
                    cell.lblAccount.text = profileResponse?.msg?.user?.phone
                }
            }else {
                if indexPath.row == 0 {
                    cell.lblAccount.text = profileResponse?.msg?.user?.email
                }else {
                    cell.lblAccount.text = "● ● ● ● ● ● ● ●"
                }
            }
        }else {
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if profileResponse?.msg?.user?.social == "phone" {
                    let newViewController = ChangePhoneNoViewController(nibName: "ChangePhoneNoViewController", bundle: nil)
                    self.navigationController?.pushViewController(newViewController, animated: true)
                }else {
                    
                }
            }else {
                let newViewController = UpdatePasswordViewController(nibName: "UpdatePasswordViewController", bundle: nil)
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
        }else {
           
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 25))
        if #available(iOS 13.0, *) {
            headerView.backgroundColor = .white
        } else {
            headerView.backgroundColor =  .white
        }
      
        let label = UILabel()
        label.font = AppFont.font(type: .Medium, size: 14.0)
        if #available(iOS 13.0, *) {
            label.textColor = UIColor.appColor(.barColor)
        } else {
            label.textColor = UIColor.appColor(.barColor)
        }
        headerView.addSubview(label)
      
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 13).isActive = true
    
        if profileResponse?.msg?.user?.social == "google" || profileResponse?.msg?.user?.social == "apple" || profileResponse?.msg?.user?.social == "facebook" { 
            label.text = "Account Control"
        }else {
            
            
            if section == 0 {
                label.text = "Account Information"
            }else{
                label.text = "Account Control"
               
            }
        }
      
        return headerView
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
                        self.profileResponse = showUserDetail
                        self.manageAccountTableView.reloadData()
                    }
                }
            case .newShowVideosAgainstUserID(showVideosAgainstUserID: let showVideosAgainstUserID):
                print("showUserDetail")
            case .newShowUserLikedVideos(showUserLikedVideos: let showUserLikedVideos):
                print("showUserDetail")
            case .newShowFavouriteVideos(showFavouriteVideos: let showFavouriteVideos):
                print("showFavouriteVideos")
            case .newShowOtherUserDetail(showOtherUserDetail: let showOtherUserDetail):
                print("")
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
}
