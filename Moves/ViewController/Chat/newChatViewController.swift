
//

import UIKit
import FirebaseCore
import SDWebImage
import FirebaseDatabase

class newChatViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITableViewDataSource, UITableViewDelegate,UITextViewDelegate{
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var accessoryView: UIView!
    @IBOutlet weak var txtMessage: UITextView!
    @IBOutlet weak var imgAdd: UIImageView!
    
    @IBOutlet weak var imgSendMessgae: UIImageView!
    @IBOutlet weak var txtMessageHeight: NSLayoutConstraint!
    @IBOutlet weak var accessoryViewBottom: NSLayoutConstraint!
    
    
    private lazy var loader: UIView = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("Unable to access key window")
        }
        return Utility.shared.createActivityIndicator(keyWindow)
    }()
    
    var isNotification =  false
    let imagePicker = UIImagePickerController()
    var imagedata = Data()
    var minTextViewHeight: CGFloat = 40
    var maxTextViewHeight: CGFloat = 100
    
    var arrMessages = [[String : Any]]()
   
    
    var msgDict = [String : Any]()
    var receiverName = "0"
    var receiverProfile = String()
    var senderName = "0"
    var senderProfile = String()
    var dateString = String()
    var currentUserName = String()
    var senderID = "0"
    var receiverID = "0"
    var profile_url = ""
    var receiver_profile_url = ""
    var OrderID =  ""
    
    var MsgType = ""


    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lblTitle.text = self.receiverName
        txtMessage.text = "Type your message here..."
        txtMessage.textColor = UIColor.lightGray
        txtMessage.delegate = self
        
        ChatDBhandler.shared.fetchMessage(senderID: self.senderID, receiverID: self.receiverID) { (isSuccess, messages) in
            self.arrMessages.removeAll()
            
            if isSuccess {
                DispatchQueue.global(qos: .userInitiated).async {
                    var newMessages = [[String: Any]]()
                    
                    for (_, messageData) in messages {
                        guard let message = messageData as? [String: Any] else { continue }
                        newMessages.append(message)
                    }
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ssZZ"
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    
                    for (index,obj) in newMessages.enumerated(){
                        var msg =  obj
                        let formate =  dateFormatter.date(from: msg["timestamp"] as? String ?? "")
                        msg.updateValue(formate, forKey: "formate_date")
                        newMessages.remove(at: index)
                        newMessages.insert(msg, at: index)
                    }
                    
                    print(newMessages)
                    
//                    let sortedMessages = newMessages.sorted { (msg1, msg2) -> Bool in
//                        guard let timestamp1 = msg1["timestamp"] as? String,
//                              let timestamp2 = msg2["timestamp"] as? String,
//                              let date1 = dateFormatter.date(from: timestamp1),
//                              let date2 = dateFormatter.date(from: timestamp2) else {
//                            return false
//                        }
//                        return date1 > date2
//                    }
                    
//                    let sortedMessages = newMessages.sorted { (msg1, msg2) -> Bool in
//                        guard let timestamp1 = msg1["timestamp"] as? String,
//                              let timestamp2 = msg2["timestamp"] as? String,
//                              let date1 = dateFormatter.date(from: timestamp1),
//                              let date2 = dateFormatter.date(from: timestamp2) else {
//                            // If timestamps are invalid, maintain the current order
//                            return false
//                        }
//                        
//                        if date1 == date2 {
//                            if let id1 = msg1["chat_id"] as? String, let id2 = msg2["chat_id"] as? String {
//                                return id1 < id2
//                            }
//                        }
//                        
//                        return date1 > date2
//                    }
                    
                    let sortedMessages = newMessages.sorted(by: {$1["formate_date"] as? Date ?? Date() > $0["formate_date"] as? Date  ?? Date() })
                    // Once sorting is done, update the UI on the main thread
                    DispatchQueue.main.async {
                        self.arrMessages = sortedMessages
                        self.tblView.reloadData()
                        self.scrollToBottom()
                    }
                }
            } else {
                print("Failed to fetch messages.")
            }
        }

        if arrMessages.count == 0 {
            self.lblMessage.isHidden = true
        } else {
            self.lblMessage.isHidden = false
        }

        self.txtMessage.tintColor = UIColor(named: "theme")
        self.txtMessage.tintColorDidChange()
        self.txtMessage.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.imagePicker.delegate = self
        let imgTap = UITapGestureRecognizer.init(target: self, action: #selector(self.tapImage(sender:)))
        imgAdd.isUserInteractionEnabled = true
        imgAdd.addGestureRecognizer(imgTap)
        
        let imgMessage = UITapGestureRecognizer.init(target: self, action: #selector(self.sendMessage(tap:)))
        imgSendMessgae.isUserInteractionEnabled = true
        imgSendMessgae.addGestureRecognizer(imgMessage)
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == self.view{
                self.txtMessage.resignFirstResponder()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
        self.tabBarController?.tabBar.isHidden = true
    }
   
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       // self.tabBarController?.tabBar.isHidden = false
    }
    

    
    //MARK:- scroll to bottom
    func scrollToBottom(){
        if arrMessages.count > 0
        {
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: self.arrMessages.count-1, section: 0)
                self.tblView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    
    
    //MARK:- Delegate Method
    
    //MARK:- tap gesture
    @objc func tapImage(sender:UITapGestureRecognizer){
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .fullScreen
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK:- image picker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            self.dismiss(animated: true, completion: nil)
            self.imagedata = pickedImage.jpegData(compressionQuality: 0.25)!
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy HH:mm:ssZ"//"dd-MM-yyyy HH:mm:ss"
            let timeStamp = formatter.string(from: date)
            
           // txtMessage.text = "Type your message here..."
            
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "dd-MM-yyyy HH:mm:ss"
            let time = formatter1.string(from: date)
            
            self.loader.isHidden =  false
           
            
//            ChatDBhandler.shared.sendImage(requestID: self.OrderID, senderID: senderID,senderName:senderName ,receiverID: receiverID, image: imagedata, seen: false, time: time, type: "image", timestamp:timeStamp, orderID: self.OrderID, msgType: MsgType) { (result, url) in
//                print(result , url)
//                self.loader.isHidden =  true
//                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
//                if result == true{
//                    print("image sent")
//                    
////                    ApiHandler.sharedInstance.SendNotifications(order_id: self.OrderID, sender_id: self.senderID, receiver_id: self.receiverID, title: "Send a message", type: "image", message: "Send an image") { (isSuccess, response) in
////                        if isSuccess{
////                            if response?.value(forKey: "code") as! NSNumber == 200 {
////                                print("Notification Send")
////                            }
////                        }
////                    }
//                }
//                
//            }
        }else{
            print("Error in pick Image")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Change the height of textView when type
    
    func textViewDidChange(_ textView: UITextView){
        var height = textView.contentSize.height
        
        if height < minTextViewHeight
        {
            height = minTextViewHeight
        }
        
        if (height > maxTextViewHeight)
        {
            height = maxTextViewHeight
        }
        
        if height != txtMessageHeight.constant
        {
            txtMessageHeight.constant = height
            textView.setContentOffset(CGPoint.zero, animated: false)
        }
       
    }
    
  
    //MARK:- keyboardWillShow
    @objc func keyboardWillShow(notification: NSNotification){
        let keyboardSize = (notification.userInfo?  [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        
        let keyboardHeight = keyboardSize?.height
        
        self.accessoryViewBottom.constant = -(keyboardHeight! - view.safeAreaInsets.bottom)
        
        UIView.animate(withDuration: 0.5)
        {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK:- keyboardWillHide
    @objc func keyboardWillHide(notification: NSNotification){
        self.accessoryViewBottom.constant =  0
        UIView.animate(withDuration: 0.5){
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK:- button Actions
    @IBAction func btnBackAction(_ sender: Any){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func sendMessage(tap:UITapGestureRecognizer){
        self.sendPressed()
        txtMessage.resignFirstResponder()
    }

    //MARK:- SEND MSG ACTION

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            self.sendPressed()
            textView.resignFirstResponder()
        }
        return true
        
    }

    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.txtMessage.text == ""{
            self.txtMessage.text = "Text a message here..."
            self.txtMessage.textColor = UIColor.lightGray
        }
    }
    
    //MARK:- PLACEHOLDER OF TEXT VIEW
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    
    func sendPressed() {
        guard let messageText = self.txtMessage.text, !messageText.isEmpty else {
            Utility.showMessage(message: "Please type your message", on: self.view)
            return
        }

        let date = Date()
        
        let formatter1 = DateFormatter()
        formatter1.locale = Locale(identifier: "en_US_POSIX")
        formatter1.dateFormat = "dd-MM-yyyy HH:mm:ssZZ"
        let timeStamp = formatter1.string(from: date)
        
        print("timeStamp",timeStamp)
        print("sender: \(senderID) && receiver: \(receiverID)")
        print("Message text: \(messageText)")
        
        if receiver_profile_url == ""{
            receiver_profile_url = "https://app.movesapp.io/mobileapp_api/"
        }
        
        if profile_url == ""{
            profile_url = "https://app.movesapp.io/mobileapp_api/"
        }
        
        // Send the message
        ChatDBhandler.shared.sendMessage(senderID: senderID, receiverID: receiverID, senderName: senderName, receiverName: receiverName, receiverPic: receiver_profile_url, message: messageText, pic_url: profile_url, timestamp: timeStamp, time: "") { (isSuccess) in
            if isSuccess {
                print("Message Sent")
                self.txtMessage.text = "Type of message here..."
                self.txtMessage.textColor = UIColor.lightGray
            } else {
                Utility.showMessage(message: "Try Again Later", on: self.view)
            }
        }
        
        self.txtMessageHeight.constant = self.minTextViewHeight
    }

    
    
    
    //MARK:- tableView delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if self.arrMessages.count == 0{
            return 0
        }else{
            self.lblMessage.isHidden = true
            return self.arrMessages.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let timeString = self.arrMessages[indexPath.row]["timestamp"] as? String else {
            return UITableViewCell()
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ssZZ"
        
        guard let dateFromStr = dateFormatter.date(from: timeString) else {
            print("Error: Unable to parse date from string:", timeString)
            return UITableViewCell()
        }
        
        // Configure output format for displaying time
        dateFormatter.dateFormat = "hh:mm"
        let timeFromDate = dateFormatter.string(from: dateFromStr)
        print("Formatted time:", timeFromDate)
        
        let from = self.arrMessages[indexPath.row]["sender_id"] as? String ?? "from"
        let type = self.arrMessages[indexPath.row]["type"] as? String ?? "type"
        
        if from == senderID {
            // Outgoing message
            if type == "text" || type == "delete" {
                
                if type == "delete" {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell5", for: indexPath) as! ChatTableViewCell
                    cell.lblMessage.text = "This message is deleted by \(senderName)"
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell1", for: indexPath) as! ChatTableViewCell
                    cell.lblMessage.text = arrMessages[indexPath.row]["text"] as? String ?? "text"
                    cell.lblDate.text = timeFromDate
                    return cell
                }
               
                
            } else if type == "image" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell2", for: indexPath) as! ChatTableViewCell
                // Configure image cell
                return cell
            }
        } else {
            // Incoming message
            if type == "text" || type == "delete" {
              
                if type == "delete" {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell5", for: indexPath) as! ChatTableViewCell
                    cell.lblMessage.text = "This message is deleted by \(senderName)"
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell3", for: indexPath) as! ChatTableViewCell
                    cell.lblMessage.text = arrMessages[indexPath.row]["text"] as? String ?? "text"
                    cell.lblDate.text = timeFromDate
                    return cell
                }
               
            } else if type == "image" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell4", for: indexPath) as! ChatTableViewCell
                // Configure image cell
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    @objc func handleLongPress(_ gesture: UITapGestureRecognizer) {
        guard let tag = gesture.view?.tag else { return }
        
        let objRequestID = self.arrMessages[tag]["chat_id"] as! String
        let type = self.arrMessages[tag]["type"] as? String ?? "type"
        
        print(objRequestID)
        
        if type == "image" {
            // Handle image deletion (if needed)
            // Uncomment and implement as per your requirements
            /*
            let objImgURL = self.arrMessages[tag]["pic_url"] as! String
            ChatDBhandler.shared.DeleteImage(requestID: self.OrderID, ChatID: objRequestID, ImageURL: objImgURL, senderID: senderID, receiverID: receiverID, senderName: self.senderName, message: "image has been deleted", pic_url: "", seen: false, type: "delete") { (isSuccess) in
                if isSuccess {
                    print("Image Deleted")
                }
            }
            */
        } else if type == "text" {
            let alert = UIAlertController(title: "Delete Message", message: "Are you sure you want to delete this message?", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                ChatDBhandler.shared.updateMessage(chatID: objRequestID, senderID: self.senderID, receiverID: self.receiverID) { success in
                    if success {
                        print("Message Deleted")
                        // Optionally remove message from local display
                        self.tblView.reloadData()
                    }
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
    }



    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat{
        return UITableView.automaticDimension
    }

    
    //MARK:- tap getsure recognizer
    @objc func imagePreview(_ gesture: UITapGestureRecognizer){
        let tapLocation = gesture.location(in: self.tblView)
        let indexPath = self.tblView.indexPathForRow(at: tapLocation)!
        
        let type = self.arrMessages[indexPath.row]["type"] as? String ?? "type"
        let picture = arrMessages[indexPath.row]["pic_url"] as? String ?? "messages"
        
        print("pic: ",picture)
        if type == "image"{
            let imagePreviewVC = self.storyboard?.instantiateViewController(withIdentifier: "imagePreviewVC") as! ImagePreviewViewController
            imagePreviewVC.imgUrl = picture
            imagePreviewVC.modalPresentationStyle = .fullScreen
            navigationController?.present(imagePreviewVC, animated: true, completion: nil)
        }
    }
}

