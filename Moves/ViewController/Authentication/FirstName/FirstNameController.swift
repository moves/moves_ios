//
//  FirstNameController.swift
// //
//
//  Created by YS on 2024/9/7.
//

import UIKit
import FirebaseAuth

class FirstNameController: UIViewController {

    var phone: String?
    var email: String?
    var birthday: String?
    var userName: String?
    var social_id: String?
    
    var social: String?
    private lazy var loader: UIView = {
        return Utility.shared.createActivityIndicator(view)
    }()
    let viewModel = UsernameViewModel()
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var nextButton: SubmitButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTextField.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
    }
    
    @objc func textFieldsDidChange() {
        let isTextField1Filled = !(firstNameTextField.text?.isEmpty ?? true)
        let isTextField2Filled = !(lastNameTextField.text?.isEmpty ?? true)
        nextButton.isEnabled = isTextField1Filled && isTextField2Filled
    }
    
    @IBAction func confirm(_ sender: Any) {
        
        guard let firstName = self.firstNameTextField.text, !firstName.isEmpty else {
            return
        }
        
        guard let lastName = self.lastNameTextField.text, !lastName.isEmpty else {
            return
        }
        
        if social == ""{
            social = "phone"
        }
        
        let registerSocialRequest = RegisterUserAppRequest(username: userName ?? "", dob: birthday ?? "", firstName: firstName, lastName: lastName, email: email ?? "", phone: phone ?? "", socialID: social_id ?? "", authToken: UserDefaultsManager.shared.authToken, deviceToken: UserDefaultsManager.shared.device_token, socialType: social ?? "")
        viewModel.registerEmail(parameters: registerSocialRequest)
        print("registerSocialRequest",registerSocialRequest)
        self.observeEvent()
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
                    self.loader.isHidden = true
                }
                
            case .newCheckUsername(checkUsername: let checkUsername):
                print("checkUsername")
            case .newRegisterPhone(registerPhone: let registerPhone):
                DispatchQueue.main.async {
                    self.loader.isHidden = true
                    if registerPhone.code == 200 {
                        UserObject.shared.Objresponse(userID:registerPhone.msg?.user.id?.toString() ?? "",username: registerPhone.msg?.user.username ?? "",authToken: UserDefaultsManager.shared.authToken,profileUser: registerPhone.msg?.user.profilePic ?? "",first_name: registerPhone.msg?.user.firstName ?? "" ,last_name:registerPhone.msg?.user.lastName ?? "" , isLogin: false, businessProfile: registerPhone.msg?.user.business ?? 0,email:registerPhone.msg?.user.email ?? "")
                        UserDefaultsManager.shared.user_id = registerPhone.msg?.user.id?.toString() ?? ""
                        self.jumpInterest()
                    }else {
                        Utility.showMessage(message: registerPhone.message ?? "", on: self.view)
                    }
                }
            }
        }
    }
    
    func jumpInterest() {
        if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
            appdelegate.gotoHomeController()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}
