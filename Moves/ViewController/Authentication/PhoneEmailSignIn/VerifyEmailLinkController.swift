//
//  VerifyEmailLinkController.swift
// //
//
//  Created by YS on 2024/9/10.
//

import UIKit
import FirebaseAuth

class VerifyEmailLinkController: UIViewController {

    let viewModel = UsernameViewModel()
    var password: String?
    var email: String?
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var loginButton: SubmitButton!
    private lazy var loader: UIView = {
        return Utility.shared.createActivityIndicator(view)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let email = email {
            self.tipsLabel.text = "We have sent an email to \(email) Please click on the link in that email for verification."
        }
        
        perform(#selector(submitEnable), with: nil, afterDelay: 10)
        
    }
    
    @objc func submitEnable() {
        loginButton.isEnabled = true
    }

    @IBAction func login() {
        if let user = Auth.auth().currentUser {
            user.reload { [weak self] error in
                guard let self = self else {
                    return
                }
                guard error == nil else {
                    return
                }
                if user.isEmailVerified {
                    user.getIDTokenForcingRefresh(true)  { [weak self] idToken, error in
                        guard let self = self else {
                            return
                        }
                        UserDefaultsManager.shared.idAuthToken = idToken ?? ""
                        if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
                            appdelegate.gotoHomeController()
                        }
                    }
                } else {
                    let tips = "We have sent an email to \(email ?? "") Please click on the link in that email for verification."
                    Utility.showMessage(message: tips, on: view)
                }
            }
            
        }
    }
    
    
    @IBAction func backClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}
