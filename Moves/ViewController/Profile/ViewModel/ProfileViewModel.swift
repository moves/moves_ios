//
//  ProfileViewModel.swift
// //
//
//  Created by Wasiq Tayyab on 14/06/2024.
//

import Foundation

final class ProfileViewModel {
    var eventHandler: ((_ event: Event) -> Void)?
    var showVideosAgainstUserID: ShowVideosAgainstUserIDResponse?
    var privateShowVideosAgainstUserID: ShowPrivateVideosAgainstUserIDResponse?
    var showUserLikedVideos: HomeResponse?
    var showTaggedVideosAgainstUserID: HomeResponse?
    var showOrderPlacedVideos: HomeResponse?
    var showFavouriteVideos: HomeResponse?
    var showStoreTaggedVideos: HomeResponse?
    
    func showUserDetail(parameters: ShowUserDetailRequest) {
        APIManager.shared.request(
            modelType: ProfileResponse.self,
            type: ProductEndPoint.showUserDetail(showUserDetail: parameters)) { result in
                switch result {
                case .success(let showUserDetail):
                    self.eventHandler?(.newShowUserDetail(showUserDetail: showUserDetail))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func showOtherUserDetail(parameters: ShowUserOtherDetailRequest) {
        APIManager.shared.request(
            modelType: ProfileResponse.self,
            type: ProductEndPoint.showOtherUserDetail(showOtherUserDetail: parameters)) { result in
                switch result {
                case .success(let showOtherUserDetail):
                    self.eventHandler?(.newShowOtherUserDetail(showOtherUserDetail: showOtherUserDetail))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
 
    
    func showVideosAgainstUserID(parameters: ShowVideosAgainstUserIDRequest) {
        APIManager.shared.request(
            modelType: ShowVideosAgainstUserIDResponse.self,
            type: ProductEndPoint.showVideosAgainstUserID(showVideosAgainstUserID: parameters)) { result in
                switch result {
                case .success(let showVideosAgainstUserID):
                    self.eventHandler?(.newShowVideosAgainstUserID(showVideosAgainstUserID: showVideosAgainstUserID))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func newShowPrivateVideosAgainstUserID(parameters: ShowVideosAgainstUserIDRequest) {
        APIManager.shared.request(
            modelType: ShowPrivateVideosAgainstUserIDResponse.self,
            type: ProductEndPoint.showVideosAgainstUserID(showVideosAgainstUserID: parameters)) { result in
                switch result {
                case .success(let showVideosAgainstUserID):
                    self.eventHandler?(.newShowPrivateVideosAgainstUserID(showPrivateVideosAgainstUserID: showVideosAgainstUserID))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func showUserLikedVideos(parameters: ShowVideosAgainstUserIDRequest) {
        APIManager.shared.request(
            modelType: HomeResponse.self,
            type: ProductEndPoint.showUserLikedVideos(showUserLikedVideos: parameters)) { result in
                switch result {
                case .success(let showUserLikedVideos):
                    self.eventHandler?(.newShowUserLikedVideos(showUserLikedVideos: showUserLikedVideos))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    
    func showFavouriteVideos(parameters: FriendsRequest) {
        APIManager.shared.request(
            modelType: HomeResponse.self,
            type: ProductEndPoint.showFavouriteVideos(showFavouriteVideos: parameters)) { result in
                switch result {
                case .success(let showFavouriteVideos):
                    self.eventHandler?(.newShowFavouriteVideos(showFavouriteVideos: showFavouriteVideos))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func deleteVideo(parameters: DeleteVideoRequest) {
        APIManager.shared.request(
            modelType: VerifyPhoneNoResponse.self,
            type: ProductEndPoint.deleteVideo(deleteVideo: parameters)) { result in
                switch result {
                case .success(let deleteVideo):
                    self.eventHandler?(.newDeleteVideo(deleteVideo: deleteVideo))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func withdrawRequest(parameters: WithdrawRequest) {
        APIManager.shared.request(
            modelType: VerifyPhoneNoResponse.self,
            type: ProductEndPoint.withdrawRequest(withdrawRequest: parameters)) { result in
                switch result {
                case .success(let withdrawRequest):
                    self.eventHandler?(.newWithdrawRequest(withdrawRequest: withdrawRequest))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func addpayout(parameters: AddPayoutRequest) {
        APIManager.shared.request(
            modelType: AddPayoutResponse.self,
            type: ProductEndPoint.addpayout(addpayout: parameters)) { result in
                switch result {
                case .success(let showPayout):
                    self.eventHandler?(.newShowPayout(showPayout: showPayout))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func showUserRepostedVideos(parameters: ShowVideosAgainstUserIDRequest) {
        APIManager.shared.request(
            modelType: HomeResponse.self,
            type: ProductEndPoint.showUserRepostedVideos(showUserRepostedVideos: parameters)) { result in
                switch result {
                case .success(let showUserRepostedVideos):
                    self.eventHandler?(.showUserRepostedVideos(showUserRepostedVideos: showUserRepostedVideos))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
}

extension ProfileViewModel {
    enum Event {
        case error(Error?)
        case newShowUserDetail(showUserDetail: ProfileResponse)
        case newShowOtherUserDetail(showOtherUserDetail: ProfileResponse)
        case newShowVideosAgainstUserID(showVideosAgainstUserID: ShowVideosAgainstUserIDResponse)
        case newShowUserLikedVideos(showUserLikedVideos: HomeResponse)
        case newShowFavouriteVideos(showFavouriteVideos: HomeResponse)
        case newDeleteVideo(deleteVideo: VerifyPhoneNoResponse)
        case newWithdrawRequest(withdrawRequest: VerifyPhoneNoResponse)
        case newShowPayout(showPayout: AddPayoutResponse)
        case newShowStoreTaggedVideos(showStoreTaggedVideos: HomeResponse)
        case newShowPrivateVideosAgainstUserID(showPrivateVideosAgainstUserID: ShowPrivateVideosAgainstUserIDResponse)
        case showUserRepostedVideos(showUserRepostedVideos: HomeResponse)
    }
}
