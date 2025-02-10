//
//  RequestVerificationViewController.swift
// //
//
//  Created by Wasiq Tayyab on 14/06/2024.
//

import UIKit

class RequestVerificationViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let viewModel = RequestVerificationViewModel()
    private lazy var loader: UIView = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("Unable to access key window")
        }
        return Utility.shared.createActivityIndicator(keyWindow)
    }()
    let randomInt = Int.random(in: 0..<8)
    
    var fullname = ""
    var imgData = ""
    
    @IBOutlet weak var tfFulName: UITextField!
    @IBOutlet weak var lblApply: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.hideKeyboardWhenTappedAround()
        tfFulName.text = fullname
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
    }
  
    @IBAction func btnSelectImageAction(_ sender: Any) {
        ImagePickerManager().pickImage(self){ image in
            //here is the image

            self.imgData = (image.jpegData(compressionQuality: 0.1)?.base64EncodedString())!
            self.lblApply.text = "\(self.randomInt).png"
            
        }
    }
    

    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnSend(_ sender: Any) {
        if tfFulName.text == ""{
            Utility.showMessage(message: "Enter the full name", on: self.view)
            return
        }
        if imgData != ""{
            self.loader.isHidden = false
            let requestVerification = UserVerificationRequest(
                        userId: UserDefaultsManager.shared.user_id,
                        name: tfFulName.text!,
                        attachment: UserVerificationRequest.Attachment(fileData: imgData)
                    )
            viewModel.userVerificationRequest(parameters: requestVerification)
            self.loader.isHidden = false
            observeEvent()
        }else{
            Utility.showMessage(message: "File is Missing", on: self.view)
        }
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

            case .newUserVerificationRequest(userVerificationRequest: let userVerificationRequest):
                if userVerificationRequest.code == 200 {
                   
                    DispatchQueue.main.async {
                        self.loader.isHidden = true
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }

    
}
