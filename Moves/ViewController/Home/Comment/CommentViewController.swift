//
//  CommentViewController.swift
// //
//
//  Created by Wasiq Tayyab on 02/07/2024.
//

import UIKit
import GrowingTextView
import SDWebImage

protocol CommentCountUpdateDelegate {
    func CommentCountUpdateDelegate(commentCount : Int)
    
}

class CommentViewController: UIViewController,GrowingTextViewDelegate {
    
    var isLoadingData = false
    var hasMoreData = true
    
    var postCommentOnVideo: CommentResponse?
    var showVideoComments: CommentResponse?
    let viewModel = CommentViewModel()
    var startPoint = 0
    var isNextPageLoad = false
    var videoId = 0
    var profileImage = ""
    var username = ""
    var commentID = 0
    var commentDelegate : CommentCountUpdateDelegate?
    
    var day = ""
    var day1 = ""
    var isViewRow = true
    
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var bottomImageView: NSLayoutConstraint!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputToolbar: UIView!
    @IBOutlet weak var commentTextView: GrowingTextView!
    
    @IBOutlet weak var noDataStackView: UIStackView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var imageProfile: CustomImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configuration()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            if touch.view == self.view || touch.view == self.tableView{
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    private func setup() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CommentHeaderTableViewCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "CommentHeaderTableViewCell")
        tableView.register(UINib(nibName: "CommentRowTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentRowTableViewCell")
        
        self.imageProfile.sd_setImage(with: URL(string:(UserDefaultsManager.shared.profileUser)), placeholderImage: UIImage(named: "videoPlaceholder"))
        
        commentTextView.placeholder = "Add a comment for " + username
        commentTextView.delegate = self
        commentTextView.layer.cornerRadius = 17
        commentTextView.layer.borderWidth = 1.0
        commentTextView.layer.borderColor = UIColor.appColor(.lightGrey)?.cgColor
        commentTextView.contentInset = UIEdgeInsets(top: 5, left: 11, bottom: 5, right: 40)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: NSNotification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if #available(iOS 11, *) {
                if keyboardHeight > 0 {
                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
                }
            }
            
            textViewBottomConstraint.constant = keyboardHeight + 40
            bottomImageView.constant = keyboardHeight + 40
            view.layoutIfNeeded()
        }
    }
    
    
    @objc func tapGestureHandler() {
        view.endEditing(true)
    }
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.05, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: [.curveLinear], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count != 0 {
            btnSend.isHidden = false
        }else {
            btnSend.isHidden = true
        }
    }
    
    @IBAction func sendCommentButtonPressed(_ sender: UIButton) {
        self.isViewRow = true
        self.view.endEditing(true)
        self.btnSend.isHidden = true

        if commentID != 0 {
            let postComment = PostCommentReplyRequest(comment: commentTextView.text!, commentId: commentID,videoId: videoId)
            print("Reply Post Comment",postComment)
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.viewModel.postCommentReply(parameters: postComment)
                self?.observeEvent()
                Task {
                    self?.commentTextView.placeholder = await "Add a comment for " + (self?.username ?? "")
                    self?.commentID = 0
                }
            }
            
        } else {
            let sendComment = PostCommentRequest(userId: UserDefaultsManager.shared.user_id.toInt() ?? 0, videoId: videoId, comment: commentTextView.text!)
            
            print("Post Comment",sendComment)
            
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.viewModel.postCommentOnVideo(parameters: sendComment)
                
                DispatchQueue.main.async {
                    self?.observeEvent()
                    self?.commentTextView.placeholder = "Add a comment for " + (self?.username ?? "")
                }
            }
        }
        self.commentTextView.text = ""
    }

    
    @objc func btnProfilePressed(sender : UITapGestureRecognizer){
        let user = self.showVideoComments?.msg?[sender.view?.tag ?? 0].user
        
        if user?.id == nil || user?.id == 0 {
            Utility.showMessage(message: "Something went wrong. Please try later", on: self.view)
            return
        }
        if UserDefaultsManager.shared.user_id == user?.id?.toString() {
            let story = UIStoryboard(name: "Main", bundle: nil)
            if let tabBarController = story.instantiateViewController(withIdentifier: "TabbarViewController") as? UITabBarController {
                tabBarController.selectedIndex = 4
                let nav = UINavigationController(rootViewController: tabBarController)
                nav.navigationBar.isHidden = true
                self.view.window?.rootViewController = nav
            }
        }else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let myViewController = storyboard.instantiateViewController(withIdentifier: "OtherProfileViewController")as! OtherProfileViewController
            myViewController.userResponse = user
            myViewController.hidesBottomBarWhenPushed = true
            myViewController.otherUserId = user?.id?.toString() ?? ""
            self.navigationController?.pushViewController(myViewController, animated: true)
        }
        
    }
    
    @objc func likedButtonPressed(_ sender: UIButton) {
        let header = tableView.headerView(forSection: sender.tag) as? CommentHeaderTableViewCell
        let comment =  self.showVideoComments?.msg?[sender.tag].videoComment.id.intValue ?? 0
        let currentImage = header?.btnHeart.currentImage
        playLightImpactHaptic()
        if currentImage == UIImage(named: "Heart 1") {
            var count = header?.lblCommentCount.text?.toInt()
            count! += 1
            header?.lblCommentCount.text = count?.toString()
            header?.btnHeart.setImage(UIImage(named: "heartfilled"), for: .normal)
            
            
            self.showVideoComments?.msg?[sender.tag].videoComment.like = .int(1)
            self.showVideoComments?.msg?[sender.tag].videoComment.likeCount = .int(count ?? 0)
        } else {
            var count = header?.lblCommentCount.text?.toInt()
            count! -= 1
            header?.lblCommentCount.text = count?.toString()
            header?.btnHeart.setImage(UIImage(named: "Heart 1"), for: .normal)
            
            
            self.showVideoComments?.msg?[sender.tag].videoComment.like = .int(1)
            self.showVideoComments?.msg?[sender.tag].videoComment.likeCount = .int(count ?? 0)
        }
        let likedComment = LikeCommentRequest(commentId: comment, userId: UserDefaultsManager.shared.user_id)
        viewModel.likeComment(parameters: likedComment)
        observeEvent()
    }
    
    
    @objc func likedButtonPressed1(_ sender: UIButton) {
        guard let indexPath = tableView.indexPathForRow(at: sender.convert(sender.bounds.origin, to: tableView)) else {
            return
        }
        
        guard let header = tableView.cellForRow(at: indexPath) as? CommentRowTableViewCell else {
            return
        }
        
        guard let comment = self.showVideoComments?.msg?[indexPath.section].videoCommentReply?[sender.tag].videoComment.id else {
            return
        }
        
        playLightImpactHaptic()
        
        if header.btnHeart.currentImage == UIImage(named: "heartfilled") {
            if let currentCount = header.lblCommentCount.text?.toInt() {
                let newCount = currentCount - 1
                header.lblCommentCount.text = newCount.toString()
                header.btnHeart.setImage(UIImage(named: "Heart 1"), for: .normal)
                self.showVideoComments?.msg?[indexPath.section].videoCommentReply?[sender.tag].videoComment.like = .int(0)
                self.showVideoComments?.msg?[indexPath.section].videoCommentReply?[sender.tag].videoComment.likeCount = .int(newCount)
            }
        } else {
            if let currentCount = header.lblCommentCount.text?.toInt() {
                let newCount = currentCount + 1
                header.lblCommentCount.text = newCount.toString()
                header.btnHeart.setImage(UIImage(named: "heartfilled"), for: .normal)
                self.showVideoComments?.msg?[indexPath.section].videoCommentReply?[sender.tag].videoComment.like = .int(1)
                self.showVideoComments?.msg?[indexPath.section].videoCommentReply?[sender.tag].videoComment.likeCount = .int(newCount)
            }
        }
        
        let likeReplyComments = LikeReplyCommentsRequest(commentReplyId: comment.intValue!)
        viewModel.likeReplyComments(parameters: likeReplyComments)
        observeEvent()
    }
    
}

//MARK: -  TableView
extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return showVideoComments?.msg?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let videoComments = showVideoComments?.msg else {
            return 0
        }
        
        if videoComments[section].collapsed ?? true {
            return 0
        } else {
            return videoComments[section].videoCommentReply?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  =  tableView.dequeueReusableCell(withIdentifier: "CommentRowTableViewCell") as! CommentRowTableViewCell
        
        
        if (self.showVideoComments?.msg?[indexPath.section].videoCommentReply?.count ?? 0) - 1 == indexPath.row {
            cell.btnViewMoreReply.isHidden = false
            cell.lineView.isHidden = false
        }else {
            cell.lineView.isHidden = true
            cell.btnViewMoreReply.isHidden = true
        }
        
        let comment = self.showVideoComments?.msg?[indexPath.section].videoCommentReply?[indexPath.row].videoComment
        let user = self.showVideoComments?.msg?[indexPath.section].videoCommentReply?[indexPath.row].user
        
        let timeZone = getTimeZoneOffset()
        if let updatedDateString = adjustDate(for: comment?.created ?? "", timeZoneOffset: timeZone) {
            let difference = timeDifference(from: updatedDateString)
            day = difference ?? ""
        }
        
        let formattedText = formatText(user?.username ?? "", characterLimit: 115, addString: day)
        
        cell.lblName.attributedText = formattedText
        
        cell.lblComment.text = comment?.comment ?? ""
        let format = Utility.shared.formatPoints(num: comment?.likeCount.intValue?.toDouble() ?? 0.0)
        cell.lblCommentCount.text = format
        if comment?.like?.intValue == 0 {
            cell.btnHeart.setImage(UIImage(named: "Heart 1"), for: .normal)
        }else {
            cell.btnHeart.setImage(UIImage(named: "heartfilled"), for: .normal)
        }
        
        cell.imgProfile.sd_setImage(with: URL(string: user?.profilePic ?? ""), placeholderImage: UIImage(named:"profile1"))
        let gestureUserImg = UITapGestureRecognizer(target: self, action:  #selector(self.btnProfilePressed(sender:)))
        cell.imgProfile.tag = indexPath.row
        gestureUserImg.view?.tag = indexPath.row
        cell.imgProfile.isUserInteractionEnabled = true
        cell.imgProfile.addGestureRecognizer(gestureUserImg)
        
        cell.btnHeart.addTarget(self, action: #selector(likedButtonPressed1(_:)), for: .touchUpInside)
        cell.btnHeart.tag = indexPath.row
        
        cell.btnLargeLike.addTarget(self, action: #selector(likedButtonPressed1(_:)), for: .touchUpInside)
        cell.btnLargeLike.tag = indexPath.row
        
        cell.btnViewMoreReply.addTarget(self, action: #selector(self.hideRow1(sectionButton:)), for: .touchUpInside)
        cell.btnViewMoreReply.tag = indexPath.section
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress1(_:)))
        cell.contentView.addGestureRecognizer(longPressGesture)
        cell.contentView.tag = indexPath.row
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.showVideoComments?.msg?[section].videoCommentReply?.count == 0 {
            return UITableView.automaticDimension
        }else {
            if isViewRow == true {
                return UITableView.automaticDimension
            }else {
                return UITableView.automaticDimension
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat{
        if self.showVideoComments?.msg?[section].videoCommentReply?.count == 0 {
            return UITableView.automaticDimension
        }else {
            if isViewRow == true {
                return UITableView.automaticDimension
            }else {
                return UITableView.automaticDimension
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CommentHeaderTableViewCell")as? CommentHeaderTableViewCell
        let comment = self.showVideoComments?.msg?[section].videoComment
        let user = self.showVideoComments?.msg?[section].user
        
        let timeZone = getTimeZoneOffset()
        if let updatedDateString = adjustDate(for: comment?.created ?? "", timeZoneOffset: timeZone) {
            let difference = timeDifference(from: updatedDateString)
            day = difference ?? ""
        }
        
        let formattedText = formatText(user?.username ?? "", characterLimit: 115, addString: day)
        
        header?.lblName.attributedText = formattedText
        
        
        header?.lblComment.text = comment?.comment ?? ""
        let format = Utility.shared.formatPoints(num: comment?.likeCount.intValue?.toDouble() ?? 0.0)
        header?.lblCommentCount.text = format
        if comment?.like?.intValue == 0 {
            header?.btnHeart.setImage(UIImage(named: "Heart 1"), for: .normal)
        }else {
            header?.btnHeart.setImage(UIImage(named: "heartfilled"), for: .normal)
        }
        
        if self.showVideoComments?.msg?[section].videoCommentReply?.count == 0 {
            header?.btnViewMoreReply.isHidden = true
            header?.moreReplyView.isHidden = true
        }else {
            if isViewRow == true {
                header?.btnViewMoreReply.isHidden = false
                let title = "View " + (self.showVideoComments?.msg?[section].videoCommentReply?.count.toString() ?? "") + " more reply"
                header?.btnViewMoreReply.setTitle(title, for: .normal)
                header?.moreReplyView.isHidden = false
            }else {
                header?.btnViewMoreReply.isHidden = true
                header?.moreReplyView.isHidden = true
            }
        }
        
        header?.imgProfile.sd_setImage(with: URL(string: user?.profilePic ?? ""), placeholderImage: UIImage(named:"profile1"))
        let gestureUserImg = UITapGestureRecognizer(target: self, action:  #selector(self.btnProfilePressed(sender:)))
        header?.imgProfile.tag = section
        gestureUserImg.view?.tag = section
        header?.imgProfile.isUserInteractionEnabled = true
        header?.imgProfile.addGestureRecognizer(gestureUserImg)
        
        header?.btnHeart.addTarget(self, action: #selector(likedButtonPressed(_:)), for: .touchUpInside)
        header?.btnHeart.tag = section
        
        header?.btnLargeLike.addTarget(self, action: #selector(likedButtonPressed(_:)), for: .touchUpInside)
        header?.btnLargeLike.tag = section
        
        header?.btnReply.tag =  section
        header?.btnReply.addTarget(self, action: #selector(self.btnReply(section:)), for: .touchUpInside)
        
        header?.btnViewMoreReply.addTarget(self, action: #selector(self.hideRow(sectionButton:)), for: .touchUpInside)
        header?.btnViewMoreReply.tag = section
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5 // Customize the duration as needed
        header?.addGestureRecognizer(longPressGesture)
        header?.tag = section
        
        return header
    }
   
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section == (self.showVideoComments?.msg?.count ?? 0) - 8 && hasMoreData {
            addTableFooterLoader()
            self.initViewModel()
        }
    }
    
    private func addTableFooterLoader() {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.startAnimating()
        activityIndicator.color = UIColor(named: "theme")
        activityIndicator.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView?.isHidden = false
    }
    
    private func removeTableFooterLoader() {
        tableView.tableFooterView = nil
    }
    
    @objc func hideRow1(sectionButton: UIButton) {
        guard let videoComments = self.showVideoComments?.msg else { return }
        
        let sectionIndex = sectionButton.tag
        
        let collapsed = !(videoComments[sectionIndex].collapsed ?? true)
        self.showVideoComments?.msg?[sectionIndex].collapsed = collapsed
        isViewRow = true
        tableView.reloadSections(IndexSet(integer: sectionIndex), with: .automatic)
        
        if !collapsed, let rowCount = videoComments[sectionIndex].videoCommentReply?.count {
            var indexPaths: [IndexPath] = []
            for row in 0..<rowCount {
                indexPaths.append(IndexPath(row: row, section: sectionIndex))
            }
            
            tableView.reloadRows(at: indexPaths, with: .automatic)
        }
    }
    
    @objc func hideRow(sectionButton: UIButton) {
        guard let videoComments = self.showVideoComments?.msg else {
            return
        }
        
        let sectionIndex = sectionButton.tag
        
        let collapsed = !(videoComments[sectionIndex].collapsed ?? true)
        if !collapsed {
            self.commentID = videoComments[sectionIndex].videoComment.id.intValue ?? 0
        } else {
            self.commentID = 0
        }
        isViewRow = false
        self.showVideoComments?.msg?[sectionIndex].collapsed = collapsed
        
        tableView.reloadSections(IndexSet(integer: sectionIndex), with: .none)
        if !collapsed {
            guard let rowCount = videoComments[sectionIndex].videoCommentReply?.count else {
                return
            }
            
            var indexPaths: [IndexPath] = []
            for row in 0..<rowCount {
                indexPaths.append(IndexPath(row: row, section: sectionIndex))
            }
            
            tableView.reloadRows(at: indexPaths, with: .none)
        }
        // Debug prints
        print("collapsed: \(collapsed)")
        print("commentID: \(commentID)")
    }
    
    
    @objc func btnReply(section:UIButton){
        self.commentTextView.becomeFirstResponder()
        guard let user = self.showVideoComments?.msg?[section.tag].user.username else { return }
        guard let comment = self.showVideoComments?.msg?[section.tag].videoComment.id else { return }
        self.commentID = comment.intValue ?? 0
        
        self.commentTextView.text = "@" + user + " "
    }
    
    @objc func handleLongPress1(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        
        let location = gestureRecognizer.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: location) else { return }
        
        let section = indexPath.section
        let row = indexPath.row
        
        guard let user = self.showVideoComments?.msg?[section].videoCommentReply?[row].user else { return }
        
        if UserDefaultsManager.shared.user_id == user.id?.toString() {
            presentDeleteCommentAlert1(for: indexPath)
        }
    }
    
    
    func presentDeleteCommentAlert1(for indexPath: IndexPath) {
        guard let comment = self.showVideoComments?.msg?[indexPath.section].videoCommentReply?[indexPath.section].videoComment else {
            Utility.showMessage(message: "Something went wrong. Please try later", on: self.view)
            return
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete Comment", style: .destructive) { [weak self] _ in
            self?.deleteComment1(comment, at: indexPath)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = self.view.bounds
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteComment1(_ comment: VideoComment, at indexPath: IndexPath) {
        let deleteAccount = DeleteVideoCommentRequest(id: comment.id.intValue ?? 0)
        viewModel.deleteVideoCommentReply(parameters: deleteAccount)
        print("deleteAccount",deleteAccount)
        DispatchQueue.main.async {
            self.showVideoComments?.msg?[indexPath.section].videoCommentReply?.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.observeEvent()
        }
    }
    
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        print("Long press detected in section \(gestureRecognizer.view?.tag)")
        let section = gestureRecognizer.view?.tag ?? 0
        guard let user = self.showVideoComments?.msg?[section].user else { return }
        
        if UserDefaultsManager.shared.user_id == user.id?.toString() {
            presentDeleteCommentAlert(for: IndexPath(row: 0, section: section))
        }
    }
    
    func presentDeleteCommentAlert(for indexPath: IndexPath) {
        guard let comment = self.showVideoComments?.msg?[indexPath.section].videoComment else {
            Utility.showMessage(message: "Something went wrong. Please try later", on: self.view)
            return
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete Comment", style: .destructive) { [weak self] _ in
            self?.deleteComment(comment, at: indexPath)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = self.view.bounds
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteComment(_ comment: VideoComment, at indexPath: IndexPath) {
        let deleteAccount = DeleteVideoCommentRequest(id: comment.id.intValue ?? 0)
        viewModel.deleteVideoComment(parameters: deleteAccount)
        
        DispatchQueue.main.async {
            self.showVideoComments?.msg?.remove(at: indexPath.section)
            self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            self.observeEvent()
        }
    }
}

extension CommentViewController {
    
    func configuration() {
        setup()
        initViewModel()
    }
    
    func initViewModel() {
        guard !isLoadingData && hasMoreData else { return }
        isLoadingData = true
        
        let showComment = CommentRequest(
            videoId: videoId,
            comment: "",
            startingPoint: startPoint
        )
        
        print("showComment",showComment)
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.viewModel.showVideoComments(parameters: showComment)
            
            DispatchQueue.main.async {
                self?.observeEvent()
            }
        }
    }
    
    
    func observeEvent() {
        DispatchQueue.main.async {
            self.tableView.isHidden = false
        }
        
        viewModel.eventHandler = { [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .error(let error):
                DispatchQueue.main.async {
                    if let error = error {
                        if let dataError = error as? Moves.DataError {
                            switch dataError {
                            case .invalidResponse, .invalidURL, .network(_):
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
                
            case .newPostCommentOnVideo(postCommentOnVideo: let postCommentOnVideo):
                DispatchQueue.global(qos: .background).async {
                    print("postCommentOnVideo", postCommentOnVideo.code)
                    if postCommentOnVideo.code == 200 {
                        DispatchQueue.main.async {
                            self.commentDelegate?.CommentCountUpdateDelegate(commentCount: 1)
                            let showComment = CommentRequest(videoId: self.videoId, comment: "", startingPoint: self.startPoint)
                            print(showComment)
                            
                            self.viewModel.showVideoComments(parameters: showComment)
                            self.observeEvent()
                        }
                    }
                }
                
            case .newShowVideoComments(showVideoComments: let showVideoComments):
                DispatchQueue.global(qos: .background).async {
                    DispatchQueue.main.async {
                        if showVideoComments.code == 200 {
                            if self.startPoint == 0 {
                                self.noDataStackView.isHidden = true
                                self.viewModel.showVideoComments?.msg?.removeAll()
                                self.showVideoComments?.msg?.removeAll()
                                self.viewModel.showVideoComments = showVideoComments
                                self.showVideoComments = showVideoComments
                                
                                self.startPoint += 1
                            } else {
                                if let newMessages = showVideoComments.msg {
                                    self.viewModel.showVideoComments?.msg?.append(contentsOf: newMessages)
                                    self.showVideoComments?.msg?.append(contentsOf: newMessages)
                                    self.startPoint += 1
                                }else {
                                    self.hasMoreData = false
                                }
                            }
                            
                            self.removeTableFooterLoader()
                            
                          
                            
                            self.isNextPageLoad = (self.showVideoComments?.msg?.count ?? 0) >= 20
                            self.tableView.reloadData()
                            
                            self.isLoadingData = false
                        } else {
                            if self.startPoint == 0 {
                                self.showVideoComments?.msg?.removeAll()
                                self.tableView.reloadData()
                                self.noDataStackView.isHidden = false
                            } else {
                                self.hasMoreData = false
                                self.isNextPageLoad = false
                            }
                        }
                    }
                }
                
            case .newLikeComment(likeComment: let likeComment):
                DispatchQueue.global(qos: .background).async {
                    print("likeComment", likeComment.code)
                }
                
            case .newDeleteVideoComment(deleteVideoComment: let deleteVideoComment):
                DispatchQueue.global(qos: .background).async {
                    print("deleteVideoComment", deleteVideoComment.code)
                    if deleteVideoComment.code == 200 {
                        DispatchQueue.main.async {
                            self.commentDelegate?.CommentCountUpdateDelegate(commentCount: 1)
                            self.noDataStackView.isHidden = (self.showVideoComments?.msg?.count ?? 0) > 0
                        }
                    }
                }
                
            case .newPostCommentReply(postCommentReply: let postCommentReply):
                DispatchQueue.global(qos: .background).async {
                    print("postCommentReply", postCommentReply.code)
                    if postCommentReply.code == 200 {
                        DispatchQueue.main.async {
                            let showComment = CommentRequest(videoId: self.videoId, comment: "", startingPoint: self.startPoint)
                            self.viewModel.showVideoComments(parameters: showComment)
                            self.observeEvent()
                        }
                    }
                }
                
            case .newLikeReplyComments(likeReplyComments: let likeReplyComments):
                DispatchQueue.global(qos: .background).async {
                    print("likeReplyComments", likeReplyComments.code)
                }
                
            case .newDeleteVideoCommentReply(deleteVideoCommentReply: let deleteVideoCommentReply):
                DispatchQueue.global(qos: .background).async {
                    print("deleteVideoCommentReply", deleteVideoCommentReply.code)
                }
            }
        }
    }
    
}
