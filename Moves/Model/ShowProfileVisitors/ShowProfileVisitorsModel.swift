//
//  ShowProfileVisitorsModel.swift
// //
//
//  Created by Wasiq Tayyab on 22/06/2024.
//

import Foundation

// MARK: - ShowProfileVisitorsResponse
struct ShowProfileVisitorsResponse: Codable {
    let code: Int
    var msg: [ShowProfileVisitorsResponseMsg]?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode([ShowProfileVisitorsResponseMsg].self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct ShowProfileVisitorsResponseMsg: Codable {
    let profileVisit: ProfileVisit
    let user: HomeUser
    var visitor: HomeUser

    enum CodingKeys: String, CodingKey {
        case profileVisit = "ProfileVisit"
        case user = "User"
        case visitor = "Visitor"
    }
}

// MARK: - ProfileVisit
struct ProfileVisit: Codable {
    let id, userID, visitorID, read: Int
    let created: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case visitorID = "visitor_id"
        case read, created
    }
}

// MARK: - Visitor
struct ProfileVisitor: Codable {
    let id: Int
    let firstName, lastName: String
    let bio: String
    let website: String
    let dob: String
    let socialID: String
    let email, phone, password: String
    let profilePic: String
    let profilePicSmall: String
    let profileGIF, profileVideo: String
    let role: String
    let username: String
    let social: String
    let deviceToken, token: String
    let active: Int
    let lat, long: String
    let online, verified: Int
    let authToken, version: String
    let device: String
    let ip, city, country, state: String
    let region, locationString: String
    let countryID, wallet: Int
    let paypal: String
    let visitorPrivate, profileView: Int
    let resetWalletDatetime: String
    let referralCode: String
    let business, parent: Int
    let created: String
    let followerCount, videoCount: Int
    var button: String

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case bio, website, dob
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
        case visitorPrivate = "private"
        case profileView = "profile_view"
        case resetWalletDatetime = "reset_wallet_datetime"
        case referralCode = "referral_code"
        case business, parent, created
        case followerCount = "follower_count"
        case videoCount = "video_count"
        case button
    }
}
