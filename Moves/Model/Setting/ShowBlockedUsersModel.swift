//
//  ShowBlockedUsersModel.swift
// //
//
//  Created by Wasiq Tayyab on 25/06/2024.
//

import Foundation

// MARK: - ShowBlockedUsersResponse
struct ShowBlockedUsersResponse: Codable {
    let code: Int
    var msg: [ShowBlockedUsersResponseMsg]?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode([ShowBlockedUsersResponseMsg].self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
    
    
}

struct ShowBlockedUserResponse: Codable {
    let code: Int
    var msg: ShowBlockedUsersResponseMsg?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode(ShowBlockedUsersResponseMsg.self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
    
    
}

// MARK: - Msg
struct ShowBlockedUsersResponseMsg: Codable {
    let blockUser: BlockUser
    let blockedUser: BlockedUser

    enum CodingKeys: String, CodingKey {
        case blockUser = "BlockUser"
        case blockedUser = "BlockedUser"
    }
}

// MARK: - BlockUser
struct BlockUser: Codable {
    let id, userID, blockUserID: Int
    let created: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case blockUserID = "block_user_id"
        case created
    }
}

// MARK: - BlockedUser
struct BlockedUser: Codable {
    let id: Int
    let firstName, lastName, gender, bio: String
    let website, dob, socialID, email: String
    let phone, password: String
    let profilePic, profilePicSmall: String
    let profileGIF, profileVideo, role, username: String
    let social, deviceToken, token: String
    let active: Int
    let lat, long: String
    let online, verified: Int
    let authToken, version, device, ip: String
    let city, country, state, region: String
    let locationString: String
    let countryID, wallet: Int
    let paypal: String
    let blockedUserPrivate, profileView: Int
    let resetWalletDatetime, referralCode: String
    let business, parent: Int
    let created: String

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
        case blockedUserPrivate = "private"
        case profileView = "profile_view"
        case resetWalletDatetime = "reset_wallet_datetime"
        case referralCode = "referral_code"
        case business, parent, created
    }
}
