//
//  LoginModel.swift
// //
//
//  Created by Wasiq Tayyab on 09/05/2024.
//

import Foundation

// MARK: - LoginModel
struct LoginResponse: Codable {
    let code: Int
    let msg: LoginMsg?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode(LoginMsg.self, forKey: .msg)
            errorMessage = nil
        } else {
            msg = nil
            errorMessage = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct LoginMsg: Codable {
    let user: User
    let pushNotification: PushNotification?
    let privacySetting: PrivacySetting?

    enum CodingKeys: String, CodingKey {
        case user = "User"
        case pushNotification = "PushNotification"
        case privacySetting = "PrivacySetting"
    }

}

// MARK: - PrivacySetting
struct PrivacySetting: Codable, Equatable {
    let id, videosDownload, directMessage, duet: StringOrInt?
    let likedVideos, videoComment, orderHistory: StringOrInt?

    enum CodingKeys: String, CodingKey {
        case id
        case videosDownload = "videos_download"
        case directMessage = "direct_message"
        case duet
        case likedVideos = "liked_videos"
        case videoComment = "video_comment"
        case orderHistory = "order_history"
    }
}

// MARK: - PushNotification
struct PushNotification: Codable, Equatable {
    let id, likes, comments, newFollowers: StringOrInt?
    let mentions, directMessages, videoUpdates: StringOrInt?

    enum CodingKeys: String, CodingKey {
        case id, likes, comments
        case newFollowers = "new_followers"
        case mentions
        case directMessages = "direct_messages"
        case videoUpdates = "video_updates"
    }
}

// MARK: - Store
struct LoginStore: Codable {
    let id, userID, mealmeStoreID, name: StringOrInt?
    let description, phoneNumber, foodPhotos, logoPhotos: StringOrInt?
    let logo, cover, latitude, longitude: StringOrInt?
    let type, pickupEnabled, deliveryEnabled, created: StringOrInt?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case mealmeStoreID = "mealme_store_id"
        case name, description
        case phoneNumber = "phone_number"
        case foodPhotos = "food_photos"
        case logoPhotos = "logo_photos"
        case logo, cover, latitude, longitude, type
        case pickupEnabled = "pickup_enabled"
        case deliveryEnabled = "delivery_enabled"
        case created
    }
}

// MARK: - User
struct User: Codable {
    let id: Int?
    let firstName, lastName, bio: String?
    let gender: String?
    let dob: String?
    let socialID: String?
    let website, email: String?
    let phone, password, profilePic, profilePicSmall: String?
    let profileGIF, profileVideo, role, username: String?
    let social, deviceToken, token: String?
    let active: Int?
    let lat, long: String?
    let online, verified: Int?
    let authToken, version, device, ip: String?
    let city, country, state, region: String?
    let locationString: String?
    let countryID, wallet: StringOrInt?
    let paypal: String?
    let userPrivate, profileView: Int?
    let resetWalletDatetime, referralCode: String?
    let business, parent: Int?
    let created: String?
    let comissionEarned, totalAllTimeCoins: StringOrInt?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case gender, bio, website, dob
        case socialID = "social_id"
        case email, phone, password
        case profilePic = "profile_pic"
        case profilePicSmall = "profile_pic_small"
        case profileGIF = "profile_gif"
        case profileVideo = "profile_video"
        case role, username, social
        case deviceToken = "device_token"
        case token, active, lat, long, online, verified
        case authToken = "auth_token"
        case version, device, ip, city, country, state, region
        case locationString = "location_string"
        case countryID = "country_id"
        case wallet, paypal
        case userPrivate = "private"
        case profileView = "profile_view"
        case resetWalletDatetime = "reset_wallet_datetime"
        case referralCode = "referral_code"
        case business, parent, created
        case comissionEarned = "comission_earned"
        case totalAllTimeCoins = "total_all_time_coins"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        self.gender = try container.decodeIfPresent(String.self, forKey: .gender)
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio)
        self.website = try container.decodeIfPresent(String.self, forKey: .website)
        self.dob = try container.decodeIfPresent(String.self, forKey: .dob)
        self.socialID = try container.decodeIfPresent(String.self, forKey: .socialID)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.phone = try container.decodeIfPresent(String.self, forKey: .phone)
        self.password = try container.decodeIfPresent(String.self, forKey: .password)
        self.profilePic = try container.decodeIfPresent(String.self, forKey: .profilePic)
        self.profilePicSmall = try container.decodeIfPresent(String.self, forKey: .profilePicSmall)
        self.profileGIF = try container.decodeIfPresent(String.self, forKey: .profileGIF)
        self.profileVideo = try container.decodeIfPresent(String.self, forKey: .profileVideo)
        self.role = try container.decodeIfPresent(String.self, forKey: .role)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        self.social = try container.decodeIfPresent(String.self, forKey: .social)
        self.deviceToken = try container.decodeIfPresent(String.self, forKey: .deviceToken)
        self.token = try container.decodeIfPresent(String.self, forKey: .token)
        self.active = try container.decodeIfPresent(Int.self, forKey: .active)
        self.lat = try container.decodeIfPresent(String.self, forKey: .lat)
        self.long = try container.decodeIfPresent(String.self, forKey: .long)
        self.online = try container.decodeIfPresent(Int.self, forKey: .online)
        self.verified = try container.decodeIfPresent(Int.self, forKey: .verified)
        self.authToken = try container.decodeIfPresent(String.self, forKey: .authToken)
        self.version = try container.decodeIfPresent(String.self, forKey: .version)
        self.device = try container.decodeIfPresent(String.self, forKey: .device)
        self.ip = try container.decodeIfPresent(String.self, forKey: .ip)
        self.city = try container.decodeIfPresent(String.self, forKey: .city)
        self.country = try container.decodeIfPresent(String.self, forKey: .country)
        self.state = try container.decodeIfPresent(String.self, forKey: .state)
        self.region = try container.decodeIfPresent(String.self, forKey: .region)
        self.locationString = try container.decodeIfPresent(String.self, forKey: .locationString)
        self.countryID = try container.decodeIfPresent(StringOrInt.self, forKey: .countryID)
        self.wallet = try container.decodeIfPresent(StringOrInt.self, forKey: .wallet)
        self.paypal = try container.decodeIfPresent(String.self, forKey: .paypal)
        self.userPrivate = try container.decodeIfPresent(Int.self, forKey: .userPrivate)
        self.profileView = try container.decodeIfPresent(Int.self, forKey: .profileView)
        self.resetWalletDatetime = try container.decodeIfPresent(String.self, forKey: .resetWalletDatetime)
        self.referralCode = try container.decodeIfPresent(String.self, forKey: .referralCode)
        self.business = try container.decodeIfPresent(Int.self, forKey: .business)
        self.parent = try container.decodeIfPresent(Int.self, forKey: .parent)
        self.created = try container.decodeIfPresent(String.self, forKey: .created)
        self.comissionEarned = try container.decodeIfPresent(StringOrInt.self, forKey: .comissionEarned)
        self.totalAllTimeCoins = try container.decodeIfPresent(StringOrInt.self, forKey: .totalAllTimeCoins)
    }
}
