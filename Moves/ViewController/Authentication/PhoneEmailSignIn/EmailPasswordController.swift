//
//  EmailPasswordController.swift
// //
//
//  Created by YS on 2024/9/9.
//

import UIKit
import FirebaseAuth

class EmailPasswordController: UIViewController {

    var email: String = ""
    @IBOutlet weak var pwdVisableButton01: UIButton!
    @IBOutlet weak var pwdVisableButton02: UIButton!
    @IBOutlet weak var pwdCorrect01: UIButton!
    @IBOutlet weak var pwdCorrect02: UIButton!
    @IBOutlet weak var pwdCorrect03: UIButton!
    @IBOutlet weak var nextButton: SubmitButton!
    @IBOutlet weak var errorTipLabel: UILabel!

    @IBOutlet weak var pwdStrenghtView: UIView!
    @IBOutlet weak var pwdStrenghtViewLength: NSLayoutConstraint!
    @IBOutlet weak var pwdTextField01: UITextField!
    @IBOutlet weak var pwdTextField02: UITextField!
    
    let viewModel = UsernameViewModel()
    private lazy var loader: UIView = {
        return Utility.shared.createActivityIndicator(view)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        pwdTextField01.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
        pwdTextField02.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)

    }
    
    @objc func textFieldsDidChange() {
        errorTipLabel.text = nil
        if let pwd = pwdTextField01.text {
            pwdCorrect01.isSelected = verifyCharactersNum(password: pwd)
            pwdCorrect02.isSelected = verifyLetterAndNum(password: pwd)
            pwdCorrect03.isSelected = verifySpecailCharacter(password: pwd)
        }
        
        pwdStrenghtViewLength.constant = 5
        pwdStrenghtView.backgroundColor = .black
        let padding = 13.0
        if pwdCorrect01.isSelected || pwdCorrect02.isSelected || pwdCorrect03.isSelected{
            pwdStrenghtViewLength.constant = (UIDevice.ex.screenWidth - padding*2)/3.0
            pwdStrenghtView.backgroundColor = UIColor(hex: "#20B462")
        }
        
        let count = (pwdCorrect01.isSelected ? 1 : 0) + (pwdCorrect02.isSelected ? 1 : 0) + (pwdCorrect03.isSelected ? 1 : 0)
        if count == 2 {
            pwdStrenghtViewLength.constant = (UIDevice.ex.screenWidth - padding*2)/3.0 * 2
            pwdStrenghtView.backgroundColor = UIColor(hex: "#20B462")
        }
        
        if pwdCorrect01.isSelected, pwdCorrect02.isSelected, pwdCorrect03.isSelected {
            pwdStrenghtViewLength.constant = (UIDevice.ex.screenWidth - padding*2)/3.0 * 3
            pwdStrenghtView.backgroundColor = UIColor(hex: "#20B462")
        }
        
        if pwdCorrect01.isSelected, pwdCorrect02.isSelected, pwdCorrect03.isSelected {
            let isTextField1Filled = !(pwdTextField01.text?.isEmpty ?? true)
            let isTextField2Filled = !(pwdTextField02.text?.isEmpty ?? true)
            nextButton.isEnabled = isTextField1Filled && isTextField2Filled
        } else {
            nextButton.isEnabled = false
        }
    }

    func setupViews() {
        pwdVisableButton01.setImage(UIImage(named: "pwd_invisable"), for: .normal)
        pwdVisableButton01.setImage(UIImage(named: "pwd_visable"), for: .selected)
        
        pwdVisableButton02.setImage(UIImage(named: "pwd_invisable"), for: .normal)
        pwdVisableButton02.setImage(UIImage(named: "pwd_visable"), for: .selected)
        
        pwdCorrect01.setImage(UIImage(named: "pwd_complete"), for: .normal)
        pwdCorrect01.setImage(UIImage(named: "pwd_correct_complete"), for: .selected)
        pwdCorrect01.setTitleColor(UIColor(hex: "#6F6F6F"), for: .normal)
        pwdCorrect01.setTitleColor(UIColor(hex: "#000000"), for: .selected)

        pwdCorrect02.setImage(UIImage(named: "pwd_complete"), for: .normal)
        pwdCorrect02.setImage(UIImage(named: "pwd_correct_complete"), for: .selected)
        pwdCorrect02.setTitleColor(UIColor(hex: "#6F6F6F"), for: .normal)
        pwdCorrect02.setTitleColor(UIColor(hex: "#000000"), for: .selected)
        
        pwdCorrect03.setImage(UIImage(named: "pwd_complete"), for: .normal)
        pwdCorrect03.setImage(UIImage(named: "pwd_correct_complete"), for: .selected)
        pwdCorrect03.setTitleColor(UIColor(hex: "#6F6F6F"), for: .normal)
        pwdCorrect03.setTitleColor(UIColor(hex: "#000000"), for: .selected)
        
    }
    
    
    func verifyCharactersNum(password: String) -> Bool {
        let passwordRegEx = "^.{8,20}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordPredicate.evaluate(with: password)
    }
    
    func verifyLetterAndNum(password: String) -> Bool {
        let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d).{1,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordPredicate.evaluate(with: password)
    }
    
    func verifySpecailCharacter(password: String) -> Bool {
        let passwordRegEx = "^(?=.*[!@#$%^&*(),.?\":{}|<>]).{1,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordPredicate.evaluate(with: password)
    }
    
    @IBAction func pwdVisbleClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.tag == 100 {
            self.pwdTextField01.isSecureTextEntry = !sender.isSelected
        } else {
            self.pwdTextField02.isSecureTextEntry = !sender.isSelected
        }
    }
    
    @IBAction func nextClick(_ sender: UIButton) {
        if pwdTextField01.text == pwdTextField02.text {
            errorTipLabel.text = nil
            if let password = pwdTextField01.text {
                loader.isHidden = false
                Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                    guard let self = self else {
                        return
                    }
                    loader.isHidden = true
                    if let error = error as NSError? {
                        print("Error code: \(error.code)")
                        print("Error creating user: \(error.localizedDescription)")
                        
                        errorTipLabel.text = {
                            switch AuthErrorCode(rawValue: error.code) {
                            case .emailAlreadyInUse:
                                return "This email is already registered"
                            default:
                                return error.localizedDescription
                            }
                        }()
                    }
                    if let user = Auth.auth().currentUser {
                        UserDefaultsManager.shared.authToken = user.uid
                        sendEmailVerification()
                    }
                }
            }
        } else {
            errorTipLabel.text = "The two passwords are inconsistent"
        }
    }
    
    func sendEmailVerification() {
        if let user = Auth.auth().currentUser {
            loader.isHidden = false
            user.sendEmailVerification { [weak self] error in
                guard let self = self else {
                    return
                }
                loader.isHidden = true
                if let error = error {
                    print("Error sending verification email: \(error.localizedDescription)")
                    return
                }
                
                let registerSocialRequest = RegisterUserAppRequest(username: "", dob: "", firstName: "", lastName: "", email: email, phone: "", socialID: "", authToken: UserDefaultsManager.shared.authToken, deviceToken: UserDefaultsManager.shared.device_token, socialType: "email")
                viewModel.registerEmail(parameters: registerSocialRequest)
                print("registerSocialRequest",registerSocialRequest)
                observeEvent()
            }
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
                    self.loader.isHidden = true
                }
                
            case .newCheckUsername(checkUsername: let checkUsername):break
            case .newRegisterPhone(registerPhone: let registerPhone):
                if registerPhone.code == 200 {
                    self.loader.isHidden = true
                    DispatchQueue.main.async {
                        UserDefaultsManager.shared.user_id = registerPhone.msg?.user.id?.toString() ?? ""
                        
                        
                        UserObject.shared.Objresponse(userID:registerPhone.msg?.user.id?.toString() ?? "",username: registerPhone.msg?.user.username ?? "",authToken:UserDefaultsManager.shared.authToken ?? "",profileUser: registerPhone.msg?.user.profilePic ?? "",first_name: registerPhone.msg?.user.firstName ?? "" ,last_name:registerPhone.msg?.user.lastName ?? "", isLogin: false, businessProfile: registerPhone.msg?.user.business ?? 0,email:registerPhone.msg?.user.email ?? "")
                        
                        let verifyEmailLink = VerifyEmailLinkController(nibName: "VerifyEmailLinkController", bundle: nil)
                        verifyEmailLink.email = self.email
                        verifyEmailLink.password = self.pwdTextField01.text
                        self.navigationController?.pushViewController(verifyEmailLink, animated: true)
                    }
                }else {
                    DispatchQueue.main.async {
                        Utility.showMessage(message: registerPhone.message ?? "", on: self.view)
                    }
                   
                }
            }
        }
    }

    @IBAction func backClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
