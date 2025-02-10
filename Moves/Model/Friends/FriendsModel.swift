//
//  FriendsModel.swift
// //
//
//  Created by Wasiq Tayyab on 15/06/2024.
//

import Foundation

// MARK: - FriendsResponse
struct FollowingResponse: Codable {
    let code: Int
    var msg: [FollowingResponseMsg]?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode([FollowingResponseMsg].self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct FollowingResponseMsg: Codable {
    var user: HomeUser?
    var store: Store?

    enum CodingKeys: String, CodingKey {
        case user = "User"
        case store = "Store"
    }
}


// MARK: - FollowerResponse
struct FollowerResponse: Codable {
    let code: Int
    var msg: [FollowerResponseMsg]?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode([FollowerResponseMsg].self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct FollowerResponseMsg: Codable {
    var user: HomeUser?
    var store: Store?
    
    enum CodingKeys: String, CodingKey {
        case store = "Store"
        case user = "User"
    }
}

// MARK: - FollowerResponse
struct SuggestedResponse: Codable {
    let code: Int
    var msg: [SearchStoreResponseMsg]?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode([SearchStoreResponseMsg].self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Follower
struct Follower: Codable {
    let id, senderID, receiverID, notification: Int
    let promotionID: Int
    let created: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case senderID = "sender_id"
        case receiverID = "receiver_id"
        case notification
        case promotionID = "promotion_id"
        case created
    }
}

// MARK: - Notification
struct SuggestedNotification: Codable {
    let id, senderID, receiverID: Int
    let string: String
    let type: String
    let videoID, liveStreamingID, roomID: Int
    let status: String
    let read: Int
    let created: String
    let orderID: Int
    
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
}


struct FollowUserResponse: Codable {
    let code: Int
    var msg: FollowUserResponseMsg?
}

// MARK: - FollowUserResponseMsg
struct FollowUserResponseMsg: Codable {
    let user: HomeUser
    let pushNotification: PushNotification
    let store: Store?
    let privacySetting: PrivacySetting
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
        self.user = try container.decode(HomeUser.self, forKey: .user)
        self.pushNotification = try container.decode(PushNotification.self, forKey: .pushNotification)
        self.store = try container.decodeIfPresent(Store.self, forKey: .store)
        self.privacySetting = try container.decode(PrivacySetting.self, forKey: .privacySetting)
        self.playlist = (try? container.decodeIfPresent([Playlist].self, forKey: .playlist)) ?? []
        self.card = (try? container.decodeIfPresent([Card].self, forKey: .card)) ?? []
        self.deliveryAddress = (try? container.decodeIfPresent([DeliveryAddress].self, forKey: .deliveryAddress)) ?? []
    }
}
