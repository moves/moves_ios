//
//  BlockUserViewModel.swift
// //
//
//  Created by Wasiq Tayyab on 25/06/2024.
//

import Foundation

final class BlockUserViewModel {
    var eventHandler: ((_ event: Event) -> Void)?
    
    var showBlockedUsers: ShowBlockedUsersResponse?
    var showFavouriteVideos: HomeResponse?


    func showBlockedUsers(parameters: ShowBlockedUsersRequest) {
            APIManager.shared.request(
                modelType: ShowBlockedUsersResponse.self,
                type: ProductEndPoint.showBlockedUsers(showBlockedUsers: parameters)
            ) { result in
                switch result {
                case .success(let showBlockedUsers):
                    self.eventHandler?(.newShowBlockedUsers(showBlockedUsers: showBlockedUsers))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
        }
    
    func blockUser(parameters: BlockUserRequest) {
            APIManager.shared.request(
                modelType: ShowBlockedUserResponse.self,
                type: ProductEndPoint.blockUser(blockUser: parameters)
            ) { result in
                switch result {
                case .success(let blockUser):
                    self.eventHandler?(.newBlockUser(blockUser: blockUser))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
        }
    
    func showFavouriteVideos(parameters: FriendsRequest) {
        APIManager.shared.request(
            modelType: HomeResponse.self,
            type: ProductEndPoint.showFavouriteVideos(showFavouriteVideos: parameters)
        ) { result in
            switch result {
            case .success(let showFavouriteVideos):
                self.eventHandler?(.newShowFavouriteVideos(showFavouriteVideos: showFavouriteVideos))
            case .failure(let error):
                self.eventHandler?(.error(error))
            }
        }
    }
    
}

extension BlockUserViewModel {
    enum Event {
        case error(Error?)
        case newShowBlockedUsers(showBlockedUsers: ShowBlockedUsersResponse)
        case newBlockUser(blockUser: ShowBlockedUserResponse)
        case newShowFavouriteVideos(showFavouriteVideos: HomeResponse)
    }
}
