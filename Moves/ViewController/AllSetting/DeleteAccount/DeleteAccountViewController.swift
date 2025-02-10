//
//  DeleteAccountViewController.swift
//  Movess
//
//  Created by Mac on 02/11/2022.
//

import UIKit

class DeleteAccountViewController: UIViewController {

    
    //MARK:- Outlets

    @IBOutlet weak var lblTitleText:UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var lblText:UILabel!
    
    //MARK:- VARS
    let viewModel = DeleteAccountViewModel()
    var profileResponse : ProfileResponse?
    let textDescription = ["If you delete your account","Your will no longer be able tol og in to App with that account","Your will lose to access to any videos you have posted"," Your will no able to get refund on any item you have purchased"," Information that is not stored in your account, such as chat message, may still be visible to others","Your account will be deactivated for 30 days. During deactivation, your account won’t be visible to public. After 30 days, your account will be then deleted permanently.","Do you want to continue? "]
    private lazy var loader: UIView = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("Unable to access key window")
        }
        return Utility.shared.createActivityIndicator(keyWindow)
    }()
    //MARK:- viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblTitleText.text! = "Are you sure you want to delete account " + (profileResponse?.msg?.user?.username ?? "") + "?"
        lblText.attributedText = add(stringList: textDescription, font: lblText.font, bullet: "•")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent

    }
   
    
    //MARK:- Button Action
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnContinue(_ sender: Any) {
        let deleteAccount = DeleteUserAccountRequest(authToken: UserDefaultsManager.shared.authToken)
        viewModel.deleteUserAccount(parameters: deleteAccount)
        self.observeEvent()
    }
    
    func observeEvent() {
        viewModel.eventHandler = { [weak self] event in
            guard let self else { return }
            
            switch event {
            case .error(let error):
                print("error",error)
                DispatchQueue.main.async {
                    if let urlError = error as? URLError, urlError.code == .badServerResponse {
                        Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                    } else {
                        if isDebug == true {
                            Utility.showMessage(message: "Something went wrong. Please try again", on: self.view)
                        }
                    }
                }
            case .newDeleteUserAccount(deleteUserAccount: let deleteUserAccount):
                if deleteUserAccount.code == 200 {
                    
                    DispatchQueue.main.async {
                        UserDefaults.standard.removeObject(forKey: "cachedNotification")
                        UserDefaults.standard.removeObject(forKey: "cachedVideos")
                        UserDefaults.standard.removeObject(forKey: "cachedShowUserDetail")
                        UserDefaults.standard.removeObject(forKey: "cachedAddress")
                        ConstantManager.shared.resetDishDetails()
                        UserDefaultsManager.shared.payment_method_id = ""
                        UserDefaultsManager.shared.cardExpiry = ""
                        UserDefaultsManager.shared.cardLastNumber = ""
                        UserDefaultsManager.shared.payment_id = ""
                        UserDefaultsManager.shared.location_id = 0
                        UserDefaultsManager.shared.location_name = ""
                        UserDefaultsManager.shared.location_address = ""
                        UserDefaultsManager.shared.user_id = "0"
                        UserDefaultsManager.shared.authToken = "0"
                        self.restartApplication()
                    }
                   
                }else {
                    Utility.showMessage(message: deleteUserAccount.msg, on: self.view)
                }
            }
        }
    }
    
    func restartApplication () {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.isHidden = true
        self.view.window?.rootViewController = nav
    }
    
 //MARK:- NSAttributed Strings
    
    func add(stringList: [String],
             font: UIFont,
             bullet: String = "\u{2022}",
             indentation: CGFloat = 20,
             lineSpacing: CGFloat = 2,
             paragraphSpacing: CGFloat = 12,
             textColor: UIColor = .black, // Default text color
             bulletColor: UIColor = .black) -> NSAttributedString {
        
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor]
        let bulletAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: bulletColor]
        
        let paragraphStyle = NSMutableParagraphStyle()
        let nonOptions = [NSTextTab.OptionKey: Any]()
        paragraphStyle.tabStops = [
            NSTextTab(textAlignment: .left, location: indentation, options: nonOptions)]
        paragraphStyle.defaultTabInterval = indentation
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = paragraphSpacing
        paragraphStyle.headIndent = indentation
        
        let bulletList = NSMutableAttributedString()
        
        for (index, string) in stringList.enumerated() {
            if index == 0 || index == stringList.count - 1 {
                // First and last strings are not bulleted
                let attributedString = NSAttributedString(string: "\(string)\n", attributes: textAttributes)
                bulletList.append(attributedString)
            } else {
                // Bulleted points
                let formattedString = "\(bullet)\t\(string)\n"
                let attributedString = NSMutableAttributedString(string: formattedString)
                
                attributedString.addAttributes(
                    [NSAttributedString.Key.paragraphStyle : paragraphStyle],
                    range: NSMakeRange(0, attributedString.length))
                
                attributedString.addAttributes(
                    textAttributes,
                    range: NSMakeRange(0, attributedString.length))
                
                let string:NSString = NSString(string: formattedString)
                let rangeForBullet:NSRange = string.range(of: bullet)
                attributedString.addAttributes(bulletAttributes, range: rangeForBullet)
                bulletList.append(attributedString)
            }
        }
        
        return bulletList
    }


}
