//
//  PhoneEmailSignInViewModel.swift
// //
//
//  Created by Wasiq Tayyab on 09/05/2024.
//

import Foundation

final class PhoneEmailSignInViewModel {
    var eventHandler: ((_ event: Event) -> Void)?
    
    func checkEmail(parameters: CheckEmailRequest) {
        APIManager.shared.request(
            modelType: CheckEmailResponse.self,
            type: ProductEndPoint.checkEmail(checkEmail: parameters)) { result in
                switch result {
                case .success(let checkEmail):
                    self.eventHandler?(.newCheckEmail(checkEmail: checkEmail))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func verifyPhoneNo(parameters: VerifyPhoneNoRequest) {
        APIManager.shared.request(
            modelType: VerifyPhoneNoResponse.self,
            type: ProductEndPoint.verifyPhoneNo(verifyPhoneNo: parameters)) { result in
                switch result {
                case .success(let verifyPhoneNo):
                    self.eventHandler?(.newVerifyPhoneNoAdded(verifyPhoneNo: verifyPhoneNo))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func verifyPhoneNoWithCode(parameters: VerifyPhoneNoRequest) {
        APIManager.shared.request(
            modelType: VerifyPhoneNoResponse.self,
            type: ProductEndPoint.verifyPhoneNo(verifyPhoneNo: parameters)) { result in
                switch result {
                case .success(let verifyPhoneNo):
                    self.eventHandler?(.newVerifyPhoneNoWithCodeAdded(verifyPhoneNo: verifyPhoneNo))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
  
    func registerPhone(parameters: RegisterUserAppRequest) {
        APIManager.shared.request(
            modelType: RegisterUserResponse.self,
            type: ProductEndPoint.registerUserApp(registerUserApp: parameters)) { result in
                switch result {
                case .success(let registerPhone):
                    self.eventHandler?(.newRegisterUser(registerPhone: registerPhone))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }

    func showUserDetail(parameters: ShowUserDetailRequest) {
        APIManager.shared.request(
            modelType: FollowUserReponse.self,
            type: ProductEndPoint.showUserDetail(showUserDetail: parameters)) { result in
                switch result {
                case .success(let showUserDetail):
                    self.eventHandler?(.newShowUserDetail(showUserDetail: showUserDetail))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
}

extension PhoneEmailSignInViewModel {
    enum Event {
        case error(Error?)
        case newCheckEmail(checkEmail: CheckEmailResponse)
        case newVerifyPhoneNoAdded(verifyPhoneNo: VerifyPhoneNoResponse)
        case newVerifyPhoneNoWithCodeAdded(verifyPhoneNo: VerifyPhoneNoResponse)
        case newLogin(login: LoginResponse)
        case newRegisterUser(registerPhone: RegisterUserResponse)
        case newShowUserDetail(showUserDetail: FollowUserReponse)
    }
}
