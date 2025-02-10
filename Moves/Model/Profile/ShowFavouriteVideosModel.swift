//
//  ShowFavouriteVideosModel.swift
// //
//
//  Created by Wasiq Tayyab on 23/06/2024.
//

import Foundation

// MARK: - ShowFavouriteVideosResponse
struct ShowFavouriteVideosResponse: Codable {
    let code: Int
    var msg: [ShowFavouriteVideosResponseMsg]?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode([ShowFavouriteVideosResponseMsg].self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct ShowFavouriteVideosResponseMsg: Codable {
    let videoFavourite: VideoFavourite
    let video: Video

    enum CodingKeys: String, CodingKey {
        case videoFavourite = "VideoFavourite"
        case video = "Video"
    }
}

// MARK: - Video
struct FavVideo: Codable {
    let id, userID: Int
    let description: String
    let video: String
    let thum, thumSmall: String
    let gif: String
    let view: Int
    let section: String
    let soundID: Int
    let privacyType, allowComments: String
    let allowDuet, block, duetVideoID, oldVideoID: Int
    let duration: Double
    let promote, pinCommentID, pin, repostUserID: Int
    let repostVideoID, qualityCheck, viral, story: Int
    let countryID: Int
    let city, state, country, region: String
    let locationString: String
    let locationID, share: Int
    let videoWithWatermark, lat, long: String
    let productID: String?
    let jobID: String
    let tagProduct, width, height: Int
    let aiSummary, aiCategory, aiHashtags, aiFilters: String
    let created: String
    let user: FaUser
    let sound: Sound
    let like, favourite, repost, commentCount: Int
    let likeCount, favouriteCount: Int

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case description, video, thum
        case thumSmall = "thum_small"
        case gif, view, section
        case soundID = "sound_id"
        case privacyType = "privacy_type"
        case allowComments = "allow_comments"
        case allowDuet = "allow_duet"
        case block
        case duetVideoID = "duet_video_id"
        case oldVideoID = "old_video_id"
        case duration, promote
        case pinCommentID = "pin_comment_id"
        case pin
        case repostUserID = "repost_user_id"
        case repostVideoID = "repost_video_id"
        case qualityCheck = "quality_check"
        case viral, story
        case countryID = "country_id"
        case city, state, country, region
        case locationString = "location_string"
        case locationID = "location_id"
        case share
        case videoWithWatermark = "video_with_watermark"
        case lat, long
        case productID = "product_id"
        case jobID = "job_id"
        case tagProduct = "tag_product"
        case width, height
        case aiSummary = "ai_summary"
        case aiCategory = "ai_category"
        case aiHashtags = "ai_hashtags"
        case aiFilters = "ai_filters"
        case created
        case user = "User"
        case sound = "Sound"
        case like, favourite, repost
        case commentCount = "comment_count"
        case likeCount = "like_count"
        case favouriteCount = "favourite_count"
    }
}

// MARK: - User
struct FaUser: Codable {
    let id: Int
    let firstName, lastName, bio, website: String
    let profilePic: String
    let profilePicSmall, profileGIF, deviceToken: String
    let business, parent: Int
    let username: String
    let verified: Int

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case bio, website
        case profilePic = "profile_pic"
        case profilePicSmall = "profile_pic_small"
        case profileGIF = "profile_gif"
        case deviceToken = "device_token"
        case business, parent, username, verified
    }
}


// MARK: - VideoFavourite
struct VideoFavourite: Codable {
    let id, userID, videoID: Int
    let created: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case videoID = "video_id"
        case created
    }
}
