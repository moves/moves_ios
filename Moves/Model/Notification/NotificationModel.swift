//
//  NotificationModel.swift
// //
//
//  Created by Wasiq Tayyab on 05/06/2024.
//

import Foundation

struct NotificationReponse: Codable {
    let code: Int
    var msg: [NotificationReponseMsg]?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode([NotificationReponseMsg].self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct NotificationReponseMsg: Codable {
    let notification: Notification
    var video: Video?
    var sender: HomeUser?
    var receiver: Receiver?
    var pinComment: PinComment?
    var user: User?
    var location: HomeLocation?
    var sound: Sound?
    var store: Store?

    enum CodingKeys: String, CodingKey {
        case notification = "Notification"
        case video = "Video"
        case sender = "Sender"
        case receiver = "Receiver"
        case pinComment = "PinComment"
        case user = "User"
        case location = "Location"
        case sound = "Sound"
        case store = "Store"
    }
}


// MARK: - Notification
struct Notification: Codable {
    let id: Int?
    let senderID: Int?
    let receiverID: Int?
    let string: String?
    let type: String?
    let videoID: Int?
    let liveStreamingID: Int?
    let roomID: Int?
    let status: String?
    let read: Int?
    let created: String?
    let orderID: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case senderID = "sender_id"
        case receiverID = "receiver_id"
        case string, type
        case videoID = "video_id"
        case liveStreamingID = "live_streaming_id"
        case roomID = "room_id"
        case status, read, created
        case orderID = "order_id"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(senderID, forKey: .senderID)
        try container.encodeIfPresent(receiverID, forKey: .receiverID)
        try container.encodeIfPresent(string, forKey: .string)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(videoID, forKey: .videoID)
        try container.encodeIfPresent(liveStreamingID, forKey: .liveStreamingID)
        try container.encodeIfPresent(roomID, forKey: .roomID)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(read, forKey: .read)
        try container.encodeIfPresent(created, forKey: .created)
        try container.encodeIfPresent(orderID, forKey: .orderID)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        senderID = try container.decodeIfPresent(Int.self, forKey: .senderID)
        receiverID = try container.decodeIfPresent(Int.self, forKey: .receiverID)
        string = try container.decodeIfPresent(String.self, forKey: .string)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        videoID = try container.decodeIfPresent(Int.self, forKey: .videoID)
        liveStreamingID = try container.decodeIfPresent(Int.self, forKey: .liveStreamingID)
        roomID = try container.decodeIfPresent(Int.self, forKey: .roomID)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        read = try container.decodeIfPresent(Int.self, forKey: .read)
        created = try container.decodeIfPresent(String.self, forKey: .created)
        orderID = try container.decodeIfPresent(Int.self, forKey: .orderID)
    }
}

// MARK: - Receiver
struct Receiver: Codable {
    let id: Int?
    let firstName: String?
    let lastName: String?
    let bio: String?
    let website: String?
    let dob: String?
    let socialID: String?
    let email: String?
    let phone: String?
    let password: String?
    let profilePic: String?
    let profilePicSmall: String?
    let profileGIF: String?
    let profileVideo: String?
    let role: String?
    let username: String?
    let social: String?
    let deviceToken: String?
    let token: String?
    let active: Int?
    let lat: String?
    let long: String?
    let online: Int?
    let verified: Int?
    let authToken: String?
    let version: String?
    let device: String?
    let ip: String?
    let city: String?
    let country: String?
    let state: String?
    let region: String?
    let locationString: String?
    let countryID: Int?
    let wallet: Int?
    let paypal: String?
    let receiverPrivate: Int?
    let profileView: Int?
    let resetWalletDatetime: String?
    let referralCode: String?
    let business: Int?
    let parent: Int?
    let created: String?
    var button: String?

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
        case receiverPrivate = "private"
        case profileView = "profile_view"
        case resetWalletDatetime = "reset_wallet_datetime"
        case referralCode = "referral_code"
        case business, parent, created, button
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(bio, forKey: .bio)
        try container.encodeIfPresent(website, forKey: .website)
        try container.encodeIfPresent(dob, forKey: .dob)
        try container.encodeIfPresent(socialID, forKey: .socialID)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encodeIfPresent(password, forKey: .password)
        try container.encodeIfPresent(profilePic, forKey: .profilePic)
        try container.encodeIfPresent(profilePicSmall, forKey: .profilePicSmall)
        try container.encodeIfPresent(profileGIF, forKey: .profileGIF)
        try container.encodeIfPresent(profileVideo, forKey: .profileVideo)
        try container.encodeIfPresent(role, forKey: .role)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(social, forKey: .social)
        try container.encodeIfPresent(deviceToken, forKey: .deviceToken)
        try container.encodeIfPresent(token, forKey: .token)
        try container.encodeIfPresent(active, forKey: .active)
        try container.encodeIfPresent(lat, forKey: .lat)
        try container.encodeIfPresent(long, forKey: .long)
        try container.encodeIfPresent(online, forKey: .online)
        try container.encodeIfPresent(verified, forKey: .verified)
        try container.encodeIfPresent(authToken, forKey: .authToken)
        try container.encodeIfPresent(version, forKey: .version)
        try container.encodeIfPresent(device, forKey: .device)
        try container.encodeIfPresent(ip, forKey: .ip)
        try container.encodeIfPresent(city, forKey: .city)
        try container.encodeIfPresent(country, forKey: .country)
        try container.encodeIfPresent(state, forKey: .state)
        try container.encodeIfPresent(region, forKey: .region)
        try container.encodeIfPresent(locationString, forKey: .locationString)
        try container.encodeIfPresent(countryID, forKey: .countryID)
        try container.encodeIfPresent(wallet, forKey: .wallet)
        try container.encodeIfPresent(paypal, forKey: .paypal)
        try container.encodeIfPresent(receiverPrivate, forKey: .receiverPrivate)
        try container.encodeIfPresent(profileView, forKey: .profileView)
        try container.encodeIfPresent(resetWalletDatetime, forKey: .resetWalletDatetime)
        try container.encodeIfPresent(referralCode, forKey: .referralCode)
        try container.encodeIfPresent(business, forKey: .business)
        try container.encodeIfPresent(parent, forKey: .parent)
        try container.encodeIfPresent(created, forKey: .created)
        try container.encodeIfPresent(button, forKey: .button)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        website = try container.decodeIfPresent(String.self, forKey: .website)
        dob = try container.decodeIfPresent(String.self, forKey: .dob)
        socialID = try container.decodeIfPresent(String.self, forKey: .socialID)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        password = try container.decodeIfPresent(String.self, forKey: .password)
        profilePic = try container.decodeIfPresent(String.self, forKey: .profilePic)
        profilePicSmall = try container.decodeIfPresent(String.self, forKey: .profilePicSmall)
        profileGIF = try container.decodeIfPresent(String.self, forKey: .profileGIF)
        profileVideo = try container.decodeIfPresent(String.self, forKey: .profileVideo)
        role = try container.decodeIfPresent(String.self, forKey: .role)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        social = try container.decodeIfPresent(String.self, forKey: .social)
        deviceToken = try container.decodeIfPresent(String.self, forKey: .deviceToken)
        token = try container.decodeIfPresent(String.self, forKey: .token)
        active = try container.decodeIfPresent(Int.self, forKey: .active)
        lat = try container.decodeIfPresent(String.self, forKey: .lat)
        long = try container.decodeIfPresent(String.self, forKey: .long)
        online = try container.decodeIfPresent(Int.self, forKey: .online)
        verified = try container.decodeIfPresent(Int.self, forKey: .verified)
        authToken = try container.decodeIfPresent(String.self, forKey: .authToken)
        version = try container.decodeIfPresent(String.self, forKey: .version)
        device = try container.decodeIfPresent(String.self, forKey: .device)
        ip = try container.decodeIfPresent(String.self, forKey: .ip)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        locationString = try container.decodeIfPresent(String.self, forKey: .locationString)
        countryID = try container.decodeIfPresent(Int.self, forKey: .countryID)
        wallet = try container.decodeIfPresent(Int.self, forKey: .wallet)
        paypal = try container.decodeIfPresent(String.self, forKey: .paypal)
        receiverPrivate = try container.decodeIfPresent(Int.self, forKey: .receiverPrivate)
        profileView = try container.decodeIfPresent(Int.self, forKey: .profileView)
        resetWalletDatetime = try container.decodeIfPresent(String.self, forKey: .resetWalletDatetime)
        referralCode = try container.decodeIfPresent(String.self, forKey: .referralCode)
        business = try container.decodeIfPresent(Int.self, forKey: .business)
        parent = try container.decodeIfPresent(Int.self, forKey: .parent)
        created = try container.decodeIfPresent(String.self, forKey: .created)
        button = try container.decodeIfPresent(String.self, forKey: .button)
    }
}


// MARK: - Sender
struct Sender: Codable {
    let id: Int?
    let firstName: String?
    let lastName: String?
    let bio: String?
    let website: String?
    let dob: String?
    let socialID: String?
    let email: String?
    let phone: String?
    let password: String?
    let profilePic: String?
    let profilePicSmall: String?
    let profileGIF: String?
    let profileVideo: String?
    let role: String?
    let username: String?
    let social: String?
    let deviceToken: String?
    let token: String?
    let active: Int?
    let lat: String?
    let long: String?
    let online: Int?
    let verified: Int?
    let authToken: String?
    let version: String?
    let device: String?
    let ip: String?
    let city: String?
    let country: String?
    let state: String?
    let region: String?
    let locationString: String?
    let countryID: Int?
    let wallet: Int?
    let paypal: String?
    let receiverPrivate: Int?
    let profileView: Int?
    let resetWalletDatetime: String?
    let referralCode: String?
    let business: Int?
    let parent: Int?
    let created: String?
    var button: String?

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
        case receiverPrivate = "private"
        case profileView = "profile_view"
        case resetWalletDatetime = "reset_wallet_datetime"
        case referralCode = "referral_code"
        case business, parent, created, button
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(bio, forKey: .bio)
        try container.encodeIfPresent(website, forKey: .website)
        try container.encodeIfPresent(dob, forKey: .dob)
        try container.encodeIfPresent(socialID, forKey: .socialID)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encodeIfPresent(password, forKey: .password)
        try container.encodeIfPresent(profilePic, forKey: .profilePic)
        try container.encodeIfPresent(profilePicSmall, forKey: .profilePicSmall)
        try container.encodeIfPresent(profileGIF, forKey: .profileGIF)
        try container.encodeIfPresent(profileVideo, forKey: .profileVideo)
        try container.encodeIfPresent(role, forKey: .role)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(social, forKey: .social)
        try container.encodeIfPresent(deviceToken, forKey: .deviceToken)
        try container.encodeIfPresent(token, forKey: .token)
        try container.encodeIfPresent(active, forKey: .active)
        try container.encodeIfPresent(lat, forKey: .lat)
        try container.encodeIfPresent(long, forKey: .long)
        try container.encodeIfPresent(online, forKey: .online)
        try container.encodeIfPresent(verified, forKey: .verified)
        try container.encodeIfPresent(authToken, forKey: .authToken)
        try container.encodeIfPresent(version, forKey: .version)
        try container.encodeIfPresent(device, forKey: .device)
        try container.encodeIfPresent(ip, forKey: .ip)
        try container.encodeIfPresent(city, forKey: .city)
        try container.encodeIfPresent(country, forKey: .country)
        try container.encodeIfPresent(state, forKey: .state)
        try container.encodeIfPresent(region, forKey: .region)
        try container.encodeIfPresent(locationString, forKey: .locationString)
        try container.encodeIfPresent(countryID, forKey: .countryID)
        try container.encodeIfPresent(wallet, forKey: .wallet)
        try container.encodeIfPresent(paypal, forKey: .paypal)
        try container.encodeIfPresent(receiverPrivate, forKey: .receiverPrivate)
        try container.encodeIfPresent(profileView, forKey: .profileView)
        try container.encodeIfPresent(resetWalletDatetime, forKey: .resetWalletDatetime)
        try container.encodeIfPresent(referralCode, forKey: .referralCode)
        try container.encodeIfPresent(business, forKey: .business)
        try container.encodeIfPresent(parent, forKey: .parent)
        try container.encodeIfPresent(created, forKey: .created)
        try container.encodeIfPresent(button, forKey: .button)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        website = try container.decodeIfPresent(String.self, forKey: .website)
        dob = try container.decodeIfPresent(String.self, forKey: .dob)
        socialID = try container.decodeIfPresent(String.self, forKey: .socialID)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        password = try container.decodeIfPresent(String.self, forKey: .password)
        profilePic = try container.decodeIfPresent(String.self, forKey: .profilePic)
        profilePicSmall = try container.decodeIfPresent(String.self, forKey: .profilePicSmall)
        profileGIF = try container.decodeIfPresent(String.self, forKey: .profileGIF)
        profileVideo = try container.decodeIfPresent(String.self, forKey: .profileVideo)
        role = try container.decodeIfPresent(String.self, forKey: .role)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        social = try container.decodeIfPresent(String.self, forKey: .social)
        deviceToken = try container.decodeIfPresent(String.self, forKey: .deviceToken)
        token = try container.decodeIfPresent(String.self, forKey: .token)
        active = try container.decodeIfPresent(Int.self, forKey: .active)
        lat = try container.decodeIfPresent(String.self, forKey: .lat)
        long = try container.decodeIfPresent(String.self, forKey: .long)
        online = try container.decodeIfPresent(Int.self, forKey: .online)
        verified = try container.decodeIfPresent(Int.self, forKey: .verified)
        authToken = try container.decodeIfPresent(String.self, forKey: .authToken)
        version = try container.decodeIfPresent(String.self, forKey: .version)
        device = try container.decodeIfPresent(String.self, forKey: .device)
        ip = try container.decodeIfPresent(String.self, forKey: .ip)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        locationString = try container.decodeIfPresent(String.self, forKey: .locationString)
        countryID = try container.decodeIfPresent(Int.self, forKey: .countryID)
        wallet = try container.decodeIfPresent(Int.self, forKey: .wallet)
        paypal = try container.decodeIfPresent(String.self, forKey: .paypal)
        receiverPrivate = try container.decodeIfPresent(Int.self, forKey: .receiverPrivate)
        profileView = try container.decodeIfPresent(Int.self, forKey: .profileView)
        resetWalletDatetime = try container.decodeIfPresent(String.self, forKey: .resetWalletDatetime)
        referralCode = try container.decodeIfPresent(String.self, forKey: .referralCode)
        business = try container.decodeIfPresent(Int.self, forKey: .business)
        parent = try container.decodeIfPresent(Int.self, forKey: .parent)
        created = try container.decodeIfPresent(String.self, forKey: .created)
        button = try container.decodeIfPresent(String.self, forKey: .button)
    }
}
