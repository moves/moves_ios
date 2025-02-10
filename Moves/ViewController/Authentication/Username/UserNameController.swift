//
//  UserNameController.swift
// //
//
//  Created by YS on 2024/9/7.
//

import UIKit

class UserNameController: UIViewController {

    private lazy var loader: UIView = {
        return Utility.shared.createActivityIndicator(view)
    }()
    let viewModel = UsernameViewModel()
    var birthday: String?
    var phone:String?
    var social: String?
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var takeTipsLabel: UILabel!
    @IBOutlet weak var numsLabel: UILabel!
    @IBOutlet weak var submitButton: SubmitButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == self.view {
                view.endEditing(true)
            }
        }
    }
   
    @IBAction func confirm(_ sender: Any) {
        
        guard let userName = userNameTextField.text else {
            return
        }
        
        loader.isHidden = false
        let checkUsername = CheckUsernameRequest(username: userName)
        viewModel.checkUsername(parameters: checkUsername)
        observeEvent()
    }
    
    func jumpToController() {
        let firstName = FirstNameController(nibName: "FirstNameController", bundle: nil)
        firstName.userName = userNameTextField.text ?? ""
        firstName.birthday = birthday
        firstName.phone = self.phone
        firstName.social = social
        navigationController?.pushViewController(firstName, animated: true)
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
                DispatchQueue.main.async {
                    self.loader.isHidden = true
                    if checkUsername.code == 200 {
                        self.jumpToController()
                    }else {
                        self.takeTipsLabel.text = "username is taken, please choose different one"
                    }
                    self.loader.isHidden = true
                }
            case .newRegisterPhone(registerPhone: let registerPhone):
                print("registerPhone")
            }
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}

extension UserNameController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == userNameTextField {
            takeTipsLabel.text = nil
            let maxLength = 30
            let currentString = (userNameTextField.text ?? "") as NSString
            guard range.location + range.length <= currentString.length else {
                return false
            }
            let newString = currentString.replacingCharacters(in: range, with: string)
            if newString.count < 5 {
                submitButton.isEnabled = false
            }
            numsLabel.text = "\(newString.count)/30"
            print(userNameTextField.text ?? "")
            print(newString)

            let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")
            if newString.rangeOfCharacter(from: characterset.inverted) != nil {
                print("string contains special characters")
                takeTipsLabel.text = "Only Letters, numbers, underscores or periods are allowed."
                submitButton.isEnabled = false
            } else {
                if newString.count >= 5 {
                    submitButton.isEnabled = true
                }
                return newString.count < maxLength
            }
            return true
        }
        return true
    }
    
    
}
