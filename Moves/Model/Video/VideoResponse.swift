//
//  VideoResponse.swift
// //
//
//  Created by Wasiq Tayyab on 28/06/2024.
//

import Foundation

struct VideoMainMVC {
    // Video properties
    var videoId: Int
    var userID: Int
    var videoDescription: String
    var video: String
    var soundID: Int
    var privacyType: String
    var allowComments: String
    var allowDuet: Int
    var block: Int
    var duetVideoID: Int
    var oldVideoID: Int
    var duration: Double
    var promote: Int
    var pinCommentID: Int
    var pin: Int
    var repostUserID: Int
    var repostVideoID: Int
    var qualityCheck: Int
    var viral: Int
    var story: Int
    var countryID: Int
    var city: String
    var state: String
    var country: String
    var region: String
    var locationString: String
    var locationID: Int
    var share: Int
    var videoWithWatermark: String
    var productID: String?
    var jobID: String
    var tagProduct: Int
    var width: Int
    var height: Int
    var aiSummary: String
    var aiCategory: String
    var aiHashtags: String
    var aiFilters: String
    var like: Int
    var favourite: Int
    var repost: Int
    var favouriteCount: Int
    var commentCount: Int
    var likeCount: Int

    // Privacy properties
    var videosDownload: StringOrInt
    var directMessage: StringOrInt
    var duet: StringOrInt
    var likedVideos: StringOrInt
    var videoComment: StringOrInt
    var orderHistory: StringOrInt

    // Push notification properties
    var likes: StringOrInt
    var comments: StringOrInt
    var newFollowers: StringOrInt
    var mentions: StringOrInt
    var directMessages: StringOrInt
    var videoUpdates: StringOrInt

    // User properties

    var firstName: String
    var lastName: String
    var bio: String
    var website: String
    var profilePic: String
    var profilePicSmall: String
    var profileGIF: String
    var deviceToken: String
    var business: Int
    var parent: Int
    var username: String
    var verified: Int
    var button: String

    let soundThum: String
    
    // Location properties
    var locationId: Int
    var locationName: String
    var lat: String
    var long: String
    var googlePlaceID: String
    var image: String
    
    
    
    let audio: String
    let soundName: String
    let soundDescription: String
    
    var videoProduct: [VideoProduct]?
    var store: Store?
}
