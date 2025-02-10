//
//  ChangePhoneNoViewController.swift
//  Movess
//
//  Created by Mac on 03/11/2022.
//

import UIKit
import PhoneNumberKit
class ChangePhoneNoViewController: UIViewController,UITextFieldDelegate {

    //MARK:- VARS
    var dialCode = "+1"
    private lazy var loader: UIView = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("Unable to access key window")
        }
        return Utility.shared.createActivityIndicator(keyWindow)
    }()
    private let phoneNumberKit = PhoneNumberKit()
    var updatedPhone = ""
    var defaultRegion = "US"
    
    //MARK: - OUTLET

    @IBOutlet weak var tfPhoneNumber: PhoneNumberTextField!
    @IBOutlet weak var btnSendCode: UIButton!
    @IBOutlet weak var btnCountryCode: UIButton!
    @IBOutlet weak var lblCode: UILabel!
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.countryDataNoti(_:)), name: NSNotification.Name(rawValue: "countryDataNoti"), object: nil)
        self.tfPhoneNumber.placeholder = phoneNumberKit.metadata(for: defaultRegion)?.mobile?.exampleNumber
        tfPhoneNumber.delegate = self
        tfPhoneNumber.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.hideKeyboardWhenTappedAround()
        
        self.tfPhoneNumber.isPartialFormatterEnabled = true
        self.tfPhoneNumber.defaultRegion = defaultRegion
        self.tfPhoneNumber.withExamplePlaceholder = true
        self.tfPhoneNumber.withPrefix = false
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

    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.text?.count == 0 && string == "0" {
            
            return false
        }
      
        return true
    }
    
   
    
    //MARK:- BUTTON ACTION
    
    @IBAction func btnSendCodeAction(_ sender: Any) {
        
        if (Utility.shared.isEmpty(self.tfPhoneNumber.text)){
            Utility.showMessage(message: "Enter your valid Phone number", on: self.view)
            return
        }
      
        if self.tfPhoneNumber.isValidNumber {
            self.verifyPhoneFunc()
        }else{
            Utility.showMessage(message: "Phone number is not valid", on: self.view)
            return
        }

    }
    
    
    private func verifyPhoneFunc() {
        self.updatedPhone = phoneNumberKit.format(tfPhoneNumber.phoneNumber!, toType: .e164)
        
        FirebaseAuthService.shared.verifyPhoneNumber(self.updatedPhone) { verificationID, error in
            if let error = error {
                Utility.showMessage(message: error.localizedDescription ?? "", on: self.view)
                print("Error verifying phone number: \(error.localizedDescription)")
                return
            }
            UserDefaultsManager.shared.verificationID = verificationID ?? ""
        }
            let myViewController = OTPViewController(nibName: "OTPViewController", bundle: nil)
            myViewController.number = self.updatedPhone
            myViewController.isPhoneUpdate = true
            
            self.navigationController?.pushViewController(myViewController, animated: true)
    
    }
    
    @IBAction func btnCountryCode(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "countryCodeVC") as! countryCodeViewController
        present(vc, animated: true, completion: nil)
        
    }
    
    @objc func countryDataNoti(_ notification: NSNotification) {
        let newDialCode = notification.userInfo?["dial_code"] as! String
        let code = notification.userInfo?["code"] as! String
        print("code",code)
        self.tfPhoneNumber.defaultRegion = code
        self.tfPhoneNumber.placeholder = phoneNumberKit.metadata(for: code)?.mobile?.exampleNumber
        self.dialCode = newDialCode
        self.lblCode.text = "(\(code)) \(newDialCode)"
    }

    //MARK: - FUNCTION
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let textCount = textField.text?.count
    
        if textCount! > 0{
            btnSendCode.backgroundColor = UIColor.appColor(.theme)
            btnSendCode.setTitleColor(UIColor.appColor(.white), for: .normal)
        }else{
            btnSendCode.backgroundColor = UIColor.appColor(.barColor)
            btnSendCode.setTitleColor(UIColor.appColor(.white), for: .normal)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
