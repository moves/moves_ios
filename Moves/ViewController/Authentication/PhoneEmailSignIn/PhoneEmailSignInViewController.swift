//
//  PhoneEmailSignInViewController.swift
// //
//
//  Created by Wasiq Tayyab on 06/05/2024.
//

import UIKit
import PhoneNumberKit
import FirebaseAuth
class PhoneEmailSignInViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    //MARK: - VARS
    let message = "Your phone number may be used to connect you to people you may know, improve ads, and more, depending on your settings. "
    let emailMessage = "Your email address may be used to be connnect you to people you may know, improve ads, and more, depending on your settings."
    let findword1 = "Terms of Use"
    let findword2 = "Privacy Policy"
    
    fileprivate var menuTitles = [["menu":"Phone","isSelected":"true"],
                                  ["menu":"Email","isSelected":"false"]]
    var topTitle: String = ""
    private var dialCode = "+1"
    private var defaultRegion = "US"
    private let phoneNumberKit = PhoneNumberKit()
    private var viewModel = PhoneEmailSignInViewModel()
    private lazy var loader: UIView = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("Unable to access key window")
        }
        return Utility.shared.createActivityIndicator(keyWindow)
    }()
    var email = ""
    var isLogin = true
    var isVisible = true
    var updatedPhone = ""
    //MARK: - OUTLET
    
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var phoneSignUpView: UIView!
    @IBOutlet weak var emailSignIn: UIView!
    @IBOutlet weak var emailSignUp: UIView!
    @IBOutlet weak var phoneSignInView: UIView!
    @IBOutlet weak var lblTopTitle: UILabel!
    @IBOutlet weak var menuCollectionView: UICollectionView!
    
    @IBOutlet weak var lblCountryCode: UILabel!
    @IBOutlet weak var tfPhoneNumber: PhoneNumberTextField!
    @IBOutlet weak var btnSendCode: UIButton!
    
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var tfEmail: UITextField!
    
    
    @IBOutlet weak var btnContinueLogin: UIButton!
    @IBOutlet weak var btnVisible: UIButton!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfEmailLogin: UITextField!
    
    @IBOutlet weak var imgCheckBox: UIImageView!
    @IBOutlet weak var lblLogin: UITextView!
    
    @IBOutlet weak var lblLoginSignUp: UITextView!
    @IBOutlet weak var lblPhoneSignUpCode: UILabel!
    @IBOutlet weak var tfPhoneSignup: PhoneNumberTextField!
    @IBOutlet weak var checkBoxPhoneSignUp: UIImageView!
    
    @IBOutlet weak var btnSendCodeSignUp: UIButton!
    
    
    @IBOutlet weak var lblEmailSignupError: UILabel!
    @IBOutlet weak var lblPhoneRegisterError: UILabel!
    @IBOutlet weak var lblPhoneLoginError: UILabel!
    
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configuration()
    }
    
    //MARK: - FUNCTION
    
    private func setup(){
        if topTitle == "Sign Up" || topTitle == "Sign Up For Shop"{
            self.phoneSignUpView.isHidden = false
        }else {
            self.phoneSignInView.isHidden = false
        }
        self.lblLogin.delegate = self
        self.lblLoginSignUp.delegate = self
        self.configureSubViews()
        self.lblTopTitle.text = topTitle
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self
        menuCollectionView.register(UINib(nibName: "PhoneSiginCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhoneSiginCollectionViewCell")
        self.tfPhoneSignup.delegate = self
        self.tfPhoneNumber.delegate = self
        self.tfEmail.delegate = self
        self.tfEmailLogin.delegate = self
        self.tfPassword.delegate = self
        self.tfPhoneSignup.delegate = self
        tfPhoneSignup.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        tfPhoneNumber.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        tfEmail.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        tfEmailLogin.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        tfPassword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.tfPhoneNumber.isPartialFormatterEnabled = true
        self.tfPhoneNumber.withExamplePlaceholder = true
        self.tfPhoneNumber.withPrefix = false
        self.tfPhoneNumber.defaultRegion = defaultRegion
        self.tfPhoneNumber.placeholder = phoneNumberKit.metadata(for: defaultRegion)?.mobile?.exampleNumber
        
        self.tfPhoneSignup.isPartialFormatterEnabled = true
        self.tfPhoneSignup.withExamplePlaceholder = true
        self.tfPhoneSignup.withPrefix = false
        self.tfPhoneSignup.defaultRegion = defaultRegion
        self.tfPhoneSignup.placeholder = phoneNumberKit.metadata(for: defaultRegion)?.mobile?.exampleNumber
        NotificationCenter.default.addObserver(self, selector: #selector(self.countryDataNoti(_:)), name: NSNotification.Name(rawValue: "countryDataNoti"), object: nil)
    }
    
    private func configureSubViews() {
        let attributeMutableStringlink = NSMutableAttributedString(string: message)
        let emailAttributeMutableStringlink = NSMutableAttributedString(string: emailMessage)
       
        // Configure link text attributes
        let applyColorheadlineOnText: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.appColor(.black)
        ]
        
        // Configure lblLogin
        lblLogin.linkTextAttributes = applyColorheadlineOnText
        lblLogin.attributedText = emailAttributeMutableStringlink
        lblLogin.textAlignment = .left
        lblLogin.sizeToFit()
        lblLogin.textContainerInset = UIEdgeInsets.zero
        lblLogin.textContainer.lineFragmentPadding = 0
        lblLogin.textColor = UIColor.appColor(.darkGrey)
        lblLogin.font = AppFont.font(type: .Regular, size: 10.0)
        
        // Configure lblLoginSignUp
        lblLoginSignUp.linkTextAttributes = applyColorheadlineOnText
        lblLoginSignUp.attributedText = attributeMutableStringlink
        lblLoginSignUp.textAlignment = .left
        lblLoginSignUp.sizeToFit()
        lblLoginSignUp.textContainerInset = UIEdgeInsets.zero
        lblLoginSignUp.textContainer.lineFragmentPadding = 0
        lblLoginSignUp.textColor = UIColor.appColor(.darkGrey)
        lblLoginSignUp.font = AppFont.font(type: .Regular, size: 10.0)
    }
  
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    func emailNext() {
        let pwd = EmailPasswordController(nibName: "EmailPasswordController", bundle: nil)
        pwd.email = email
        self.navigationController?.pushViewController(pwd, animated: true)
    }
    
    private func verifyPhone() {
        if tfPhoneNumber.text! == "" {
            updatedPhone = phoneNumberKit.format(tfPhoneSignup.phoneNumber!, toType: .e164)
        }else {
            updatedPhone = phoneNumberKit.format(tfPhoneNumber.phoneNumber!, toType: .e164)
        }
        firebaseSendCode()
    }
    
    //send code
    func firebaseSendCode() {
        loader.isHidden = false
        print("updatedPhone",updatedPhone)
        FirebaseAuthService.shared.verifyPhoneNumber(updatedPhone) { [self] verificationID, error in
            loader.isHidden = true
            if let error = error {
                print("Error verifying phone number: \(error.localizedDescription)")
                Utility.showMessage(message: error.localizedDescription, on: view)
                return
            }
            UserDefaultsManager.shared.verificationID = verificationID ?? ""
            
            let myViewController = OTPViewController(nibName: "OTPViewController", bundle: nil)
            myViewController.number = updatedPhone
            myViewController.isLogin = isLogin
            myViewController.email = self.tfEmail.text ?? ""
            myViewController.isPhoneUpdate = false
            navigationController?.pushViewController(myViewController, animated: true)
        }
    }

    func loginEmail(){
        let email =  tfEmailLogin.text!
        let password =  tfPassword.text!
        self.loader.isHidden = false
                
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error as? NSError {
                loader.isHidden = true
                switch AuthErrorCode(rawValue: error.code) {
                case .wrongPassword:
                    lblError.text = "Password is incorrect"
                    print("Password is incorrect.")

                case .invalidEmail:
                    lblError.text = "Email format is invalid"
                    print("Email format is invalid.")

                default:
                    lblError.text = error.localizedDescription
                    print("Error: \(error.localizedDescription)")
                }

            } else {
                print("Successfully signed in")
                if let user = Auth.auth().currentUser {
                    UserDefaultsManager.shared.authToken = user.uid
                    if user.isEmailVerified {
                        user.getIDTokenForcingRefresh(true) { [weak self] idToken, error in
                            guard let self = self else {return}
                            UserDefaultsManager.shared.idAuthToken = idToken ?? ""
                            let showUserDetail = ShowUserDetailRequest(authToken: UserDefaultsManager.shared.authToken)
                            self.viewModel.showUserDetail(parameters: showUserDetail)
                            DispatchQueue.main.async {
                                self.observeEvent()
                            }
                        }
                        
                    } else {
                        Utility.showMessage(message: "We've already sent you an email. Click the link to verify your account.", on: view)
                    }
                }
            }

        }
    }
    
    func observeEvent() {
        viewModel.eventHandler = { [weak self] event in
            guard let self else { return }
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
            case .newShowUserDetail(showUserDetail: let showUserDetail):
                print("showUserDetail",showUserDetail)
                DispatchQueue.main.async {
                    UserDefaultsManager.shared.user_id = showUserDetail.msg?.user.id?.toString() ?? ""
                    if showUserDetail.code == 200 {
                        self.loader.isHidden = true
                        
                        UserObject.shared.Objresponse(userID:showUserDetail.msg?.user.id?.toString() ?? "",username: showUserDetail.msg?.user.username ?? "",authToken: UserDefaultsManager.shared.authToken,profileUser: showUserDetail.msg?.user.profilePic ?? "",first_name: showUserDetail.msg?.user.firstName ?? "" ,last_name:showUserDetail.msg?.user.lastName ?? "" , isLogin: false, businessProfile: showUserDetail.msg?.user.business ?? 0,email:showUserDetail.msg?.user.email ?? "")
                        
                        DataPersistence.shared.saveOrUpdateCoreData(data: showUserDetail, withId: "profile")
                        
                        if  let appdelegate = UIApplication.shared.delegate as? AppDelegate {
                            appdelegate.gotoHomeController()
                        }
                    }else {
                        self.lblError.text = "This account does not exist. Please register."
                    }
                }
            case .newCheckEmail(checkEmail: let checkEmail):
                print("checkEmail",checkEmail)
                DispatchQueue.main.async {
                    if checkEmail.code == 200 {
                        self.emailNext()
                    }else {
                        self.lblEmailSignupError.isHidden = false
                        self.lblEmailSignupError.text = "Your email already exists. Please log in."
                    }
                }
                
            case .newVerifyPhoneNoAdded(verifyPhoneNo: let verifyPhoneNo):
                print("verifyPhoneNo")
            case .newVerifyPhoneNoWithCodeAdded(verifyPhoneNo: let verifyPhoneNo):
                print("verifyPhoneNo")
            case .newLogin(login: let login):
                print("login")
            case .newRegisterUser(registerPhone: let registerPhone):
                print("registerPhone")
            }
        }
    }
    
    @IBAction func countryCodeButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "countryCodeVC") as! countryCodeViewController
        self.present(vc, animated: true)
    }
    
    
    @IBAction func sendCodeButtonPressed(_ sender: UIButton) {
        if sender.tag == 0 {  //phone login
            if (Utility.shared.isEmpty(self.tfPhoneNumber.text)){
                self.lblPhoneLoginError.text = "Enter your valid Phone number"
                return
            }
            
            if self.tfPhoneNumber.isValidNumber {
                self.verifyPhone()
            }else{
                self.lblPhoneLoginError.text = "Phone number is not valid"
                return
            }
           
        }else { //phone register
            if (Utility.shared.isEmpty(self.tfPhoneSignup.text)){
                self.lblPhoneRegisterError.text = "Enter your valid Phone number"
               
                return
            }
            
            if self.tfPhoneSignup.isValidNumber {
                verifyPhone()
            }else{
                self.lblPhoneRegisterError.text = "Phone number is not valid"
                return
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        if !tfEmail.text!.isEmail() {
            self.lblEmailSignupError.text = "Your email is not valid"
            return
        }
        self.email = tfEmail.text!
        
        let checkEmail = CheckEmailRequest(email: self.email)
        self.viewModel.checkEmail(parameters: checkEmail)
        DispatchQueue.main.async {
            self.observeEvent()
        }
    }
    
    @objc func countryDataNoti(_ notification: NSNotification) {
        if topTitle == "Login" {
            let newDialCode = notification.userInfo?["dial_code"] as! String
            let code = notification.userInfo?["code"] as! String
            
            self.tfPhoneNumber.placeholder = phoneNumberKit.metadata(for: code)?.mobile?.exampleNumber
            self.tfPhoneNumber.defaultRegion = code
            self.dialCode = newDialCode
            self.lblCountryCode.text = "(\(code)) \(newDialCode)"
        }else {
            let newDialCode = notification.userInfo?["dial_code"] as! String
            let code = notification.userInfo?["code"] as! String
            
            self.tfPhoneSignup.placeholder = phoneNumberKit.metadata(for: code)?.mobile?.exampleNumber
            self.tfPhoneSignup.defaultRegion = code
            self.dialCode = newDialCode
            self.lblPhoneSignUpCode.text = "(\(code)) \(newDialCode)"
        }
    }
    
    @IBAction func continueLoginButtonPressed(_ sender: UIButton) {
        if Utility.shared.isEmpty(tfEmailLogin.text!) {
            self.lblError.text = "Enter your email"
        
            return
        }
        
        if !tfEmailLogin.text!.isEmail() {
            self.lblError.text = "Your email is not valid"
            return
        }
        
        if Utility.shared.isEmpty(tfPassword.text!) {
            self.lblError.text = "Enter your password"
            return
        }
    
        self.email = tfEmailLogin.text ?? ""
        loginEmail()
    }
    
    @IBAction func forgetPasswordButtonPressed(_ sender: UIButton) {
        let myViewController = ForgetPasswordViewController(nibName: "ForgetPasswordViewController", bundle: nil)
        self.navigationController?.pushViewController(myViewController, animated: true)
    }
    
    @IBAction func visibleButtonPressed(_ sender: UIButton) {
        if isVisible == false {
            tfPassword.isSecureTextEntry = true
            btnVisible.setImage(UIImage(named: "unvisible"), for: .normal)
            isVisible = true
        }else {
            tfPassword.isSecureTextEntry = false
            btnVisible.setImage(UIImage(named: "visible"), for: .normal)
            isVisible = false
        }
    }
    
    
    //MARK: - TEXTFIELD ACTION
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.lblError.text = nil
        self.lblPhoneLoginError.text = nil
        self.lblPhoneRegisterError.text = nil
        self.lblEmailSignupError.text = nil
        if textField == tfPhoneSignup {
            let textCount = textField.text?.count
            if textCount! == 0{
                btnSendCodeSignUp.backgroundColor = UIColor.appColor(.barColor)
                btnSendCodeSignUp.setTitleColor(UIColor.appColor(.white), for: .normal)
            }else{
                btnSendCodeSignUp.backgroundColor = UIColor.appColor(.theme)
                btnSendCodeSignUp.setTitleColor(UIColor.appColor(.white), for: .normal)
            }
            
        }else if textField == tfPhoneNumber {
            let textCount = textField.text?.count
            if textCount! == 0{
                btnSendCode.backgroundColor = UIColor.appColor(.barColor)
                btnSendCode.setTitleColor(UIColor.appColor(.white), for: .normal)
            }else{
                btnSendCode.backgroundColor = UIColor.appColor(.theme)
                btnSendCode.setTitleColor(UIColor.appColor(.white), for: .normal)
            }
        }else if textField == tfEmail {
            let textCount = textField.text?.count
            if textCount! == 0{
                btnContinue.backgroundColor = UIColor.appColor(.barColor)
                btnContinue.setTitleColor(UIColor.appColor(.white), for: .normal)
            }else{
                btnContinue.backgroundColor = UIColor.appColor(.theme)
                btnContinue.setTitleColor(UIColor.appColor(.white), for: .normal)
            }
        }else {
            let tfEmailLoginCount = tfEmailLogin.text?.count
            let tfPasswordCount = tfPassword.text?.count
            if tfEmailLoginCount! == 0 && tfPasswordCount! == 0{
                btnContinueLogin.backgroundColor = UIColor.appColor(.barColor)
                btnContinueLogin.setTitleColor(UIColor.appColor(.white), for: .normal)
            }else{
                btnContinueLogin.backgroundColor = UIColor.appColor(.theme)
                btnContinueLogin.setTitleColor(UIColor.appColor(.white), for: .normal)
            }
        }
    }
    
}

extension PhoneEmailSignInViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhoneSiginCollectionViewCell", for: indexPath)as! PhoneSiginCollectionViewCell
        cell.lblMenu.text = menuTitles[indexPath.row]["menu"] ?? ""
        if menuTitles[indexPath.row]["isSelected"] == "true" {
            cell.lineView.isHidden = false
            cell.lblMenu.textColor = UIColor.appColor(.theme)
        }else {
            cell.lineView.isHidden = true
            cell.lblMenu.textColor = UIColor.appColor(.darkGrey)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2.0, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            if topTitle == "Login" {
                self.phoneSignInView.isHidden = true
                self.emailSignIn.isHidden = false
            }else {
                self.phoneSignUpView.isHidden = true
                self.emailSignUp.isHidden = false

            }
        }else {
            if topTitle == "Sign Up" || topTitle == "Sign Up For Shop" {
                self.phoneSignUpView.isHidden = false
                self.emailSignUp.isHidden = true
            }else {
                self.phoneSignInView.isHidden = false
                self.emailSignIn.isHidden = true
            }
        }
        
        for i in 0..<self.menuTitles.count {
            var obj  = self.menuTitles[i]
            obj.updateValue("false", forKey: "isSelected")
            self.menuTitles.remove(at: i)
            self.menuTitles.insert(obj, at: i)
        }
        
        var obj  =  self.menuTitles[indexPath.row]
        obj.updateValue("true", forKey: "isSelected")
        self.menuTitles.remove(at: indexPath.row)
        self.menuTitles.insert(obj, at: indexPath.row)
        collectionView.reloadData()
    }
    
    func configuration() {
        topTitle = isLogin ? "Login" : "Sign Up"
        self.setup()
        self.hideKeyboardWhenTappedAround()
    }
    
}
