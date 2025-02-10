//
//  PostVideoViewController.swift
// //
//
//  Created by Wasiq Tayyab on 11/06/2024.
//

import UIKit
import AVFoundation
import SVProgressHUD
import FirebaseFunctions

class PostVideoViewController: UIViewController, UITextViewDelegate,URLSessionTaskDelegate,tagFriendDelegate,customThumbnailImage{
   
    
    
    //MARK: Outlets
    var isEditVideo =  false
    var objVideo:HomeResponseMsg?
    var isAiGeneration = true
    var videoUrl: URL!
    var thumbnailImage: UIImage?
    var allowComments = "true"
    var width = ""
    var height = ""
    var privacy = "Public"
    var privacyArray = ["Public","Private"]
    var lat = ""
    var long = ""
    var placeId = ""
    var string_location = ""
    var status = ""
    var isNextPageLoad = false
    var location_title = ""
    var summary = ""
    
    var isShopTag =  false  // SHOP_Tag or PRODUCT_Tag
    var showDishProductTag = false //IF DISH != ) but Dish Object nil

    //PARAM SEND TO JSON
    var tag_store_id = "0"
    var tag_product_json =  NSMutableArray() //[[String:Any]]()
    var user_custom_thumbnail:UIImage?
    var str_user_custom_thumbnail:String?
    var str_default_thumbnail:String?
    var default_thumbnail:UIImage?
    
    private var startPoint = 0
    private var viewModel = SearchViewModel()
    var storetagged = [SearchStoreResponseMsg]()
    private var loadingDotsView: LoadingDotsView?
    
    @IBOutlet weak var btnEditCover: CustomButton!
    @IBOutlet weak var btnPostVideo: CustomButton!
    @IBOutlet weak var switchAllowComment: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblPirvacy: UILabel!
    @IBOutlet weak var videoThumb: UIImageView!
    @IBOutlet weak var lblDescriptionCount: UILabel!
    @IBOutlet weak var tfDescribe: AttrTextView!
    @IBOutlet weak var backView: UIView!
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        self.backView.addGestureRecognizer(tapGesture)
        self.tfDescribe.inputAccessoryView = getKeyboardToolbar()
    }
    
    private lazy var keyboardToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        return toolbar
    }()
    
    func getKeyboardToolbar() -> UIToolbar {
        return keyboardToolbar
    }
    
    @objc private func doneButtonTapped() {
        self.backView.isHidden = true
        view.endEditing(true)
    }
    
    //MARK: ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
    }
    
    //MARK: SetupView
    func setupView(){
        
        self.tableView.isHidden =  true
        self.tableView.canCancelContentTouches = false
        self.tfDescribe.delegate = self
        self.videoThumb.image = thumbnailImage
        self.default_thumbnail = thumbnailImage
        self.XIBRegister()
        if isEditVideo{
            //LOCATION
            
            self.lat = self.objVideo?.video?.lat ?? "0"
            self.long = self.objVideo?.video?.long ?? "0"
            self.placeId =  "\(self.objVideo?.video?.locationId ?? 0)"
            self.location_title = self.objVideo?.video?.locationString ?? "Add Location"
            self.lblLocation.text =  self.objVideo?.video?.locationString ?? "Add Location"
            
            self.tfDescribe.text  =  self.objVideo?.video?.description ?? ""
            self.videoUrl =  URL(string: self.objVideo?.video?.video ?? "")
            self.videoThumb.sd_setImage(with: URL(string: self.objVideo?.video?.thum ?? ""), placeholderImage: UIImage(named: "mealMePlaceholder"))
            self.thumbnailImage  = self.videoThumb.image
            self.privacy = self.objVideo?.video?.privacyType ?? ""
            self.allowComments =  self.objVideo?.video?.allowComments ?? ""
            self.switchAllowComment.isOn =  self.objVideo?.video?.allowComments == "1" ?  true : false
            self.btnEditCover.isHidden =  true
            self.setupTextView(textView: tfDescribe.text)
            
//            tfDescribe.setText(text: tfDescribe.text,
//                               textColor: .black,
//                               withHashtagColor: UIColor.appColor(.theme)!,
//                               andMentionColor: .black,
//                               andCallBack: { (strng, type) in
//                print("type: \(type) strng: \(strng)")},
//                               normalFont: .systemFont(ofSize: 12, weight: UIFont.Weight.regular),
//                               hashTagFont: .systemFont(ofSize: 12, weight: UIFont.Weight.semibold),
//                               mentionFont: .systemFont(ofSize: 12, weight: UIFont.Weight.semibold))
//            
            self.btnPostVideo.setTitle("Edit", for: .normal)
        }
        if !isEditVideo{
            if let size = resolutionSizeForLocalVideo(url: videoUrl) {
                width = "\(Int(size.width))"
                height = "\(Int(size.height))"
                print("Video width: \(width), height: \(height)")
            } else {
                print("Failed to get video resolution size.")
            }
        }
        
    }
    
    
    @objc func tapGestureHandler() {
        view.endEditing(true)
    }
    

    //MARK: Delegate
    func customThumbnail(img: UIImage?) {
        self.videoThumb.image = img
        user_custom_thumbnail = img
       
    }

    //MARK: XIB
    
    @IBAction func editProfileButtonPressed(_ sender: CustomButton) {
        //        let myViewController = VideoThumbnailViewController(nibName: "VideoThumbnailViewController", bundle: nil)
        //        myViewController.videoURL = videoUrl
        //        self.present(myViewController, animated: true)
    }
    
    
    @IBAction func aiGenerateButtonPressed(_ sender: CustomButton) {
        self.summary = ""
        if isAiGeneration {
            self.tfDescribe.text = ""
            self.displayLoadingDots()
            DispatchQueue.global(qos: .userInitiated).async {
                while true {
                    if ConstantManager.isFunctionError {
                        DispatchQueue.main.async {
                            self.tfDescribe.text = "Describe Your Video"
                            self.tfDescribe.textColor = UIColor.appColor(.darkGrey)
                            self.hideLoadingDots()
                            ConstantManager.isFunctionError = false
                        }
                        break
                    } else {
                        
                        if let summary = ConstantManager.functionJson["msg"] as? [String: Any],
                           let summaryText = summary["summary"] as? String {
                            DispatchQueue.main.async {
                                self.hideLoadingDots()
                                self.summary = summaryText
                                self.simulateTyping(summaryText)
                            }
                            break
                        }
                    }
                    
                    Thread.sleep(forTimeInterval: 0.1)
                }
            }
        } else {
            self.tfDescribe.text = summary
            self.hideLoadingDots()
        }
    }
    
    
    private func displayLoadingDots() {
        if loadingDotsView == nil {
            loadingDotsView = LoadingDotsView()
            // Add the loading dots view as a subview of tfDescribe
            tfDescribe.addSubview(loadingDotsView!)
            
            // Set auto layout constraints
            loadingDotsView?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                loadingDotsView!.leadingAnchor.constraint(equalTo: tfDescribe.leadingAnchor, constant: 8),
                loadingDotsView!.topAnchor.constraint(equalTo: tfDescribe.topAnchor, constant: 5),
                loadingDotsView!.centerYAnchor.constraint(equalTo: tfDescribe.centerYAnchor),
                loadingDotsView!.widthAnchor.constraint(equalToConstant: 100),
                loadingDotsView!.heightAnchor.constraint(equalToConstant: 20)
            ])
        }
        loadingDotsView?.isHidden = false
    }
    
    private func hideLoadingDots() {
        loadingDotsView?.isHidden = true
    }
    
    private func simulateTyping(_ text: String) {
        self.hideLoadingDots()
        
        let truncatedText = String(text.prefix(250))
        tfDescribe.textColor = UIColor.black
        self.tfDescribe.text = ""
        tfDescribe.isUserInteractionEnabled = false
        var characterIndex = 0
        let typingSpeed = 0.05
        
        Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { [weak self] timer in
            if characterIndex < truncatedText.count {
                let index = truncatedText.index(truncatedText.startIndex, offsetBy: characterIndex)
                let nextCharacter = truncatedText[index]
                self?.tfDescribe.text?.append(nextCharacter)
                characterIndex += 1
                
                DispatchQueue.main.async {
                    self?.lblDescriptionCount.text = "\(self?.tfDescribe.text?.count ?? 0)/250"
                }
            } else {
                timer.invalidate()
                DispatchQueue.main.async {
                    self?.isAiGeneration = false
                    self?.tfDescribe.isUserInteractionEnabled = true
                }
            }
        }
        
        if truncatedText.contains("#") {
            handleHashtagDetection(newText: truncatedText)
        }
        
        self.lblDescriptionCount.text = "\(truncatedText.count)/250"
    }
    
    
    func XIBRegister(){
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection  = true
        self.tableView.register(UINib(nibName: "HashtagsTableViewCell", bundle: nil), forCellReuseIdentifier: "HashtagsTableViewCell")
        
    }
    
    //MARK: TouchView
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == self.view || touch.view == self.backView {
                self.backView.isHidden = true
                self.tfDescribe.resignFirstResponder()
            }
        }
    }
    
    func listFriends(obj: [[String:Any]]) {
        if self.tfDescribe.text.starts(with: "Describe Your Video") {
            self.tfDescribe.text = ""
        }
        let usernames = obj.map{ $0["user_name"] as? String ?? "error" }.joined(separator: " @")
        print(usernames)
        var result =  self.tfDescribe.text  + usernames
        self.tfDescribe.text = result ?? "Error to assign tag list"
    }
    //MARK: setupTextView
    func setupTextView(textView:String){
        self.tfDescribe.setText(text: textView,textColor: .black, withHashtagColor:  UIColor.appColor(.theme)!,andMentionColor: UIColor.appColor(.theme)!,andCallBack: { [weak self] (strng, type) in
            print("Mentiontype: \(type) strng: \(strng)")
        },normalFont: .systemFont(ofSize: 12, weight: UIFont.Weight.regular),hashTagFont: .systemFont(ofSize: 12, weight: UIFont.Weight.semibold),mentionFont: .systemFont(ofSize: 12, weight: UIFont.Weight.semibold))
    }
    
    //MARK: TextView
    func textView(textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.backView.isHidden =  false
        if textView.textColor == UIColor.appColor(.darkGrey) {
            textView.text = nil
            textView.textColor = UIColor.black
            textView.text = .none
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            textView.text = "Describe Your Video"
            textView.textColor = UIColor.appColor(.darkGrey)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.hideLoadingDots()
        self.lblDescriptionCount.text = "\(textView.text.count)/250"
        self.setupTextView(textView: textView.text)
        textView.becomeFirstResponder()
//        tfDescribe.setText(text: tfDescribe.text,
//                           textColor: .black,
//                           withHashtagColor: UIColor.appColor(.theme)!,
//                           andMentionColor: .black,
//                           andCallBack: { (strng, type) in
//            print("type: \(type) strng: \(strng)")
//            textView.becomeFirstResponder()},
//                           normalFont: .systemFont(ofSize: 12, weight: UIFont.Weight.regular),
//                           hashTagFont: .systemFont(ofSize: 12, weight: UIFont.Weight.semibold),
//                           mentionFont: .systemFont(ofSize: 12, weight: UIFont.Weight.semibold))
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            return false
        }
        
        guard textView == tfDescribe else { return true }
        
        /*if let currentText = textView.text as NSString? {
         let newText = currentText.replacingCharacters(in: range, with: text)
         if let hashtagRange = newText.range(of: "#", options: .backwards, range: nil, locale: nil) {
         /* let keywordStartIndex = newText.index(after: hashtagRange.upperBound)
          let keyword = String(newText[keywordStartIndex...])
          // Perform your hashtag search here using `keyword`
          let search = SearchRequest(userId: UserDefaultsManager.shared.user_id, type: "hashtag", keyword: keyword, startingPoint: startPoint)
          viewModel.searchHashtag(parameters: search)
          observeEvent()*/
         let search = SearchRequest(userId: UserDefaultsManager.shared.user_id, type: "hashtag", keyword: newText, startingPoint: startPoint)
         viewModel.searchHashtag(parameters: search)
         observeEvent()
         
         }*/
        
        if let currentText = textView.text as NSString? {
            let newText = currentText.replacingCharacters(in: range, with: text)
            if text == "#" {
                handleHashtagDetection(newText: newText)
            }else if text == "@" {
                DispatchQueue.main.async {
                    let story:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc =  story.instantiateViewController(withIdentifier: "TagFriendsViewController") as! TagFriendsViewController
                    vc.delegate = self
                    let nav = UINavigationController(rootViewController: vc)
                    nav.isNavigationBarHidden =  true
                    nav.modalPresentationStyle = .overFullScreen
                    self.present(nav, animated: true, completion: nil)
                }
            }
            
            let count = newText.count
            return count <= 250
        }
        return true
    }
    
    
    func handleHashtagDetection(newText: String) {
        if let hashtagRange = newText.range(of: "#", options: .backwards, range: nil, locale: nil) {
            self.tableView.isHidden =  false
            self.backView.isHidden  = false
            let search = SearchRequest(userId: UserDefaultsManager.shared.user_id, type: "hashtag", keyword: "", startingPoint: startPoint)
            viewModel.searchHashtag(parameters: search)
            observeEvent()
            
            /*   let hashtagEndIndex = hashtagRange.upperBound
             if hashtagEndIndex < newText.endIndex {
             let keywordStartIndex = newText.index(after: hashtagEndIndex)
             if keywordStartIndex < newText.endIndex {
             let keyword = String(newText[keywordStartIndex...])
             if !keyword.isEmpty {
             // Perform your hashtag search here using `keyword`
             let search = SearchRequest(userId: UserDefaultsManager.shared.user_id, type: "hashtag", keyword: keyword, startingPoint: startPoint)
             viewModel.searchHashtag(parameters: search)
             observeEvent()
             }
             }
             } else {
             // Handle case where hashtag is at the end of the string
             }*/
        }
    }
    
    
    //POST
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let uploadProgress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        print("Upload Progress: \(uploadProgress)")
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .uploadProgress, object: nil, userInfo: ["progress": uploadProgress])
        }
    }
    
    
    func uploadData(videoUrl: URL) {
        
        if lat == "" && long == "" {
            self.lat = UserDefaultsManager.shared.latitude.toString()
            self.long = UserDefaultsManager.shared.longitude.toString()
        }
        
        let hashtags = tfDescribe.text.hashtags()
        let mentions = tfDescribe.text.mentions1()
        
        var newHashtags: [[String: String]] = []
        var newMentions: [[String: String]] = []
        
        for hash in hashtags{
            newHashtags.append(["name":hash])
        }
        for mention in mentions{
            newMentions.append(["name":mention])
        }
        
        
        print("hashtags",hashtags)
        print("newMentions",newMentions)
        
        let urlStr =  "https://app.movesapp.io/mobileapp_api/api/postVideo"
        guard let url = URL(string: urlStr) else {
            print("Invalid URL: \(urlStr)")
            return
        }
        
        var objJSON = ""
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: tag_product_json, options: .prettyPrinted)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
                objJSON = jsonString
            }
        } catch {
            print("Error converting parameter to JSON: \(error.localizedDescription)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        
        var parameters: [String: Any] = [:]
        
            parameters = [
                "user_id" : UserDefaultsManager.shared.user_id ?? 0,
                "sound_id": UserDefaultsManager.shared.sound_id,
                "description": tfDescribe.text ?? "",
                "privacy_type": privacy.lowercased(),
                "allow_comments": self.allowComments,
                "allow_duet": "false",
                "users_json": newMentions,
                "hashtags_json": newHashtags,
                "video_id": "0",
                "videoType": "0",
                "story": "0",
                "width": width,
                "height": height,
                "lat": lat,
                "long": long,
                "location_name": self.location_title,
                "location_string": string_location,
                "google_place_id": placeId,
                "firebase_video_url" : firebase_video_url?.absoluteString ?? "",
                "user_thumbnail" : "",
                "default_thumbnail": str_default_thumbnail
                
            ]
        
        print("parameters", parameters)
        
        DispatchQueue.main.async {
            guard let videoData = try? Data(contentsOf: videoUrl) else {
                print("Failed to read data from video file")
                return
            }
            
            
            let body = self.createBody(parameters: parameters, boundary: boundary, data: videoData, mimeType: "video/mp4", filename: "video.mp4")
            
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("156c4675-9608-4591-b2ec-xxxxxxx", forHTTPHeaderField: "Api-Key")
            request.setValue(UserDefaultsManager.shared.authToken, forHTTPHeaderField: "Auth-Token")
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
            
            self.tabBarController?.selectedIndex = 0
            self.restartApplication()
            
            
            let task = session.uploadTask(with: request, from: body) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        if let data = data {
                            do {
                                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                    if let code = jsonResponse["code"] as? Int {
                                        if code == 200 {
                                            print("Upload successful with message: \(jsonResponse["msg"] ?? "")")
                                            scheduleNotification(title: "Video Uploaded", body: "Your video has been successfully uploaded!", identifier: "uploadSuccessNotification")
                                        } else {
                                            scheduleNotification(title: "Video Failed", body: "Your upload has failed", identifier: "uploadFailedNotification")
                                            print("Unexpected code: \(code), Message: \(jsonResponse["msg"] ?? "")")
                                        }
                                    }
                                }
                            } catch {
                                if let htmlString = String(data: data, encoding: .utf8) {
                                    print("Server error HTML: \(htmlString)")
                                    // Display or log the HTML error message
                                    scheduleNotification(title: "Video Failed", body: "Your upload has failed", identifier: "uploadFailedNotification")
                                } else {
                                    print("Error parsing JSON: \(error.localizedDescription)")
                                    scheduleNotification(title: "Video Failed", body: "Your upload has failed", identifier: "uploadFailedNotification")
                                }
                            }
                        }
                    default:
                        print("Invalid response: \(httpResponse.statusCode)")
                    }
                }
            }
            
            task.resume()
        }
    }
    
    //EDIT VIDEO
    func uploadWithoutVideo() {
        
        if lat == "" && long == "" {
            self.lat = UserDefaultsManager.shared.latitude.toString()
            self.long = UserDefaultsManager.shared.longitude.toString()
        }
        
        let hashtags = tfDescribe.text.hashtags()
        let mentions = tfDescribe.text.mentions1()
        
        var newHashtags: [[String: String]] = []
        var newMentions: [[String: String]] = []
        
        for hash in hashtags{
            newHashtags.append(["name":hash])
        }
        for mention in mentions{
            newMentions.append(["name":mention])
        }
        
        
        print("hashtags",hashtags)
        print("newMentions",newMentions)
        
        let urlStr = "https://app.movesapp.io/mobileapp_api/api/editVideo"
        guard let url = URL(string: urlStr) else {
            print("Invalid URL: \(urlStr)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        var parameters: [String: Any] = [:]
        
        var objJSON = ""
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: tag_product_json, options: .prettyPrinted)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
                objJSON = jsonString
            }
        } catch {
            print("Error converting parameter to JSON: \(error.localizedDescription)")
        }
        
        parameters = [
            "video_id"           : "\(self.objVideo?.video?.id ?? 0)",
            "user_id"            : UserDefaultsManager.shared.user_id ?? 0,
            "allow_comments"     : self.allowComments,
            "description"        : tfDescribe.text ?? "",
            "users_json"         : newMentions,
            "hashtags_json"      : newHashtags,
            "privacy_type"       : privacy.lowercased(),
            "tag_store_id"       : self.isShopTag ? self.tag_store_id : "0",
            "products_json"      : self.isShopTag ? [] : objJSON,
            "lat"                : lat,
            "long"               : long,
            "location_name"      : self.location_title,
            "location_string"    : string_location,
            "google_place_id"    : placeId,
            "width"              : self.objVideo?.video?.width ?? "",
            "height"             : self.objVideo?.video?.height ?? "",
            "firebase_video_url" : self.objVideo?.video?.video ?? "",
            "user_thumbnail"     : self.objVideo?.video?.thum ?? "",
            "default_thumbnail"  : self.objVideo?.video?.default_thumbnail ?? "",
        ]
        
        
        print("Parameter\n",parameters)
        print(UserDefaultsManager.shared.authToken)
        let body = createBodyWithOutVideo(parameters: parameters, boundary: boundary)
        
        // Set headers
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("156c4675-9608-4591-b2ec-xxxxxxx", forHTTPHeaderField: "Api-Key")
        request.setValue(UserDefaultsManager.shared.authToken, forHTTPHeaderField: "Auth-Token")
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        
        self.tabBarController?.selectedIndex = 0
        self.restartApplication()
        
        let task = session.uploadTask(with: request, from: body) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    if let data = data {
                        do {
                            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                if let code = jsonResponse["code"] as? Int, code == 200 {
                                    print("Upload successful with message: \(jsonResponse["msg"] ?? "")")
                                    scheduleNotification(title: "Upload Successful", body: "Your data has been successfully uploaded!", identifier: "uploadSuccessNotification")
                                } else {
                                    print("Upload failed with message: \(jsonResponse["msg"] ?? "")")
                                    scheduleNotification(title: "Upload Failed", body: "Your upload has failed", identifier: "uploadFailedNotification")
                                }
                            }
                        } catch {
                            print("Error parsing JSON: \(error.localizedDescription)")
                            scheduleNotification(title: "Upload Failed", body: "Your upload has failed", identifier: "uploadFailedNotification")
                        }
                    }
                default:
                    print("Invalid response: \(httpResponse.statusCode)")
                }
            }
        }
        
        task.resume()
    }
    
    
    func restartApplication () {
        UserDefaultsManager.shared.sound_id = ""
        UserDefaultsManager.shared.sound_name = ""
        UserDefaultsManager.shared.sound_url = ""
        UserDefaultsManager.shared.sound_second = ""

        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.isHidden = true
        self.view.window?.rootViewController = nav
    }
    
    func createBody(parameters: [String: Any], boundary: String, data: Data, mimeType: String, filename: String) -> Data {
        var body = Data()
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"video\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
    func createBodyWithOutVideo(parameters: [String: Any], boundary: String) -> Data {
        var body = Data()
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
    //MARK: Button actions
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func postVideoButtonPressed(_ sender: UIButton) {
        if isEditVideo{
            self.uploadWithoutVideo()
        }else{
            self.uploadData(videoUrl: self.videoUrl)
        }
    }
    
    
    @IBAction func commentSwitch(_ sender: UISwitch) {
        if sender.isOn {
            self.allowComments = "true"
        }else{
            self.allowComments = "false"
        }
    }
    @IBAction func addLocationButtonPressed(_ sender: UIButton) {
        let myViewController = LocationViewController(nibName: "LocationViewController", bundle: nil)
        myViewController.callback = { (placeId,string_Location,addressPlaces,status,lat,lng) -> Void in
            print("callback")
            print("string_Location",string_Location)
            self.status = status
            if status == "placeid" {
                let components = string_Location.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
                
                self.location_title = String(components[0])
                self.string_location = String(components[1])
                self.placeId = placeId
                self.lat = lat
                self.long = lng
            }else {
                self.string_location = addressPlaces.address
                self.location_title = addressPlaces.title
                self.placeId = addressPlaces.placeId
                self.lat = addressPlaces.lat.toString()
                self.long = addressPlaces.lng.toString()
            }
            DispatchQueue.main.async {
                self.lblLocation.text = self.string_location
            }
        }
        myViewController.modalPresentationStyle = .overFullScreen
        self.present(myViewController, animated: true)
    }
    @IBAction func btnEditCoverAction(_ sender: Any) {
        print("edit cover")
        let main:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc =  main.instantiateViewController(withIdentifier: "VideoTrimViewController") as! VideoTrimViewController
        vc.url = self.videoUrl
        vc.img = thumbnailImage
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    @IBAction func postHashFrieButtonPressed(_ sender: UIButton) {
        if self.tfDescribe.text.starts(with: "Describe Your Video") {
            self.tfDescribe.text = ""
        }
        if tfDescribe.text.count == 250 { return }
        self.tfDescribe.resignFirstResponder()
        let appendString: String
        if sender.tag == 0 {
            appendString = " #"
            self.tableView.isHidden = false
            let search = SearchRequest(userId: UserDefaultsManager.shared.user_id, type: "hashtag", keyword: "_", startingPoint: startPoint)
            viewModel.searchHashtag(parameters: search)
            self.observeEvent()
        } else {
            appendString = " @"
            DispatchQueue.main.async {
                let story:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc =  story.instantiateViewController(withIdentifier: "TagFriendsViewController") as! TagFriendsViewController
                vc.delegate = self
                let nav = UINavigationController(rootViewController: vc)
                nav.isNavigationBarHidden =  true
                nav.modalPresentationStyle = .overFullScreen
                self.present(nav, animated: true, completion: nil)            }
        }
        
        self.setupTextView(textView: tfDescribe.text + appendString)
        
//        self.tfDescribe.setText(text: tfDescribe.text + appendString,textColor: .black, withHashtagColor:  UIColor.appColor(.theme)!,andMentionColor: UIColor.appColor(.theme)!,andCallBack: { (strng, type) in
//            print("type: \(type) strng: \(strng)")
//        },normalFont: .systemFont(ofSize: 12, weight: UIFont.Weight.regular),hashTagFont: .systemFont(ofSize: 12, weight: UIFont.Weight.semibold),mentionFont: .systemFont(ofSize: 12, weight: UIFont.Weight.semibold))
        
        // Open keyboard and set cursor at the end
        self.tfDescribe.becomeFirstResponder()
        
        if let newPosition = tfDescribe.position(from: tfDescribe.endOfDocument, offset: 0) {
            tfDescribe.selectedTextRange = tfDescribe.textRange(from: newPosition, to: newPosition)
        }
    }
    
    @IBAction func videoViewButtonPressed(_ sender: UIButton) {
        let newViewController = PostStatusViewController(nibName: "PostStatusViewController", bundle: nil)
        newViewController.hidesBottomBarWhenPushed = true
        newViewController.modalPresentationStyle = .overFullScreen
        newViewController.status = "viewVideo"
        newViewController.selected = privacy
        newViewController.lbl = "Who can view this post"
        newViewController.mainArr = privacyArray
        
        newViewController.callback = { (str, status) -> Void in
            print("callback")
            self.privacy = str
            self.lblPirvacy.text = str
        }
        self.present(newViewController, animated: false)
    }
    
}


//MARK: Extension - TableView
extension PostVideoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchHashtag?.msg?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HashtagsTableViewCell", for: indexPath)as! HashtagsTableViewCell
        let hashtag = viewModel.searchHashtag?.msg?[indexPath.row].hashtag
        cell.lblHashtag.text = hashtag?.name
        cell.lblPost.text = (hashtag?.views ?? "0") + " posts"
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row at indexPath: \(indexPath)")
        
        let hashtagName = viewModel.searchHashtag?.msg?[indexPath.row].hashtag.name ?? ""
        
        self.setupTextView(textView: tfDescribe.text + hashtagName)
        
//        tfDescribe.setText(text: tfDescribe.text + hashtagName, textColor: .black,withHashtagColor: UIColor.appColor(.theme)!, andMentionColor: UIColor.appColor(.theme)!,andCallBack: { (strng, type) in
//            print("type: \(type) strng: \(strng)")
//        }, normalFont: .systemFont(ofSize: 12, weight: UIFont.Weight.regular),hashTagFont: .systemFont(ofSize: 12, weight: UIFont.Weight.semibold),mentionFont: .systemFont(ofSize: 12, weight: UIFont.Weight.semibold))
        self.backView.isHidden = true
        self.tableView.isHidden = true
        self.tfDescribe.resignFirstResponder()
    }
    
    func observeEvent() {
        viewModel.eventHandler = { [weak self] event in
            guard let self else { return }
            
            switch event {
            case .error(let error):
                print("error",error)
                
            case .newSearchVideo(searchVideo: let searchVideo):
                print("newSearchVideo")
            case .newSearchUser(searchUser: let searchUser):
                print("newSearchVideo")
            case .newSearchSound(searchSound: let searchSound):
                print("newSearchVideo")
            case .newSearchHashtag(searchHashtag: let searchHashtag):
                if searchHashtag.code == 201 {
                    print("no response")
                }else {
                    if startPoint == 0 {
                        viewModel.searchHashtag?.msg?.removeAll()
                        viewModel.searchHashtag = searchHashtag
                        print("response")
                    }else {
                        if let newMessages = searchHashtag.msg {
                            viewModel.searchHashtag?.msg?.append(contentsOf: newMessages)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    if (self.viewModel.searchHashtag?.msg?.count ?? 0) >= 10 {
                        self.isNextPageLoad = true
                    }else {
                        self.isNextPageLoad = false
                    }
                    self.tableView.reloadData()
                }
                
            }
        }
    }
}
