//
//  InboxViewController.swift
//  WOOW
//
//  Created by Mac on 29/06/2022.
//

import UIKit
import SDWebImage // Make sure SDWebImage is imported for image loading

class InboxViewController: UIViewController {
  
    //MARK:- OUTLET
    
    private lazy var loader: UIView = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("Unable to access key window")
        }
        return Utility.shared.createActivityIndicator(keyWindow)
    }()
    
    @IBOutlet weak var whoopView: UIView!
    @IBOutlet weak var inboxTableView: UITableView!
    
    var senderID = ""
    var arrConversation = [[String : Any]]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
        self.tabBarController?.tabBar.isHidden = true
    }
   
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    //MARK:- VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inboxTableView.delegate = self
        inboxTableView.dataSource = self
        inboxTableView.register(UINib(nibName: "InboxTableViewCell", bundle: nil), forCellReuseIdentifier: "InboxTableViewCell")
        
        senderID = UserDefaultsManager.shared.user_id
        self.loader.isHidden = false
        print("senderID",senderID)
        ChatDBhandler.shared.fetchUserInbox(userID: self.senderID) { isSuccess, conversations in
            DispatchQueue.main.async {
                if isSuccess {
                    self.arrConversation = conversations
                        .filter { $0["date"] != nil } // Filter out entries where date is nil
                    
                    self.arrConversation.sort(by: { ($0["date"] as? String ?? "") > ($1["date"] as? String ?? "") })
                    print("arrConversation",self.arrConversation)
                    print("arrConversation count: \(self.arrConversation.count)")
                    self.loader.isHidden = true
                    self.inboxTableView.reloadData()
                    
                    self.whoopView.isHidden = !self.arrConversation.isEmpty
                } else {
                    // Handle failure to fetch data
                    print("Failed to fetch user inbox")
                }
            }
        }
    }
    
    //MARK:- BUTTON ACTION
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK:- EXTENSION TABLE VIEW

extension InboxViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrConversation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.arrConversation[indexPath.row]
        let image = data["pic"] as? String ?? "pic"
        let name = data["name"] as? String ?? "name"
        let lastMessage = data["msg"] as? String ?? "message"
        let dateMessage = data["date"] as? String ?? "date"
        let type = data["type"] as? String ?? "type"
        
        let userChatCell = tableView.dequeueReusableCell(withIdentifier: "InboxTableViewCell", for: indexPath) as! InboxTableViewCell
        userChatCell.imgProfile.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "videoPlaceholder"))
       
        userChatCell.lblName.text = name
        userChatCell.lblMsg.text = lastMessage
        
        return userChatCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = self.arrConversation[indexPath.row]
        let image = data["pic"] as? String ?? "pic"
        let name = data["name"] as? String ?? "name"
        let rid = data["rid"] as? String ?? "rid"
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationController = storyboard.instantiateViewController(withIdentifier: "newChatViewController") as! newChatViewController
        
        destinationController.modalPresentationStyle = .fullScreen
        destinationController.senderName = UserDefaultsManager.shared.username
        destinationController.senderID =  UserDefaultsManager.shared.user_id
        destinationController.profile_url = UserDefaultsManager.shared.profileUser
        destinationController.receiverID =  rid
        destinationController.receiverName = name
        destinationController.receiver_profile_url = image
        self.navigationController?.pushViewController(destinationController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Delete this Chat?", message: "Message will only be removed from this account.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                print("Cancel")
            }))
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                let rid = self.arrConversation[indexPath.row]["rid"] as? String ?? "rid"
                
                ChatDBhandler.shared.deleteConversation(senderID: self.senderID, receiverID: rid) { (isSuccess) in
                    if isSuccess {
                        print("Conversation and chat deleted at index: \(indexPath.row)")
                        self.arrConversation.remove(at: indexPath.row)
                        self.inboxTableView.reloadData()
                    }
                }
            }))
            
            present(alert, animated: true, completion: nil)
        }
    }
 
}
