//
//  ReportDescriptionViewController.swift
// //
//
//  Created by Wasiq Tayyab on 23/09/2024.
//

import UIKit

class ReportDescriptionViewController: UIViewController, UITextViewDelegate {
    private lazy var loader: UIView = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            fatalError("Unable to access key window")
        }
        return Utility.shared.createActivityIndicator(keyWindow)
    }()

    var viewModel = ReasonViewModel()
    var videoId = ""
    var reportId = ""
    var titleText = ""
    var profileId = ""
    
    
    @IBOutlet var lblReason: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("videoId",videoId)
        print("profileId",profileId)
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == self.view {
                view.endEditing(true)
            }
        }
    }
   
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Tell us why this content is being reported. All supporting content should be relevant to the being reported"
            textView.textColor = UIColor.lightGray
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func setup() {
        self.lblReason.text = self.titleText
        let toolbar = ConstantManager.shared.getKeyboardToolbar()
        self.descriptionTextView.inputAccessoryView = toolbar
        self.descriptionTextView.delegate = self
        self.descriptionTextView.textContainer.lineFragmentPadding = 0
        self.descriptionTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    @IBAction func submitButtonPressed(_ sender: UIButton) {
        self.loader.isHidden = false
        let request = ReportVideoRequest(userId: UserDefaultsManager.shared.user_id.toInt() ?? 0, videoId: self.videoId, reportReasonId: self.reportId.toInt() ?? 0, description: self.descriptionTextView.text, reportUserId: self.profileId)
        print("reportVideo",request)
        
        if profileId == "0"{
            self.viewModel.reportVideo(parameter: request)
        }else {
            self.viewModel.reportUser(parameter: request)
        }
       
        
        self.observeEvent()
    }
    
    func observeEvent() {
        self.viewModel.eventHandler = { [weak self] event in
            guard let self = self else { return }

            switch event {
            case .error(let error):
                print("error", error)
                DispatchQueue.main.async {
                    if let error = error {
                        if let dataError = error as? Moves.DataError {
                            switch dataError {
                            case .invalidResponse:
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .invalidURL:
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .network:
                                Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                            case .invalidData:
                                print("invalidData")
                            case .decoding:

                                print("decoding")
                            }
                        } else {
                            if isDebug {
                                Utility.showMessage(message: "Something went wrong. Please try again", on: self.view)
                            }
                        }
                    }
                }
            case .showReportReasons(showReportReasons: _):
                print("showReportReasons")
            case .reportVideo(reportVideo: let reportVideo):
                DispatchQueue.main.async {
                    print("reportVideo",reportVideo)
                    self.loader.isHidden = true
                    if reportVideo.code == 200 {
                        NotificationCenter.default.post(name: .moveToNextVideo, object: nil)

                        if let navigationController = self.navigationController {
                            navigationController.dismiss(animated: false) {
                                navigationController.popToRootViewController(animated: true)
                            }
                        }

                    } else {
                        Utility.showMessage(message: "Something Went Wrong", on: self.view)
                    }
                }
            case .repostVideo(repostVideo: let repostVideo):
                print("repostVideo")
            case .repostUser(repostUser: let repostUser):
                DispatchQueue.main.async {
                    print("reportVideo",repostUser)
                    self.loader.isHidden = true
                    if repostUser.code == 200 {
                        if let navigationController = self.navigationController {
                            navigationController.dismiss(animated: false) {
                                navigationController.popToRootViewController(animated: true)
                            }
                        }

                    } else {
                        Utility.showMessage(message: "Something Went Wrong", on: self.view)
                    }
                }
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
