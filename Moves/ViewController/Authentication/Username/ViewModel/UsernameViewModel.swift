//
//  UsernameViewModel.swift
// //
//
//  Created by Wasiq Tayyab on 12/05/2024.
//

import Foundation

final class UsernameViewModel {
    var eventHandler: ((_ event: Event) -> Void)?

    func checkUsername(parameters: CheckUsernameRequest) {
        APIManager.shared.request(
            modelType: VerifyPhoneNoResponse.self,
            type: ProductEndPoint.checkUsername(checkUsername: parameters))
        { result in
            switch result {
            case .success(let checkUsername):
                self.eventHandler?(.newCheckUsername(checkUsername: checkUsername))
            case .failure(let error):
                self.eventHandler?(.error(error))
            }
        }
    }

    func registerEmail(parameters: RegisterUserAppRequest) {
        APIManager.shared.request(
            modelType: RegisterUserResponse.self,
            type: ProductEndPoint.registerUserApp(registerUserApp: parameters))
        { result in
            switch result {
            case .success(let registerPhone):
                self.eventHandler?(.newRegisterPhone(registerPhone: registerPhone))
            case .failure(let error):
                self.eventHandler?(.error(error))
            }
        }
    }
}

extension UsernameViewModel {
    enum Event {
        case error(Error?)
        case newCheckUsername(checkUsername: VerifyPhoneNoResponse)
        case newRegisterPhone(registerPhone: RegisterUserResponse)
    }
}
