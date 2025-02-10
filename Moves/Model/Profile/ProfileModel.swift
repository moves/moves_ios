//
//  ProfileModel.swift
// //
//
//  Created by Wasiq Tayyab on 14/06/2024.
//

import Foundation

// MARK: - ProfileResponse
struct ProfileResponse: Codable, Equatable {
    let code: Int
    var msg: ProfileResponseMsg?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(code: Int, msg: ProfileResponseMsg? = nil, message: String? = nil) {
        self.code = code
        self.msg = msg
        self.message = message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode(ProfileResponseMsg.self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct ProfileResponseMsg: Codable, Equatable {
    var user: HomeUser?
    let pushNotification: PushNotification?
    let store: Store?
    let privacySetting: PrivacySetting?
    let playlist: [Playlist]?
    let card: [Card]?
    let deliveryAddress: [DeliveryAddress]?
    
    enum CodingKeys: String, CodingKey {
        case user = "User"
        case pushNotification = "PushNotification"
        case store = "Store"
        case privacySetting = "PrivacySetting"
        case playlist = "Playlist"
        case card = "Card"
        case deliveryAddress = "DeliveryAddress"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user = try container.decodeIfPresent(HomeUser.self, forKey: .user)
        self.pushNotification = try container.decodeIfPresent(PushNotification.self, forKey: .pushNotification)
        self.store = try container.decodeIfPresent(Store.self, forKey: .store)
        self.privacySetting = try container.decodeIfPresent(PrivacySetting.self, forKey: .privacySetting)
        
        // Decode playlist
        if let playlistArray = try? container.decodeIfPresent([Playlist].self, forKey: .playlist) {
            self.playlist = playlistArray
        } else if let _ = try? container.decodeIfPresent([String: Playlist].self, forKey: .playlist) {
            self.playlist = []
        } else {
            self.playlist = []
        }
        
        // Decode card
        if let cardArray = try? container.decodeIfPresent([Card].self, forKey: .card) {
            self.card = cardArray ?? []
        } else if let _ = try? container.decodeIfPresent([String: Card].self, forKey: .card) {
            self.card = []
        } else {
            self.card = []
        }
        
        // Decode deliveryAddress
        if let deliveryAddressArray = try? container.decodeIfPresent([DeliveryAddress].self, forKey: .deliveryAddress) {
            self.deliveryAddress = deliveryAddressArray ?? []
        } else if let _ = try? container.decodeIfPresent([String: DeliveryAddress].self, forKey: .deliveryAddress) {
            self.deliveryAddress = []
        } else {
            self.deliveryAddress = []
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(user, forKey: .user)
        try container.encodeIfPresent(pushNotification, forKey: .pushNotification)
        try container.encodeIfPresent(store, forKey: .store)
        try container.encodeIfPresent(privacySetting, forKey: .privacySetting)
        try container.encodeIfPresent(playlist, forKey: .playlist)
        try container.encodeIfPresent(card, forKey: .card)
        try container.encodeIfPresent(deliveryAddress, forKey: .deliveryAddress)
    }
}



// MARK: - User
struct UserProfile: Codable {
    let id: Int?
    var firstName, lastName, bio: String?
    var website, dob, socialID, email: String?
    let phone, password: String?
    var profilePic: String?
    let profilePicSmall, profileGIF, profileVideo, role: String?
    var username, social, deviceToken, token: String?
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
    let followersCount, followingCount, likesCount, videoCount: Int?
    let block, soldItemsCount, taggedProductsCount: Int?
    let button: String?
    let notification: Int?
    let interests: [InterestElement]
    let story: [String]?
    let unreadNotification: Int?
    let comissionEarned: Double?

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
        case userPrivate = "private"
        case profileView = "profile_view"
        case resetWalletDatetime = "reset_wallet_datetime"
        case referralCode = "referral_code"
        case business, parent, created
        case comissionEarned = "comission_earned"
        case followersCount = "followers_count"
        case followingCount = "following_count"
        case likesCount = "likes_count"
        case videoCount = "video_count"
        case block
        case soldItemsCount = "sold_items_count"
        case taggedProductsCount = "tagged_products_count"
        case button, notification, story
        case unreadNotification = "unread_notification"
        case interests = "Interests"
    }
    
    // Encode using encodeIfPresent
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
        try container.encodeIfPresent(userPrivate, forKey: .userPrivate)
        try container.encodeIfPresent(profileView, forKey: .profileView)
        try container.encodeIfPresent(resetWalletDatetime, forKey: .resetWalletDatetime)
        try container.encodeIfPresent(referralCode, forKey: .referralCode)
        try container.encodeIfPresent(business, forKey: .business)
        try container.encodeIfPresent(parent, forKey: .parent)
        try container.encodeIfPresent(created, forKey: .created)
        try container.encodeIfPresent(followersCount, forKey: .followersCount)
        try container.encodeIfPresent(followingCount, forKey: .followingCount)
        try container.encodeIfPresent(likesCount, forKey: .likesCount)
        try container.encodeIfPresent(videoCount, forKey: .videoCount)
        try container.encodeIfPresent(block, forKey: .block)
        try container.encodeIfPresent(soldItemsCount, forKey: .soldItemsCount)
        try container.encodeIfPresent(taggedProductsCount, forKey: .taggedProductsCount)
        try container.encodeIfPresent(button, forKey: .button)
        try container.encodeIfPresent(notification, forKey: .notification)
        try container.encodeIfPresent(story, forKey: .story)
        try container.encodeIfPresent(unreadNotification, forKey: .unreadNotification)
        try container.encodeIfPresent(comissionEarned, forKey: .comissionEarned)
        try container.encodeIfPresent(interests, forKey: .interests)
    }
    
    // Decode using decodeIfPresent
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
        countryID = try container.decodeIfPresent(StringOrInt.self, forKey: .countryID)
        wallet = try container.decodeIfPresent(StringOrInt.self, forKey: .wallet)
        paypal = try container.decodeIfPresent(String.self, forKey: .paypal)
        userPrivate = try container.decodeIfPresent(Int.self, forKey: .userPrivate)
        profileView = try container.decodeIfPresent(Int.self, forKey: .profileView)
        resetWalletDatetime = try container.decodeIfPresent(String.self, forKey: .resetWalletDatetime)
        referralCode = try container.decodeIfPresent(String.self, forKey: .referralCode)
        business = try container.decodeIfPresent(Int.self, forKey: .business)
        parent = try container.decodeIfPresent(Int.self, forKey: .parent)
        created = try container.decodeIfPresent(String.self, forKey: .created)
        followersCount = try container.decodeIfPresent(Int.self, forKey: .followersCount)
        followingCount = try container.decodeIfPresent(Int.self, forKey: .followingCount)
        likesCount = try container.decodeIfPresent(Int.self, forKey: .likesCount)
        videoCount = try container.decodeIfPresent(Int.self, forKey: .videoCount)
        block = try container.decodeIfPresent(Int.self, forKey: .block)
        soldItemsCount = try container.decodeIfPresent(Int.self, forKey: .soldItemsCount)
        taggedProductsCount = try container.decodeIfPresent(Int.self, forKey: .taggedProductsCount)
        button = try container.decodeIfPresent(String.self, forKey: .button)
        notification = try container.decodeIfPresent(Int.self, forKey: .notification)
        story = try container.decodeIfPresent([String].self, forKey: .story)
        unreadNotification = try container.decodeIfPresent(Int.self, forKey: .unreadNotification)
        comissionEarned = try container.decodeIfPresent(Double.self, forKey: .comissionEarned)
        if let interestsArr = try? container.decodeIfPresent([InterestElement].self, forKey: .interests) {
            self.interests = interestsArr
        } else if let _ = try? container.decodeIfPresent([String: InterestElement].self, forKey: .interests) {
            self.interests = []
        } else {
            self.interests = []
        }
    }
}


// MARK: - InterestElement
struct InterestElement: Codable, Equatable {
    let userInterest: UserInterest
    let interest: InterestInterest

    enum CodingKeys: String, CodingKey {
        case userInterest = "UserInterest"
        case interest = "Interest"
    }
}

// MARK: - InterestInterest
struct InterestInterest: Codable, Equatable {
    let id, interestSectionID: Int
    let title: String
    let order: Int
    let created: String

    enum CodingKeys: String, CodingKey {
        case id
        case interestSectionID = "interest_section_id"
        case title, order, created
    }
}

// MARK: - UserInterest
struct UserInterest: Codable, Equatable {
    let id, userID, interestID: Int
    let created: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case interestID = "interest_id"
        case created
    }
}
