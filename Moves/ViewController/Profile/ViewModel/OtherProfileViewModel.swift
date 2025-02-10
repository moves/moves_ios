//
//  OtherProfileViewModel.swift
// //
//
//  Created by Wasiq Tayyab on 13/09/2024.
//

import Foundation

final class OtherProfileViewModel {
    var eventHandler: ((_ event: Event) -> Void)?
    
    func showOtherUserDetailForUsername(parameters: CheckUsernameRequest) {
        APIManager.shared.request(
            modelType: ProfileResponse.self,
            type: ProductEndPoint.showUserDetailForUsername(showUserDetailForUsername: parameters)) { result in
                switch result {
                case .success(let showOtherUserDetailForUsername):
                    self.eventHandler?(.showOtherUserDetailForUsername(showOtherUserDetailForUsername: showOtherUserDetailForUsername))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }

}

extension OtherProfileViewModel {
    enum Event {
        case error(Error?)
        case showOtherUserDetailForUsername(showOtherUserDetailForUsername: ProfileResponse)
    }
}

