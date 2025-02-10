//
//  UpdatePasswordViewController.swift
// //
//
//  Created by Wasiq Tayyab on 26/06/2024.
//

import UIKit
import FirebaseAuth

class UpdatePasswordViewController: UIViewController {
    
    var isVisible = true
    var isVisible1 = true
    var isVisible2 = true
    
    @IBOutlet weak var tfNewPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    @IBOutlet weak var btnConfirmPasswordEye: UIButton!
    @IBOutlet weak var btnPasswordEye: UIButton!
    
    @IBOutlet weak var tfOldPasswordEye: UIButton!
    @IBOutlet weak var tfOldPassword: UITextField!
    
    @IBOutlet weak var lblError: UILabel!
    
    @IBOutlet weak var btnUpdate: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        tfOldPassword.placeholder = "Old Password"
        tfNewPassword.placeholder = "New Password"
        tfConfirmPassword.placeholder = "Confirm Password"
        tfOldPassword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        tfNewPassword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        tfConfirmPassword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.hideKeyboardWhenTappedAround()
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
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func passwordButtonPressed(_ sender: UIButton) {
        if sender.tag == 0{
            if isVisible == false {
                tfNewPassword.isSecureTextEntry = true
                btnPasswordEye.setImage(UIImage(named: "unvisible"), for: .normal)
                isVisible = true
            }else {
                tfNewPassword.isSecureTextEntry = false
                btnPasswordEye.setImage(UIImage(named: "visible"), for: .normal)
                isVisible = false
            }
        }else if sender.tag == 1{
            if isVisible1 == false {
                tfConfirmPassword.isSecureTextEntry = true
                btnConfirmPasswordEye.setImage(UIImage(named: "unvisible"), for: .normal)
                isVisible1 = true
            }else {
                tfConfirmPassword.isSecureTextEntry = false
                btnConfirmPasswordEye.setImage(UIImage(named: "visible"), for: .normal)
                isVisible1 = false
            }
        }else {
            if isVisible2 == false {
                tfOldPassword.isSecureTextEntry = true
                tfOldPasswordEye.setImage(UIImage(named: "unvisible"), for: .normal)
                isVisible2 = true
            }else {
                tfOldPassword.isSecureTextEntry = false
                tfOldPasswordEye.setImage(UIImage(named: "visible"), for: .normal)
                isVisible2 = false
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.lblError.isHidden = true
        let newPasswordCount = tfNewPassword.text?.count ?? 0
        let confirmPasswordCount = tfConfirmPassword.text?.count ?? 0
        let oldPasswordCount = tfOldPassword.text?.count ?? 0
        let isValidPassword = newPasswordCount >= 6 && confirmPasswordCount >= 6 && oldPasswordCount >= 6
        if isValidPassword {
            btnUpdate.backgroundColor = UIColor.appColor(.theme)
            btnUpdate.setTitleColor(UIColor.appColor(.white), for: .normal)
        } else {
            btnUpdate.backgroundColor = UIColor.appColor(.barColor)
            btnUpdate.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    @IBAction func updateButtonPressed(_ sender: UIButton) {
        guard let oldPassword = tfOldPassword.text, !oldPassword.isEmpty else {
            self.lblError.isHidden = false
            self.lblError.text = "Please enter your old password"
            return
        }

        guard let newPassword = tfNewPassword.text, !newPassword.isEmpty else {
            self.lblError.isHidden = false
            self.lblError.text = "Please enter your new password"
            return
        }

        guard let confirmPassword = tfConfirmPassword.text, !confirmPassword.isEmpty else {
            self.lblError.isHidden = false
            self.lblError.text = "Please enter your confirm password"
            return
        }

        guard newPassword.count >= 6 else {
            self.lblError.isHidden = false
            self.lblError.text = "New Password must be at least 6 characters"
            return
        }

        guard confirmPassword.count >= 6 else {
            self.lblError.isHidden = false
            self.lblError.text = "Confirm Password must be at least 6 characters"
            
            return
        }

        guard newPassword == confirmPassword else {
            self.lblError.isHidden = false
            self.lblError.text = "New Password and Confirm Password do not match"
            return
        }
        
        guard let user = Auth.auth().currentUser else {
            self.lblError.isHidden = false
            self.lblError.text = "No user is available"
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: user.email!, password: oldPassword)

        user.reauthenticate(with: credential) { authResult, error in
            if let error = error {
                self.lblError.isHidden = false
                self.lblError.text = "Your old password is incorrect"
               
                print("Failed to re-authenticate: \(error.localizedDescription)")
                return
            }
            
            FirebaseAuthService.shared.updatePassword(newPassword: newPassword) { error in
                if let error = error {
                    self.lblError.text = "Failed to update password"
                    print("Failed to update password: \(error.localizedDescription)")
                } else {
                    Utility.showMessage(message: "Password updated successfully", on: self.view)
                    NotificationCenter.default.post(name: NSNotification.Name("changeNumber"), object: nil, userInfo: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        if let profileViewController = self.navigationController?.viewControllers.first(where: { $0 is ManageAccountViewController}) {
                            self.navigationController?.popToViewController(profileViewController, animated: true)
                        }
                    }
                }
            }
        }
    }
    

    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
