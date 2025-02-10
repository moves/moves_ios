//
//  ShowOrderPlacedVideosModel.swift
// //
//
//  Created by Wasiq Tayyab on 23/06/2024.
//

import Foundation

// MARK: - ShowOrderPlacedVideosResponse
struct ShowOrderPlacedVideosResponse: Codable {
    let code: Int
    var msg: [ShowOrderPlacedVideosResponseMsg]?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode([ShowOrderPlacedVideosResponseMsg].self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct ShowOrderPlacedVideosResponseMsg: Codable {
    let order: OrderPlaced
    let user: UserOrder
    let video: Video

    enum CodingKeys: String, CodingKey {
        case order = "Order"
        case user = "User"
        case video = "Video"
    }
}

// MARK: - Order
struct OrderPlaced: Codable {
    let id, storeID, userID, deliveryAddressID: Int
    let cardID, pickup: Int
    let dropoffNote: String
    let pickupTipCents, driverTipCents: Int
    let transactionID: String
    let subtotal, serviceFee, smallOrderFee, totalWithoutTips: Int
    let totalWithTip, salesTax, deliveryFee, tip: Int
    let mealMeOrderID: String
    let discount, total, status: Int
    let statusString, deliveryDatetime, signature, signaturePersonName: String
    let device, version: String
    let videoID, cartRandomID: Int
    let completedDatetime: String
    let storeUserID: Int
    let trackingLink: String
    let markedPrice, earned: Int
    let created, email, phone: String

    enum CodingKeys: String, CodingKey {
        case id
        case storeID = "store_id"
        case userID = "user_id"
        case deliveryAddressID = "delivery_address_id"
        case cardID = "card_id"
        case pickup
        case dropoffNote = "dropoff_note"
        case pickupTipCents = "pickup_tip_cents"
        case driverTipCents = "driver_tip_cents"
        case transactionID = "transaction_id"
        case subtotal
        case serviceFee = "service_fee"
        case smallOrderFee = "small_order_fee"
        case totalWithoutTips = "total_without_tips"
        case totalWithTip = "total_with_tip"
        case salesTax = "sales_tax"
        case deliveryFee = "delivery_fee"
        case tip
        case mealMeOrderID = "meal_me_order_id"
        case discount, total, status
        case statusString = "status_string"
        case deliveryDatetime = "delivery_datetime"
        case signature
        case signaturePersonName = "signature_person_name"
        case device, version
        case videoID = "video_id"
        case cartRandomID = "cart_random_id"
        case completedDatetime = "completed_datetime"
        case storeUserID = "store_user_id"
        case trackingLink = "tracking_link"
        case markedPrice = "marked_price"
        case earned, created, email, phone
    }
}

// MARK: - User
struct UserOrder: Codable {
    let id: Int
    let firstName, lastName, bio, website: String
    let profilePic: String
    let profilePicSmall, profileGIF, deviceToken: String
    let business, parent: Int
    let username: String
    let verified: Int
    let pushNotification: PushNotification
    let privacySetting: PrivacySetting

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
        case pushNotification = "PushNotification"
        case privacySetting = "PrivacySetting"
    }
}

// MARK: - Video
struct VideoOrder: Codable {
    let id, userID: Int?
    let description: String?
    let video: String?
    let thum, thumSmall: String?
    let gif: String?
    let view: Int?
    let section: String?
    let soundID: Int?
    let privacyType, allowComments: String?
    let allowDuet, block, duetVideoID, oldVideoID: Int?
    let duration: Double?
    let promote, pinCommentID, pin, repostUserID: Int?
    let repostVideoID, qualityCheck, viral, story: Int?
    let countryID: Int?
    let city, state, country, region: String?
    let locationString: String?
    let locationID, share: Int?
    let videoWithWatermark, lat, long: String?
    let productID: String?
    let jobID: String?
    let tagProduct, width, height: Int?
    let aiSummary, aiCategory, aiHashtags, aiFilters: String?
    let created: String?
    let user: User?
    let sound: Sound?
    let videoProduct: [VideoProduct]?
    let repost, like, favourite, favouriteCount: Int
    let commentCount, likeCount: Int
    let playlistVideo: PlaylistVideo

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
        case videoProduct = "VideoProduct"
        case repost, like, favourite
        case favouriteCount = "favourite_count"
        case commentCount = "comment_count"
        case likeCount = "like_count"
        case playlistVideo = "PlaylistVideo"
    }
}
