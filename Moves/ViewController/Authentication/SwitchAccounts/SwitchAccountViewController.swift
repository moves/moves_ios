//
//  SwitchAccountViewController.swift
//  Infotex
//
//  Created by Mac on 14/09/2021.
//

import UIKit
import SDWebImage

class SwitchAccountViewController: UIViewController {
    
    //MARK: OUTLET
    
    @IBOutlet weak var accountTableView: UITableView!
    @IBOutlet weak var heightTblView: NSLayoutConstraint!
    var mySwitchAccount:[switchAccount]?{didSet{}}
    //var myUser:[loginUser]?{didSet{}}
    var index_path = 0
    
    //MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.accountTableView.delegate = self
        self.accountTableView.dataSource = self

       // self.myUser = loginUser.readUserFromArchive()
        self.mySwitchAccount = switchAccount.readswitchAccountFromArchive()

        if mySwitchAccount?.count != 0 && self.mySwitchAccount != nil{
            for var i in 0..<self.mySwitchAccount!.count{
                var obj = self.mySwitchAccount![i]
                if obj.Id == UserDefaultsManager.shared.user_id{
                    self.index_path = i
                    self.mySwitchAccount?.remove(at: i)
                    self.mySwitchAccount?.insert(obj, at: i)
                    self.accountTableView.reloadData()
                }
            }
            if self.heightTblView.constant < self.view.frame.height - 30 {
                self.heightTblView.constant =  CGFloat(self.mySwitchAccount!.count * 80)
            }
        }
    }
    //MARK: viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
    }
    
    //MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        self.changeBackgroundAni()
    }
    
    func changeBackgroundAni() {
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        }, completion:nil)
    }
    
    
    //MARK: Button Actions
    
    @IBAction func btnCancel(_ sender: UIButton){
        self.dismiss(animated:true , completion: nil)
     }
    @IBAction func btnAddAccountAction(_ sender: Any) {
        if let rootViewController = UIApplication.topViewController() {
            let vc = SignUpViewController(nibName: "SignUpViewController", bundle: nil)
            vc.isSwitchAccount =  true
            let nav = UINavigationController(rootViewController: vc)
            nav.isNavigationBarHidden =  true
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
}
//MARK: tableView

extension SwitchAccountViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("SwitchAccount.count",self.mySwitchAccount?.count)
        return self.mySwitchAccount?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchAccountTableViewCell", for: indexPath)as! SwitchAccountTableViewCell
        
        let userImgUrl = URL(string:(self.mySwitchAccount![indexPath.row].profile_pic ?? "") ?? "profile")
        print(userImgUrl)
        cell.profileImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.profileImage.sd_setImage(with: userImgUrl, placeholderImage: UIImage(named: "profile"))
        cell.lblUsername.text =  self.mySwitchAccount![indexPath.row].username
        cell.lblName.text =  "\(self.mySwitchAccount![indexPath.row].first_name ?? "") \(self.mySwitchAccount![indexPath.row].last_name ?? "")"
         
        if index_path == indexPath.row{
            cell.tintColor = UIColor(named: "theme")
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }else{
            cell.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            cell.accessoryType = .none
        }
      
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let account = self.mySwitchAccount![indexPath.row]
        if account.Id == UserDefaultsManager.shared.user_id{
            return
        }
        
        let context = DataPersistence.shared.mainContext
        DataPersistence.shared.deleteEntity(withId: "profile", context: context)
        
        UserDefaultsManager.shared.username = account.username  ?? ""
        UserDefaultsManager.shared.user_id = account.Id ?? ""
        UserDefaultsManager.shared.profileUser = account.profile_pic ?? ""
        UserDefaultsManager.shared.authToken = account.auth_token ?? ""
        UserDefaultsManager.shared.business =  account.businessProfile?.toString() ?? "0"
        
        print("Id",account.Id ?? "")
        print("auth_token",account.auth_token ?? "")
        print("Profile type",UserDefaultsManager.shared.business)
        
        
        NotificationCenter.default.post(name: .switchAccount, object: nil)
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.isHidden = true
        self.view.window?.rootViewController = nav
    
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
