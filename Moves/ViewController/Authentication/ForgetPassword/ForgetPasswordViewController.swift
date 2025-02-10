//
//  ForgetPasswordViewController.swift
//  Movess
//
//  Created by Mac on 01/11/2022.
//

import UIKit

class ForgetPasswordViewController: UIViewController,UITextFieldDelegate {
    var email  = ""
    
    //MARK: - OUTLET
    
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var btnReset: UIButton!
   
    @IBOutlet weak var lblError: UILabel!
    
    //MARK: - VARS
    
    private lazy var loader: UIView = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("Unable to access key window")
        }
        return Utility.shared.createActivityIndicator(keyWindow)
    }()
    
    
    //MARK: - VIEW DID LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfEmail.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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
    
    
   
    //MARK: - BUTTON ACTION
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        if !tfEmail.text!.isEmail() {
            self.lblError.isHidden = false
            self.lblError.text = "Enter a valid email address"
            return
        }
        self.email = tfEmail.text ?? ""
        self.lblError.isHidden = true
        FirebaseAuthService.shared.resetPassword(forEmail: email) { error in
            if let error = error {
                Utility.showMessage(message: error.localizedDescription, on: self.view)
                print("Error resetting password: \(error.localizedDescription)")
            } else {
                Utility.showMessage(message: "A password reset link has been sent to your email. Follow the instructions to reset your password.", on: self.view)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    for controller in self.navigationController!.viewControllers as Array {
                        if controller.isKind(of: SignUpViewController.self) {
                            _ =  self.navigationController!.popToViewController(controller, animated: true)
                            break
                        }
                    }
                }
            }
        }
    }
    
    
    //MARK: - TEXTFIELD DELEGATE
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        let textCount = textField.text?.count
    
        if textCount! > 3{
            btnReset.backgroundColor = UIColor.appColor(.theme)
            btnReset.setTitleColor(UIColor.appColor(.white), for: .normal)
        }else{
            btnReset.backgroundColor = UIColor.appColor(.barColor)
            btnReset.setTitleColor(UIColor.appColor(.white), for: .normal)
        }
    }
  

}
