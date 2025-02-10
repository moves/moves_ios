//
//  ProfileViewViewModel.swift
// //
//
//  Created by Wasiq Tayyab on 22/06/2024.
//

import Foundation


final class ProfileViewViewModel {
    var eventHandler: ((_ event: Event) -> Void)?
    
    var showProfileVisitors: ShowProfileVisitorsResponse?

    func showProfileVisitors(parameters: FriendsRequest) {
            APIManager.shared.request(
                modelType: ShowProfileVisitorsResponse.self,
                type: ProductEndPoint.showProfileVisitors(showProfileVisitors: parameters)
            ) { result in
                switch result {
                case .success(let showProfileVisitors):
                    self.eventHandler?(.newShowProfileVisitors(showProfileVisitors: showProfileVisitors))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
        }
    
}

extension ProfileViewViewModel {
    enum Event {
        case error(Error?)
        case newShowProfileVisitors(showProfileVisitors: ShowProfileVisitorsResponse)
    }
}
