//
//  PrivacyPolicyViewModel.swift
// //
//
//  Created by Wasiq Tayyab on 28/06/2024.
//

import Foundation

final class PrivacyPolicyViewModel {
    var eventHandler: ((_ event: Event) -> Void)?
    
    func addPrivacySetting(parameters: AddPrivacySettingRequest) {
        APIManager.shared.request(
            modelType: AddPrivacySettingResponse.self,
            type: ProductEndPoint.addPrivacySetting(addPrivacySetting: parameters)) { result in
                switch result {
                case .success(let addPrivacySetting):
                    self.eventHandler?(.newAddPrivacySetting(addPrivacySetting: addPrivacySetting))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
}

extension PrivacyPolicyViewModel {
    enum Event {
        case error(Error?)
        case newAddPrivacySetting(addPrivacySetting: AddPrivacySettingResponse)
    }
}
