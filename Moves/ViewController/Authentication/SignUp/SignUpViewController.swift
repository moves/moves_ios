//
//  SignUpViewController.swift
// //
//
//  Created by iMac on 10/06/2024.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import CryptoKit
import AuthenticationServices
import FacebookLogin
class SignUpViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding, UITextViewDelegate {
    
    //MARK: - VARS
    var viewModel = ProfileViewModel()
    var usernameViewModel = UsernameViewModel()
    var currentNonce: String?
    let message = "By signing up, you confirm that you agree to our Terms of Use and have read and understood our Privacy Policy."
    let findword1 = "Terms of Use"
    let findword2 = "Privacy Policy"
    var phone: String?
    var birthday: String?
    var userName: String?
    var social_id: String?
    var social = ""
    
    var firstName: String?
    var lastName: String?

    private lazy var loader: UIView = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("Unable to access key window")
        }
        return Utility.shared.createActivityIndicator(keyWindow)
    }()
    var email = ""
    var isSwitchAccount =  false
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var phoneLoginButton: UIButton!
    
    
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.delegate = self
        self.configureSubViews()
        ConstantManager.isSwitchAccountFlow =  self.isSwitchAccount
    }
    
    //MARK: - FUNCTION
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            if touch.view == self.view{
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    private func configureSubViews() {
        let attributeMutableStringLink = NSMutableAttributedString(string: message)
        
        // Configure links
        let links = [
            (findword1, "https://movesapp.io/privacypolicy/", "Terms of Service"),
            (findword2, "https://movesapp.io/privacypolicy/", "Privacy Policy")
        ]
        
        for (word, link, title) in links {
            let range = message.createRangeinaLink(of: word)
            attributeMutableStringLink.addAttribute(.link, value: link, range: range)
            attributeMutableStringLink.addAttributes([
                .font: AppFont.font(type: .Regular, size: 14.0)
            ], range: range)
        }
        
        // Configure text view link attributes
        let applyColorheadlineOnText: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.appColor(.theme)
        ]
        
        textView.linkTextAttributes = applyColorheadlineOnText
        textView.attributedText = attributeMutableStringLink
        textView.textAlignment = .center
        textView.sizeToFit()
        textView.textColor = UIColor.appColor(.darkGrey)
        textView.font = AppFont.font(type: .Regular, size: 14.0)
    }

    // UITextViewDelegate method to handle link interactions
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard let attributedText = textView.attributedText else { return true }
        
        let text = attributedText.string as NSString
        let termsOfServiceRange = text.range(of: "Terms of Use")
        let privacyPolicyRange = text.range(of: "Privacy Policy")
        
        let termsUrl = "https://movesapp.io/privacypolicy/"
        let privacyUrl = "https://movesapp.io/privacypolicy/"
        
        if NSLocationInRange(characterRange.location, termsOfServiceRange) {
            openWebViewController(with: termsUrl, title: "Terms of Use")
            return false
        } else if NSLocationInRange(characterRange.location, privacyPolicyRange) {
            openWebViewController(with: privacyUrl, title: "Privacy Policy")
            return false
        }
        
        return true // Allow other interactions
    }

    private func openWebViewController(with url: String, title: String) {
        let webViewController = WebViewController(nibName: "WebViewController", bundle: nil)
        webViewController.myUrl = url
        webViewController.linkTitle = title
        webViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    private func googleFirebase() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self = self else {
                return
            }
            if let error = error {
                Utility.showMessage(message: error.localizedDescription, on: view)
                print("Error during Google Sign-In: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user,let idToken = user.idToken?.tokenString
            else { return }
            
            self.email =  user.profile?.email ?? ""
            googleCredential = GoogleAuthProvider.credential(withIDToken: idToken,accessToken: user.accessToken.tokenString)
            
            if let credential = googleCredential {
                loader.isHidden = false
                Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
                    guard let self = self else {
                        return
                    }
                    loader.isHidden = true
                    if let error = error {
                        Utility.showMessage(message: error.localizedDescription, on: self.view)
                        print("Error during sign-in: \(error.localizedDescription)")
                        return
                    }
                    
                    if let authResult = authResult {
                        print("Sign-in successful: \(authResult)")
                        UserDefaultsManager.shared.authToken = authResult.user.uid
                        //                        self.loader.isHidden = true
                        //                        self.verifyEmailFunc()
                        print("uid====\(authResult.user.uid)")
                        authResult.user.getIDTokenForcingRefresh(true) { [weak self] idToken, error in
                            guard let self = self else {
                                return
                            }
                            self.social = "google"
                            UserDefaultsManager.shared.idAuthToken = idToken ?? ""
                            self.getUserDetail()
                        }
                    }
                }
            } else {
                print("Credential is nil, cannot sign in.")
            }
            
        }
    }
    
    func getUserDetail() {
        let showUserDetail = ShowUserDetailRequest(authToken: UserDefaultsManager.shared.authToken)
        self.viewModel.showUserDetail(parameters: showUserDetail)
        DispatchQueue.main.async {
            self.observeEvent()
        }
    }
    
    func observeEvent() {
        viewModel.eventHandler = { [weak self] event in
            guard let self else { return }
            switch event {
            case .error(let error):break
            case .newShowUserDetail(showUserDetail: let showUserDetail):
                DispatchQueue.main.async { [self] in
                    self.loader.isHidden = true
                    if showUserDetail.code == 200 {
                        
                        UserObject.shared.Objresponse(userID:showUserDetail.msg?.user?.id?.toString() ?? "",username: showUserDetail.msg?.user?.username ?? "",authToken: UserDefaultsManager.shared.authToken,profileUser: showUserDetail.msg?.user?.profilePic ?? "",first_name: showUserDetail.msg?.user?.firstName ?? "" ,last_name:showUserDetail.msg?.user?.lastName ?? "" , isLogin: false, businessProfile: showUserDetail.msg?.user?.business ?? 0,email:showUserDetail.msg?.user?.email ?? "")
                        
                        DataPersistence.shared.saveOrUpdateCoreData(data: showUserDetail, withId: "profile")
                        
                        UserDefaultsManager.shared.user_id = showUserDetail.msg?.user?.id?.toString() ?? ""
                        if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
                            appdelegate.gotoHomeController()
                        }
                    }else {
                        
                        if self.social == "apple" {
                            
                            let randomUsername = Utility.shared.generateRandomUsername()
                            let (firstName, lastName) = Utility.shared.extractFirstNameAndLastName(from: randomUsername)
                            
                            self.userName = randomUsername
                            if firstName == "" {
                                self.firstName = firstName
                            }
                            
                            if lastName == "" {
                                self.lastName = lastName
                            }
                           
                            
                            let registerSocialRequest = RegisterUserAppRequest(username: self.userName ?? "", dob: self.birthday ?? "", firstName: self.firstName ?? "", lastName: self.lastName ?? "", email: self.email, phone: self.phone ?? "", socialID: self.social_id ?? "", authToken: UserDefaultsManager.shared.authToken, deviceToken: UserDefaultsManager.shared.device_token, socialType: self.social)
                            self.usernameViewModel.registerEmail(parameters: registerSocialRequest)
                            self.observeEvent1()
                        }else {
                            let username = UserNameController(nibName: "UserNameController", bundle: nil)
                            username.social = self.social
                            self.navigationController?.pushViewController(username, animated: true)
                        }
                      
                    }
                }
            case .newShowOtherUserDetail(showOtherUserDetail: let showOtherUserDetail): break
            case .newShowVideosAgainstUserID(showVideosAgainstUserID: let showVideosAgainstUserID): break
            case .newShowUserLikedVideos(showUserLikedVideos: let showUserLikedVideos): break
            case .newShowFavouriteVideos(showFavouriteVideos: let showFavouriteVideos): break
            case .newDeleteVideo(deleteVideo: let deleteVideo): break
            case .newWithdrawRequest(withdrawRequest: let withdrawRequest): break
            case .newShowPayout(showPayout: let showPayout): break
            case .newShowStoreTaggedVideos(showStoreTaggedVideos: let showStoreTaggedVideos): break
            case .newShowPrivateVideosAgainstUserID(showPrivateVideosAgainstUserID: let showPrivateVideosAgainstUserID): break
            case .showUserRepostedVideos(showUserRepostedVideos: let showUserRepostedVideos):break
            }
        }
    }
    
    func observeEvent1() {
        usernameViewModel.eventHandler = { [weak self] event in
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
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    @IBAction func phoneButtonPressed(_ sender: UIButton) {
        let myViewController = PhoneEmailSignInViewController(nibName: "PhoneEmailSignInViewController", bundle: nil)
        myViewController.hidesBottomBarWhenPushed = true
        myViewController.topTitle = "Login"
        self.navigationController?.pushViewController(myViewController, animated: true)
    }
    
    @IBAction func googleButtonPressed(_ sender: UIButton) {
        if sender.tag == 0 {
            self.googleFirebase()
        }else if sender.tag == 1 {
        }else {
            self.appleFirebase()
        }
    }
    
    
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        let phoneEmail = PhoneEmailSignInViewController(nibName: "PhoneEmailSignInViewController", bundle: nil)
        phoneEmail.hidesBottomBarWhenPushed = true
        phoneEmail.isLogin = false
        self.navigationController?.pushViewController(phoneEmail, animated: true)
    }
    
    private func appleFirebase(){
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            self.firstName = appleIDCredential.fullName?.givenName
            self.lastName = appleIDCredential.fullName?.familyName
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            // Initialize a Firebase credential
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            // Sign in with Firebase
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    Utility.showMessage(message: error.localizedDescription, on: self.view)
                    print("Error during sign-in: \(error.localizedDescription)")
                    return
                }
                self.loader.isHidden = true
                if let authResult = authResult {
                    print("Sign-in successful: \(authResult)")
                    UserDefaultsManager.shared.authToken = authResult.user.uid
                    print("uid====\(authResult.user.uid)")
                    authResult.user.getIDTokenForcingRefresh(true) { [weak self] idToken, error in
                        guard let self = self else {
                            return
                        }
                        UserDefaultsManager.shared.idAuthToken = idToken ?? ""
                        self.social = "apple"
                        self.getUserDetail()
                    }
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
}

