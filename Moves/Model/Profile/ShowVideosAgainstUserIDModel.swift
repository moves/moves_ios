//
//  ShowVideosAgainstUserIDModel.swift
// //
//
//  Created by Wasiq Tayyab on 14/06/2024.
//

import Foundation

// MARK: - ShowVideosAgainstUserIDResponse
struct ShowVideosAgainstUserIDResponse: Codable {
    let code: Int?
    var msg: ShowVideosAgainstUserIDMsg?
    
    enum CodingKeys: String, CodingKey {

        case code = "code"
        case msg = "msg"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        msg = try values.decodeIfPresent(ShowVideosAgainstUserIDMsg.self, forKey: .msg)
    }

}

// MARK: - Msg
struct ShowVideosAgainstUserIDMsg: Codable {
    var msgPublic: [HomeResponseMsg]
    var msgPrivate: [HomeResponseMsg]

    enum CodingKeys: String, CodingKey {
        case msgPublic = "public"
        case msgPrivate = "private"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.msgPublic = try container.decodeIfPresent([HomeResponseMsg].self, forKey: .msgPublic) ?? []
        self.msgPrivate = try container.decodeIfPresent([HomeResponseMsg].self, forKey: .msgPrivate) ?? []
    }
}


struct ShowPrivateVideosAgainstUserIDResponse: Codable {
    let code: Int?
    var msg: ShowVideosAgainstUserIDMsg?
    
    enum CodingKeys: String, CodingKey {

        case code = "code"
        case msg = "msg"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        msg = try values.decodeIfPresent(ShowVideosAgainstUserIDMsg.self, forKey: .msg)
    }

}

struct ShowVideosAgainstUserIDPrivate: Codable {
    let video: Video
    let user: HomeUser
    let sound: Sound
    let location: HomeLocation
    let videoProduct: [VideoProduct]?

    enum CodingKeys: String, CodingKey {
        case video = "Video"
        case user = "User"
        case sound = "Sound"
        case videoProduct = "VideoProduct"
        case location = "Location"
    }
    
    // Custom initializer for decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        video = try container.decode(Video.self, forKey: .video)
        user = try container.decode(HomeUser.self, forKey: .user)
        sound = try container.decode(Sound.self, forKey: .sound)
        location = try container.decode(HomeLocation.self, forKey: .location)
        videoProduct = try container.decodeIfPresent([VideoProduct].self, forKey: .videoProduct)
    }
    
    // Custom method for encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(video, forKey: .video)
        try container.encode(user, forKey: .user)
        try container.encode(sound, forKey: .sound)
        try container.encode(location, forKey: .location)
        try container.encodeIfPresent(videoProduct, forKey: .videoProduct)
    }
}

// MARK: - Public
struct Public: Codable {
    let video: Video
    let user: HomeUser
    let sound: Sound
    let location: HomeLocation
    let videoProduct: [VideoProduct]?
   

    enum CodingKeys: String, CodingKey {
        case video = "Video"
        case user = "User"
        case sound = "Sound"
        case product = "Product"
        case videoProduct = "VideoProduct"
        case location = "Location"
    }
    
    // Custom initializer for decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        video = try container.decode(Video.self, forKey: .video)
        user = try container.decode(HomeUser.self, forKey: .user)
        sound = try container.decode(Sound.self, forKey: .sound)
        location = try container.decode(HomeLocation.self, forKey: .location)
        videoProduct = try container.decodeIfPresent([VideoProduct].self, forKey: .videoProduct)
    }
    
    // Custom method for encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(video, forKey: .video)
        try container.encode(user, forKey: .user)
        try container.encode(sound, forKey: .sound)
        try container.encode(location, forKey: .location)
        try container.encodeIfPresent(videoProduct, forKey: .videoProduct)
    }
}


// MARK: - User
struct UserPublic: Codable {
    let id: StringOrInt
    let firstName, lastName, bio, website: String
    let profilePic: String
    let profilePicSmall, profileGIF, deviceToken: String
    let business, parent: Int
    let username: String
    let pushNotification: PushNotification?
    let privacySetting: PrivacySetting?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case bio, website
        case profilePic = "profile_pic"
        case profilePicSmall = "profile_pic_small"
        case profileGIF = "profile_gif"
        case deviceToken = "device_token"
        case business, parent, username
        case pushNotification = "PushNotification"
        case privacySetting = "PrivacySetting"
    }
}
