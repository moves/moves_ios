//
//  SettingViewController.swift
// //
//
//  Created by Wasiq Tayyab on 22/06/2024.
//

import GSPlayer
import SVProgressHUD
import UIKit

class SettingViewController: UIViewController {
    var profileResponse: ProfileResponse?
    private lazy var loader: UIView = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            fatalError("Unable to access key window")
        }
        return Utility.shared.createActivityIndicator(keyWindow)
    }()
    
   
    var headerArr = ["Account", "Content & Activity", "Cache & Cellular Data", "About", "Login"]
    var string = ""
    let accountArr = [["image": "manageAccount", "title": "Manage Account"],
                      ["image": "privacy", "title": "Privacy"],
                      ["image": "request", "title": "Request Verification"],
                      //                      ["image": "order", "title": "Orders"],
//                      ["image": "withDraw", "title": "Wallet"],
                      ["image": "bookmarks", "title": "Favorites"],
                      //                      ["image": "payment", "title": "Payment Method"],
                      ["image": "block", "title": "Blocked Users"]]
    
    let businesAccountArr = [["image": "manageAccount", "title": "Manage Account"],
                             ["image": "privacy", "title": "Privacy"],
                             ["image": "order", "title": "Orders"],
                             ["image": "withDraw", "title": "Withdrawals"],
                             ["image": "bookmarks", "title": "Favorites"],
                             ["image": "payment", "title": "Payment Method"],
                             ["image": "block", "title": "Blocked Users"]]
    
    let businessTool = [["image": "shopinformation", "title": "Shop Information"],
                        ["image": "shopinformation", "title": "Legal documents verification"],
                        ["image": "menumanagement", "title": "Menu Management"]]
    
    let contentArr = [
        ["image": "language", "title": "App Language"],
    ]
    let cacheArr = [["image": "cache", "title": "Free up space"]]
    let termsArr = [["image": "terms", "title": "Terms of Service"], ["image": "privacyPolicy", "title": "Privacy Policy"]]
    let loginArr = [["image": "switch_account", "title": "Switch Account"], ["image": "logout", "title": "Logout"]]
    var myUser: [switchAccount]? { didSet {}}
    
    @IBOutlet var settingTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bytes = VideoCacheManager.calculateCachedSize()
        let megabytes = Double(bytes) / 1000000
        print("\(megabytes) MB")
        string = String(format: "%.2f", megabytes)
        print(string)
        self.setup()
    }
    
    private func setup() {
        settingTableView.delegate = self
        settingTableView.dataSource = self
        settingTableView.register(UINib(nibName: "SettingTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
        //        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        self.tabBarController?.tabBar.isHidden = false
    }
    
    func restartApplication() {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.isHidden = true
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = nav
        }
    }
    
    private func logout() {
        FirebaseAuthService.shared.signOut { success, error in
            if let error = error {
                print("Error signing out: \(error.localizedDescription)")
                return
            }
            
            let context = DataPersistence.shared.mainContext
            DataPersistence.shared.deleteEntity(withId: "profile", context: context)
            
            if success {
                print("User signed out successfully")
                self.myUser = switchAccount.readswitchAccountFromArchive()
                print("Last User", self.myUser?.last?.first_name)
                print("Last User", self.myUser?.last?.Id)
                if self.myUser?.count != 0 && self.myUser != nil {
                    for var i in 0 ..< self.myUser!.count {
                        var obj = self.myUser![i]
                        print("id", obj.Id)
                        print("UserDefaultsManager id", UserDefaultsManager.shared.user_id)
                        if obj.Id == UserDefaultsManager.shared.user_id {
                            self.myUser?.remove(at: i)
                            
                            if switchAccount.saveswitchAccountToArchive(switchAccount: self.myUser!) {
                                print("Account remove succesfully")
                                print(self.myUser?.count)
                            }
                            break
                        }
                    }
                }
                
                if self.myUser != nil && self.myUser?.count != 0 {
                    UserDefaultsManager.shared.username = "\(self.myUser?.last?.first_name ?? "") \(self.myUser?.last?.last_name ?? "")"
                    UserDefaultsManager.shared.user_id = self.myUser?.last?.Id ?? "0"
                    UserDefaultsManager.shared.profileUser = self.myUser?.last?.profile_pic ?? ""
                    UserDefaultsManager.shared.authToken = self.myUser?.last?.auth_token ?? "0"
                    UserDefaultsManager.shared.business = self.myUser?.last?.businessProfile?.toString() ?? "0"
                    
                    print("Last User", self.myUser?.last?.first_name)
                    print("Last User", self.myUser?.last?.Id)
                    print("Last User", UserDefaultsManager.shared.business)
                    NotificationCenter.default.post(name: .switchAccount, object: nil)
                    self.restartApplication()
                } else {
                    ConstantManager.shared.resetDishDetails()
                    UserDefaultsManager.shared.payment_method_id = ""
                    UserDefaultsManager.shared.cardExpiry = ""
                    UserDefaultsManager.shared.cardLastNumber = ""
                    UserDefaultsManager.shared.payment_id = ""
                    UserDefaultsManager.shared.location_id = 0
                    UserDefaultsManager.shared.location_name = ""
                    UserDefaultsManager.shared.location_address = ""
                    UserDefaultsManager.shared.user_id = "0"
                    UserDefaultsManager.shared.authToken = "0"
                    UserDefaultsManager.shared.business = "0"
                    
                    UserDefaultsManager.shared.idAuthToken = ""
                }
                
                self.restartApplication()
                
            } else {
                print("Failed to sign out")
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return accountArr.count
        } else if section == 1 {
            return contentArr.count
        } else if section == 2 {
            return cacheArr.count
        } else if section == 3 {
            return termsArr.count
        } else {
            return loginArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as! SettingTableViewCell
        cell.lblSetting.textColor = .black
        
        if indexPath.section == 0 {
            cell.lblSetting.text = accountArr[indexPath.row]["title"]!
            cell.imgSetting.image = UIImage(named: accountArr[indexPath.row]["image"]!)
            
        } else if indexPath.section == 1 {
            cell.lblSetting.text = contentArr[indexPath.row]["title"]!
            cell.imgSetting.image = UIImage(named: contentArr[indexPath.row]["image"]!)
            
            if indexPath.row == 0 {
                cell.lblLanguage.isHidden = false
                cell.lblLanguage.text = "English"
            }
            
        } else if indexPath.section == 2 {
            cell.lblSetting.text = cacheArr[indexPath.row]["title"]!
            cell.imgSetting.image = UIImage(named: cacheArr[indexPath.row]["image"]!)
            
            cell.lblLanguage.isHidden = false
            let bytes = VideoCacheManager.calculateCachedSize() // assume this is the number of bytes
            let megabytes = Double(bytes) / 1000000
            
            cell.lblLanguage.text = "\(string) MB"
            
        } else if indexPath.section == 3 {
            cell.lblSetting.text = termsArr[indexPath.row]["title"]!
            cell.imgSetting.image = UIImage(named: termsArr[indexPath.row]["image"]!)
        } else {
            if indexPath.row == 1 {
                cell.lblSetting.textColor = .red
            }
            if indexPath.row == 0 {
                cell.imgSetting.tintColor = .black
            }
            cell.lblSetting.text = loginArr[indexPath.row]["title"]!
            cell.imgSetting.image = UIImage(named: loginArr[indexPath.row]["image"]!)
        }
        cell.imgSetting.tintColor = .black
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SettingTableViewCell
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let myviewController = ManageAccountViewController(nibName: "ManageAccountViewController", bundle: nil)
                myviewController.profileResponse = self.profileResponse
                self.navigationController?.pushViewController(myviewController, animated: true)
            } else if indexPath.row == 1 {
                let myviewController = PrivacyPolicyViewController(nibName: "PrivacyPolicyViewController", bundle: nil)
                myviewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(myviewController, animated: true)
            } else if indexPath.row == 2 {
                let first = profileResponse?.msg?.user?.firstName ?? ""
                let second = profileResponse?.msg?.user?.lastName ?? ""
                let myviewController = RequestVerificationViewController(nibName: "RequestVerificationViewController", bundle: nil)
                myviewController.fullname = first + " " + second
                myviewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(myviewController, animated: true)
            }
            //                else if indexPath.row == 3 {
            //                    let myviewController = OrderHistoryViewController(nibName: "OrderHistoryViewController", bundle: nil)
            //                    myviewController.hidesBottomBarWhenPushed = true
            //                    self.navigationController?.pushViewController(myviewController, animated: true)
            //
            //                }
//            else if indexPath.row == 3 {
//                let myviewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletViewController")as! MyWalletViewController
//                myviewController.profileResponse = self.profileResponse
//                myviewController.hidesBottomBarWhenPushed = true
//                self.navigationController?.pushViewController(myviewController, animated: true)
//                
//            }
            else if indexPath.row == 3 {
                let myviewController = FavouriteViewController(nibName: "FavouriteViewController", bundle: nil)
                myviewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(myviewController, animated: true)
                
            }
            //                else if indexPath.row == 6 {
            //                    let myviewController = PaymentMethodViewController(nibName: "PaymentMethodViewController", bundle: nil)
            //                    myviewController.hidesBottomBarWhenPushed = true
            //                    self.navigationController?.pushViewController(myviewController, animated: true)
            //
            //                }
            else {
                let myviewController = BlockUserViewController(nibName: "BlockUserViewController", bundle: nil)
                myviewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(myviewController, animated: true)
            }
            
        } else if indexPath.section == 1 {
        } else if indexPath.section == 2 {
            do {
                URLCache.shared.removeAllCachedResponses()
                DataPersistence.shared.clear()
                
                FileManager.default.clearTmpDirectory()
                SVProgressHUD.show(withStatus: "Cleaning cache...")
                try VideoCacheManager.cleanAllCache()
                
                let bytes = VideoCacheManager.calculateCachedSize()
                let megabytes = Double(bytes) / 1000000
                let string = String(format: "%.0f", megabytes)
                print("\(megabytes) MB")
                print(string)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    SVProgressHUD.dismiss()
                    cell.lblLanguage.text = "\(string) MB"
                }
            } catch {
                // In case of an error, make sure SVProgressHUD is not shown.
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    print("Error cleaning cache: \(error)")
                }
            }
            
        } else if indexPath.section == 3 {
            if indexPath.row == 0 {
                let myviewController = WebViewController(nibName: "WebViewController", bundle: nil)
                myviewController.myUrl = "https://movesapp.io/privacypolicy/"
                myviewController.linkTitle = "Terms of Service"
                myviewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(myviewController, animated: true)
            } else {
                let myviewController = WebViewController(nibName: "WebViewController", bundle: nil)
                myviewController.myUrl = "https://movesapp.io/privacypolicy/"
                myviewController.linkTitle = "Privacy Policy"
                myviewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(myviewController, animated: true)
            }
            
        } else {
            if indexPath.row == 0 {
                let story = UIStoryboard(name: "Main", bundle: nil)
                let vc = story.instantiateViewController(withIdentifier: "SwitchAccountViewController") as! SwitchAccountViewController
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: true)
            } else {
                let alertController = UIAlertController(title: NSLocalizedString("LOGOUT", comment: ""), message: "Would you like to LOGOUT?", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (_: UIAlertAction!) in
                    self.logout()
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_: UIAlertAction!) in
                    print("Cancel button tapped")
                }
                alertController.addAction(OKAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        headerView.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.font = AppFont.font(type: .Semibold, size: 14.0)
        if #available(iOS 13.0, *) {
            label.textColor = UIColor.appColor(.darkGrey)
        } else {
            label.textColor = UIColor.appColor(.darkGrey)
        }
        
        headerView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 13).isActive = true
        label.heightAnchor.constraint(equalToConstant: 18).isActive = true
        label.text = headerArr[section]
        return headerView
    }
}
