//
//  SignUpViewModel.swift
// //
//
//  Created by Wasiq Tayyab on 12/06/2024.
//

import Foundation
import UIKit

final class SignUpViewModel {
    var eventHandler: ((_ event: Event) -> Void)?
    var verifyAccountDetails : FollowUserReponse?
    func verifyAccountDetails(parameters: VerifyAccountDetailsRequest) {
        APIManager.shared.request(
            modelType: FollowUserReponse.self,
            type: ProductEndPoint.verifyAccountDetails(verifyAccountDetails: parameters)) { result in
                switch result {
                case .success(let verifyAccountDetails):
                    self.eventHandler?(.newVerifyAccountDetails(verifyAccountDetails: verifyAccountDetails))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
}

extension SignUpViewModel {
    enum Event {
        case error(Error?)
        case newVerifyAccountDetails(verifyAccountDetails: FollowUserReponse)
    }
}
