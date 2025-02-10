//
//  EditProfileViewModel.swift
// //
//
//  Created by Wasiq Tayyab on 26/06/2024.
//

import Foundation

final class EditProfileViewModel {
    var eventHandler: ((_ event: Event) -> Void)?
    
    func editProfile(parameters: EditProfileRequest) {
        APIManager.shared.request(
            modelType: ProfileResponse.self,
            type: ProductEndPoint.editProfile(editProfile: parameters)
        ) { result in
            switch result {
            case .success(let editProfile):
                self.eventHandler?(.newEditProfile(editProfile: editProfile))
            case .failure(let error):
                self.eventHandler?(.error(error))
            }
        }
    }
}

extension EditProfileViewModel {
    enum Event {
        case error(Error?)
        case newEditProfile(editProfile: ProfileResponse)
    }
}
