//
//  ProductEndPoint.swift
//  Tankhaw
//
//  Created by Mac on 21/03/2024.
//

import Foundation

enum ProductEndPoint {
    case checkEmail(checkEmail: CheckEmailRequest)
    case verifyPhoneNo(verifyPhoneNo: VerifyPhoneNoRequest)
    case addDeviceData(addDeviceData: AddDeviceDataRequest)
    case registerDevice(registerDevice: RegisterDeviceRequest)
    case checkUsername(checkUsername: CheckUsernameRequest)
    case search(search: SearchRequest)
    case showRelatedVideos(showRelatedVideos: HomeRequest)
    case showDiscoverySections(showDiscoverySections: DiscoverRequest)
    case showAllNotifications(showAllNotifications: NotificationRequest)
    case followUser(followUser: FollowUserRequest)
    case showNearbyVideos(showNearbyVideos: ShowNearbyVideosRequest)
    case showFollowingVideos(showFollowingVideos: ShowFollowingVideosRequest)
    case showUserDetail(showUserDetail: ShowUserDetailRequest)
    case showOtherUserDetail(showOtherUserDetail: ShowUserOtherDetailRequest)
    case verifyAccountDetails(verifyAccountDetails: VerifyAccountDetailsRequest)
    case showVideosAgainstUserID(showVideosAgainstUserID: ShowVideosAgainstUserIDRequest)
    case showUserLikedVideos(showUserLikedVideos: ShowVideosAgainstUserIDRequest)
    case showUserRepostedVideos(showUserRepostedVideos: ShowVideosAgainstUserIDRequest)
    case showFollowing(showFollowing: FriendsRequest)
    case showFollowers(showFollowers: FriendsRequest)
    case showSuggestedUsers(showSuggestedUsers: ShowSuggestedUsersRequest)
    case showVideosAgainstHashtag(showVideosAgainstHashtag: ShowVideosAgainstHashtagRequest)
    case addHashtagFavourite(addHashtagFavourite: AddHashtagFavouriteRequest)
    case showVideosAgainstSound(showVideosAgainstSound: ShowVideosAgainstSoundRequest)
    case showProfileVisitors(showProfileVisitors: FriendsRequest)
    case showFavouriteVideos(showFavouriteVideos: FriendsRequest)
    case registerUserApp(registerUserApp: RegisterUserAppRequest)
    case showVideosAgainstLocation(showVideosAgainstLocation: ShowVideosAgainstLocationRequest)
    case userVerificationRequest(userVerificationRequest: UserVerificationRequest)
    case showBlockedUsers(showBlockedUsers: ShowBlockedUsersRequest)
    case blockUser(blockUser: BlockUserRequest)
    case editProfile(editProfile: EditProfileRequest)
    case deleteUserAccount(deleteUserAccount: DeleteUserAccountRequest)
    case likeVideo(likeVideo: LikeVideoRequest)
    case addVideoFavourite(addVideoFavourite: LikeVideoRequest)
    case showVideoDetail(showVideoDetail: LikeVideoRequest)
    case addPrivacySetting(addPrivacySetting: AddPrivacySettingRequest)
    case sendNotification(sendNotification: SendNotificationRequest)
    case postCommentOnVideo(postCommentOnVideo: PostCommentRequest)
    case showVideoComments(showVideoComments: CommentRequest)
    case likeComment(likeComment: LikeCommentRequest)
    case deleteVideoComment(deleteVideoComment: DeleteVideoCommentRequest)
    case postCommentReply(postCommentReply: PostCommentReplyRequest)
    case likeReplyComments(likeReplyComments: LikeReplyCommentsRequest)
    case deleteVideoCommentReply(deleteVideoCommentReply: DeleteVideoCommentRequest)
    case deleteVideo(deleteVideo: DeleteVideoRequest)
    case showSounds(showSounds: ShowSoundsRequest)
    case showFavouriteSounds(showSounds: ShowSoundsRequest)
    case addFavouriteSounds(addFvrtSounds: addFvrtSoundsRequest)
    case withdrawRequest(withdrawRequest: WithdrawRequest)
    case addpayout(addpayout: AddPayoutRequest)
    case showCoinWorth
    case readNotification(readNotification: SettingRequest)
    case showUserDetailForUsername(showUserDetailForUsername: CheckUsernameRequest)
    case showReportReasons
    case reportVideo(reportVideo: ReportVideoRequest)
    case repostVideo(repostVideo: DeleteVideoRequest)
    case purchaseCoin(purchaseCoin: PurchaseCoinRequest)
    case coinWithDrawRequest(coinWithDrawRequest: CoinWithDrawRequest)
    case reportUser(reportUser: ReportVideoRequest)
}

extension ProductEndPoint: EndPointType {
    var path: String {
        switch self {
        case .checkEmail:
            return "checkEmail"
        case .verifyPhoneNo:
            return "verifyPhoneNo"
        case .addDeviceData(addDeviceData: _):
            return "addDeviceData"
        case .registerDevice(registerDevice: _):
            return "registerDevice"
        case .checkUsername(checkUsername: _):
            return "checkUsername"
        case .search(search: _):
            return "search"
        case .showRelatedVideos(showRelatedVideos: _):
            return "showRelatedVideos"
        case .showDiscoverySections(showDiscoverySections: _):
            return "showDiscoverySections"
        case .showAllNotifications(showAllNotifications: _):
            return "showAllNotifications"
        case .followUser:
            return "followUser"
        case .showNearbyVideos(showNearbyVideos: _):
            return "showNearbyVideos"
        case .showFollowingVideos(showFollowingVideos: _):
            return "showFollowingVideos"
        case .showUserDetail(showUserDetail: _):
            return "showUserDetail"
        case .verifyAccountDetails(verifyAccountDetails: _):
            return "verifyAccountDetails"
        case .showVideosAgainstUserID(showVideosAgainstUserID: _):
            return "showVideosAgainstUserID"
        case .showUserLikedVideos(showUserLikedVideos: _):
            return "showUserLikedVideos"
        case .showFollowing(showFollowing: _):
            return "showFollowing"
        case .showFollowers(showFollowers: _):
            return "showFollowers"
        case .showSuggestedUsers(showSuggestedUsers: _):
            return "showSuggestedUsers"
        case .showVideosAgainstHashtag(showVideosAgainstHashtag: _):
            return "showVideosAgainstHashtag"
        case .addHashtagFavourite(addHashtagFavourite: _):
            return "addHashtagFavourite"
        case .showVideosAgainstSound(showVideosAgainstSound: _):
            return "showVideosAgainstSound"
        case .showProfileVisitors(showProfileVisitors: _):
            return "showProfileVisitors"
        case .showFavouriteVideos(showFavouriteVideos: _):
            return "showFavouriteVideos"
        case .showOtherUserDetail(showOtherUserDetail: _):
            return "showUserDetail"
        case .registerUserApp(registerUserApp: _):
            return "registerUser"
        case .showVideosAgainstLocation(showVideosAgainstLocation: _):
            return "showVideosAgainstLocation"
        case .userVerificationRequest(userVerificationRequest: _):
            return "userVerificationRequest"
        case .showBlockedUsers(showBlockedUsers: _):
            return "showBlockedUsers"
        case .blockUser(blockUser: _):
            return "blockUser"
        case .editProfile(editProfile: _):
            return "editProfile"
        case .deleteUserAccount(deleteUserAccount: _):
            return "deleteUserAccount"
        case .likeVideo(likeVideo: _):
            return "likeVideo"
        case .addVideoFavourite(addVideoFavourite: _):
            return "addVideoFavourite"
        case .showVideoDetail(showVideoDetail: _):
            return "showVideoDetail"
        case .addPrivacySetting(addPrivacySetting: _):
            return "addPrivacySetting"
        case .sendNotification(sendNotification: _):
            return "sendNotification"
        case .postCommentOnVideo(postCommentOnVideo: _):
            return "postCommentOnVideo"
        case .showVideoComments(showVideoComments: _):
            return  "showVideoComments"
        case .likeComment(likeComment: _):
            return "likeComment"
        case .deleteVideoComment(deleteVideoComment: _):
            return "deleteVideoComment"
        case .postCommentReply(postCommentReply: _):
            return "postCommentOnVideo"
        case .likeReplyComments(likeReplyComments: _):
            return "likeCommentReply"
        case .deleteVideoCommentReply(deleteVideoCommentReply: _):
            return "deleteVideoCommentReply"
        case .deleteVideo(deleteVideo: _):
            return "deleteVideo"
        case .showSounds(showSounds: _):
            return "showSounds"
        case .showFavouriteSounds(showSounds: _):
            return "showFavouriteSounds"
        case .addFavouriteSounds(addFvrtSounds: _):
            return "addSoundFavourite"
        case .withdrawRequest(withdrawRequest: _):
            return "withdrawRequest"
        case .addpayout(addpayout: _):
            return "addpayout"
        case .readNotification(readNotification: _):
            return "readNotification"
        case .showUserDetailForUsername(showUserDetailForUsername: _):
            return "showUserDetail"
        case .showReportReasons:
            return "showReportReasons"
        case .reportVideo(reportVideo: _):
            return "reportVideo"
        case .repostVideo(repostVideo: _):
            return "repostVideo"
        case .showUserRepostedVideos(showUserRepostedVideos: _):
            return "showUserRepostedVideos"
        case .purchaseCoin(purchaseCoin: _):
            return "purchaseCoin"
        case .showCoinWorth:
            return "showCoinWorth"
        case .coinWithDrawRequest(coinWithDrawRequest: let coinWithDrawRequest):
            return "withdrawRequest"
        case .reportUser(reportUser: let reportUser):
            return "reportUser"
        }
    }
    
    var baseURL: String {
        return "https://app.movesapp.io/mobileapp_api/api/"
    }
    
    var url: URL? {
        print("url","\(baseURL)\(path)")
        return URL(string: "\(baseURL)\(path)")
    }
    
    var method: HTTPMethods {
        return .post
    }
    
    var body: Encodable? {
        switch self {
        case .checkEmail(let checkEmail):
            return checkEmail
        case .verifyPhoneNo(let verifyPhoneNo):
            return verifyPhoneNo
        case .addDeviceData(addDeviceData: let addDeviceData):
            return addDeviceData
        case .registerDevice(registerDevice: let registerDevice):
            return registerDevice
        case .checkUsername(checkUsername: let checkUsername):
            return checkUsername
        case .search(search: let search):
            return search
        case .showRelatedVideos(showRelatedVideos: let showRelatedVideos):
            return showRelatedVideos
        case .showDiscoverySections(showDiscoverySections: let showDiscoverySections):
            return showDiscoverySections
        case .showAllNotifications(showAllNotifications: let showAllNotifications):
            return showAllNotifications
        case .followUser(followUser: let followUser):
            return followUser
        case .showNearbyVideos(showNearbyVideos: let showNearbyVideos):
            return showNearbyVideos
        case .showFollowingVideos(showFollowingVideos: let showFollowingVideos):
            return showFollowingVideos
        case .showUserDetail(showUserDetail: let showUserDetail):
            return showUserDetail
        case .verifyAccountDetails(verifyAccountDetails: let verifyAccountDetails):
            return verifyAccountDetails
        case .showVideosAgainstUserID(showVideosAgainstUserID: let showVideosAgainstUserID):
            return showVideosAgainstUserID
        case .showUserLikedVideos(showUserLikedVideos: let showUserLikedVideos):
            return showUserLikedVideos
        case .showFollowing(showFollowing: let showFollowing):
            return showFollowing
        case .showFollowers(showFollowers: let showFollowers):
            return showFollowers
        case .showSuggestedUsers(showSuggestedUsers: let showSuggestedUsers):
            return showSuggestedUsers
        case .showVideosAgainstHashtag(showVideosAgainstHashtag: let showVideosAgainstHashtag):
            return showVideosAgainstHashtag
        case .addHashtagFavourite(addHashtagFavourite: let addHashtagFavourite):
            return addHashtagFavourite
        case .showVideosAgainstSound(showVideosAgainstSound: let showVideosAgainstSound):
            return showVideosAgainstSound
        case .showProfileVisitors(showProfileVisitors: let showProfileVisitors):
            return showProfileVisitors
        case .showFavouriteVideos(showFavouriteVideos: let showFavouriteVideos):
            return showFavouriteVideos
        case .showOtherUserDetail(showOtherUserDetail: let showOtherUserDetail):
            return showOtherUserDetail
        case .registerUserApp(registerUserApp: let registerUserApp):
            return registerUserApp
        case .showVideosAgainstLocation(showVideosAgainstLocation: let showVideosAgainstLocation):
            return showVideosAgainstLocation
        case .userVerificationRequest(userVerificationRequest: let userVerificationRequest):
            return userVerificationRequest
        case .showBlockedUsers(showBlockedUsers: let showBlockedUsers):
            return showBlockedUsers
        case .blockUser(blockUser: let blockUser):
            return blockUser
        case .editProfile(editProfile: let editProfile):
            return editProfile
        case .deleteUserAccount(deleteUserAccount: let deleteUserAccount):
            return deleteUserAccount
        case .likeVideo(likeVideo: let likeVideo):
            return likeVideo
        case .addVideoFavourite(addVideoFavourite: let addVideoFavourite):
            return addVideoFavourite
        case .showVideoDetail(showVideoDetail: let showVideoDetail):
            return showVideoDetail
        case .addPrivacySetting(addPrivacySetting: let addPrivacySetting):
            return addPrivacySetting
        case .sendNotification(sendNotification: let sendNotification):
            return sendNotification
        case .postCommentOnVideo(postCommentOnVideo: let postCommentOnVideo):
            return postCommentOnVideo
        case .showVideoComments(showVideoComments: let showVideoComments):
            return showVideoComments
        case .likeComment(likeComment: let likeComment):
            return likeComment
        case .deleteVideoComment(deleteVideoComment: let deleteVideoComment):
            return deleteVideoComment
        case .postCommentReply(postCommentReply: let postCommentReply):
            return postCommentReply
        case .likeReplyComments(likeReplyComments: let likeReplyComments):
            return likeReplyComments
        case .deleteVideoCommentReply(deleteVideoCommentReply: let deleteVideoCommentReply):
            return deleteVideoCommentReply
        case .deleteVideo(deleteVideo: let deleteVideo):
            return deleteVideo
        case .showSounds(showSounds: let showSounds):
            return showSounds
        case .showFavouriteSounds(showSounds: let showSounds):
            return showSounds
        case .addFavouriteSounds(addFvrtSounds: let fvrtSounds):
            return fvrtSounds
        case .withdrawRequest(withdrawRequest: let withdrawRequest):
            return withdrawRequest
        case .addpayout(addpayout: let addpayout):
            return addpayout
            return nil
        case .readNotification(readNotification: let readNotification):
            return readNotification
        case .showUserDetailForUsername(showUserDetailForUsername: let showUserDetailForUsername):
            return showUserDetailForUsername
        case .showReportReasons:
            return nil
        case .reportVideo(reportVideo: let reportVideo):
            return reportVideo
        case .repostVideo(repostVideo: let repostVideo):
            return repostVideo
        case .showUserRepostedVideos(showUserRepostedVideos: let showUserRepostedVideos):
            return showUserRepostedVideos
        case .purchaseCoin(purchaseCoin: let purchaseCoin):
            return purchaseCoin
        case .showCoinWorth:
            return nil
        case .coinWithDrawRequest(coinWithDrawRequest: let coinWithDrawRequest):
            return coinWithDrawRequest
        case .reportUser(reportUser: let reportUser):
            return reportUser
        }
    }
    
    var headers: [String : String]? {
        APIManager.commonHeaders
    }
}
