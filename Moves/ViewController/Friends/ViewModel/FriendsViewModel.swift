//
//  FriendsViewModel.swift
// //
//
//  Created by Wasiq Tayyab on 15/06/2024.
//

import Foundation

final class FriendsViewModel {
    var eventHandler: ((_ event: Event) -> Void)?
    
    var showSuggestedUsers: SuggestedResponse?
    var showFollowing: FollowingResponse?
    var showFollowers: FollowerResponse?
    
    func showSuggestedUsers(parameters: ShowSuggestedUsersRequest) {
        APIManager.shared.request(
            modelType: SuggestedResponse.self,
            type: ProductEndPoint.showSuggestedUsers(showSuggestedUsers: parameters)) { result in
                switch result {
                case .success(let showSuggestedUsers):
                    self.eventHandler?(.newShowSuggestedUsers(showSuggestedUsers: showSuggestedUsers))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    func showFollowing(parameters: FriendsRequest) {
        APIManager.shared.request(
            modelType: FollowingResponse.self,
            type: ProductEndPoint.showFollowing(showFollowing: parameters)) { result in
                switch result {
                case .success(let showFollowing):
                    self.eventHandler?(.newShowFollowing(showFollowing: showFollowing))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func showFollowers(parameters: FriendsRequest) {
        APIManager.shared.request(
            modelType: FollowerResponse.self,
            type: ProductEndPoint.showFollowers(showFollowers: parameters)) { result in
                switch result {
                case .success(let showFollowers):
                    self.eventHandler?(.newShowFollowers(showFollowers: showFollowers))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
}

extension FriendsViewModel {
    enum Event {
        case error(Error?)
        case newShowSuggestedUsers(showSuggestedUsers: SuggestedResponse)
        case newShowFollowing(showFollowing: FollowingResponse)
        case newShowFollowers(showFollowers: FollowerResponse)
    }
}
