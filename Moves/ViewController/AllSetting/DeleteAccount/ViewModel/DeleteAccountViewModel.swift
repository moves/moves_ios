//
//  DeleteAccountViewModel.swift
// //
//
//  Created by Wasiq Tayyab on 26/06/2024.
//

import Foundation

final class DeleteAccountViewModel {
    var eventHandler: ((_ event: Event) -> Void)?
    
    func deleteUserAccount(parameters: DeleteUserAccountRequest) {
        APIManager.shared.request(
            modelType: VerifyPhoneNoResponse.self,
            type: ProductEndPoint.deleteUserAccount(deleteUserAccount: parameters)
        ) { result in
            switch result {
            case .success(let deleteUserAccount):
                self.eventHandler?(.newDeleteUserAccount(deleteUserAccount: deleteUserAccount))
            case .failure(let error):
                self.eventHandler?(.error(error))
            }
        }
    }
    
}

extension DeleteAccountViewModel {
    enum Event {
        case error(Error?)
        case newDeleteUserAccount(deleteUserAccount: VerifyPhoneNoResponse)
    }
}
