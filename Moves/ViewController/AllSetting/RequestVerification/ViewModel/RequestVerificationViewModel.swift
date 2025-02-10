//
//  RequestVerificationViewModel.swift
// //
//
//  Created by Wasiq Tayyab on 25/06/2024.
//

import Foundation

final class RequestVerificationViewModel {
    var eventHandler: ((_ event: Event) -> Void)?
    
    func userVerificationRequest(parameters: UserVerificationRequest) {
        APIManager.shared.request(
            modelType: UserVerificationResponse.self,
            type: ProductEndPoint.userVerificationRequest(userVerificationRequest: parameters)) { result in
                switch result {
                case .success(let userVerificationRequest):
                    self.eventHandler?(.newUserVerificationRequest(userVerificationRequest: userVerificationRequest))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
}

extension RequestVerificationViewModel {
    enum Event {
        case error(Error?)
        case newUserVerificationRequest(userVerificationRequest: UserVerificationResponse)

    }
}
