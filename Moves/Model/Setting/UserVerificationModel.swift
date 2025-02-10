//
//  UserVerificationModel.swift
// //
//
//  Created by Wasiq Tayyab on 25/06/2024.
//

import Foundation

// MARK: - UserVerificationResponse
struct UserVerificationResponse: Codable {
    let code: Int
    let msg: UserVerificationResponseMsg
}

// MARK: - Msg
struct UserVerificationResponseMsg: Codable {
    let verificationRequest: VerificationRequest
    let user: UserVerificationUser?

    enum CodingKeys: String, CodingKey {
        case verificationRequest = "VerificationRequest"
        case user = "User"
    }
}

// MARK: - User
struct UserVerificationUser: Codable {
    let id: Int
    let firstName, lastName, gender, bio: String
    let website, dob, socialID, email: String
    let phone, password, profilePic, profilePicSmall: String
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
    let userPrivate, profileView: Int
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
        case userPrivate = "private"
        case profileView = "profile_view"
        case resetWalletDatetime = "reset_wallet_datetime"
        case referralCode = "referral_code"
        case business, parent, created
    }
}

// MARK: - VerificationRequest
struct VerificationRequest: Codable {
    let id, userID: Int
    let attachment, name: String
    let verified: Int
    let updateTime, created: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case attachment, name, verified
        case updateTime = "update_time"
        case created
    }
}
